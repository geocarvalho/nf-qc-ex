#!/usr/bin/env Rscript
library(optparse)

VERSION <- "v0.1"

# Define command-line options
option_list <- list(
  make_option(c("-v", "--version"), action="store_true", default=FALSE,
              help="Print version and exit"),
  make_option(c("-i", "--input"), type="character", default=NULL, 
              help="Path to input TSV file", metavar="FILE"),
  make_option(c("-o", "--output"), type="character", default="output.bw", 
              help="Path to output BigWig file [default=%default]", metavar="FILE"),
  make_option(c("-r", "--removed"), type="character", default="removed_intervals.tsv", 
              help="Path to output TSV of removed intervals [default=%default]", metavar="FILE"),
  make_option(c("-c", "--chrom-col"), type="character", default="chromosome", 
              help="Name of chromosome column [default=%default]"),
  make_option(c("-s", "--start-col"), type="character", default="start", 
              help="Name of start position column [default=%default]"),
  make_option(c("-e", "--end-col"), type="character", default="end", 
              help="Name of end position column [default=%default]"),
  make_option(c("-b", "--bf-col"), type="character", default="BF", 
              help="Name of Bayes Factor column [default=%default]")
)

# Parse arguments
opt <- parse_args(OptionParser(option_list=option_list))

# Handle --version flag
if (opt$version) {
  cat(VERSION, "\n")
  quit(status=0)
}

# Check required input
if (is.null(opt$input)) {
  stop("Input file must be specified (-i/--input)", call.=FALSE)
}

# Main script (modified from previous version)
library(rtracklayer)
library(BSgenome.Hsapiens.UCSC.hg38)
library(GenomicRanges)

bed <- read.delim(opt$input, header=TRUE, stringsAsFactors=FALSE)
selected_data <- bed[, c(opt$`chrom-col`, opt$`start-col`, opt$`end-col`, opt$`bf-col`)]
colnames(selected_data) <- c("chromosome", "start", "end", "BF") # Standardize column names

# Select and clean data
selected_data <- bed[, c("chromosome", "start", "end", "BF")]
selected_data$chromosome <- paste0("chr", sub("^chr", "", selected_data$chromosome))
selected_data$BF <- as.numeric(selected_data$BF)

# Remove NA values
selected_data <- selected_data[!is.na(selected_data$BF), ]

# Convert log10(BF) to log2(BF)
selected_data$BF <- selected_data$BF / log10(2)  # log2(x) = log10(x) / log10(2)

# Create temporary GRanges for processing overlaps
temp_gr <- GRanges(
  seqnames = selected_data$chromosome,
  ranges = IRanges(start = selected_data$start, end = selected_data$end),
  BF = selected_data$BF
)

# Find overlaps
hits <- findOverlaps(temp_gr, temp_gr)

# Convert to data frame for easier manipulation
hits_df <- as.data.frame(hits)

# Only keep pairs where query < subject to avoid duplicate comparisons
hits_df <- hits_df[hits_df$queryHits < hits_df$subjectHits, ]

# Initialize vectors to track kept/removed intervals
to_remove <- integer()
removed_intervals <- GRanges()  # Stores removed intervals

if(nrow(hits_df) > 0) {
  for(i in 1:nrow(hits_df)) {
    q <- hits_df$queryHits[i]
    s <- hits_df$subjectHits[i]
    
    # Compare absolute BF values (log2)
    if(abs(temp_gr$BF[q]) > abs(temp_gr$BF[s])) {
      to_remove <- c(to_remove, s)
      removed_intervals <- c(removed_intervals, temp_gr[s])  # Add removed interval
    } else {
      to_remove <- c(to_remove, q)
      removed_intervals <- c(removed_intervals, temp_gr[q])  # Add removed interval
    }
  }
  
  # Keep only non-overlapping or highest BF intervals
  keep <- setdiff(1:length(temp_gr), unique(to_remove))
  temp_gr <- temp_gr[keep]
}

# Save removed intervals to TSV (if any)
if(length(removed_intervals) > 0) {
  removed_df <- as.data.frame(removed_intervals)
  removed_df <- removed_df[, c("seqnames", "start", "end", "BF")]  # Keep key columns
  colnames(removed_df) <- c("chromosome", "start", "end", "log2_BF")  # Rename BF column
  
  write.table(removed_df, 
              file = "removed_overlapping_intervals_log2BF.tsv",
              sep = "\t", 
              quote = FALSE, 
              row.names = FALSE)
  
  cat(sprintf("Saved %d removed intervals to 'removed_overlapping_intervals_log2BF.tsv'\n", 
              length(removed_intervals)))
} else {
  cat("No overlapping intervals were removed.\n")
}

# Create final GRanges with scores
bedgr <- GRanges(
  seqnames = seqnames(temp_gr),
  ranges = ranges(temp_gr),
  score = temp_gr$BF
)

# Get seqlengths
all_seqlengths <- seqlengths(Hsapiens)
present_chroms <- unique(seqnames(bedgr))
matching_seqlengths <- all_seqlengths[names(all_seqlengths) %in% present_chroms]

# Verify we found all chromosomes
if(length(present_chroms) != length(matching_seqlengths)) {
  missing <- setdiff(present_chroms, names(matching_seqlengths))
  warning("Some chromosomes not found in reference: ", paste(missing, collapse=", "))
}

# Set seqlengths
seqlengths(bedgr) <- matching_seqlengths[names(seqlengths(bedgr))]

# Save outputs
export.bw(bedgr, opt$output)
write.table(removed_df, opt$removed, sep="\t", quote=FALSE, row.names=FALSE)