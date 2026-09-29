suppressPackageStartupMessages(library(bambu))

args <- commandArgs(trailingOnly = TRUE)
scenario <- args[1]
genome_file <- args[2]
gtf_file <- args[3]

bam_files <- sort(list.files(".", pattern = "\\.bam$", full.names = TRUE))
stopifnot(length(bam_files) == 4L)
cat("Scenario:", scenario, "\n")
print(bam_files)

annotations <- if (scenario == "annotated") {
  prepareAnnotations(gtf_file)
} else if (scenario == "de_novo") {
  NULL
} else {
  stop("Unknown scenario: ", scenario)
}

se <- bambu(
  reads = bam_files,
  annotations = annotations,
  genome = genome_file,
  ncore = 1,
  lowMemory = TRUE,
  verbose = TRUE,
  NDR = 0.1
)

saveRDS(se, "se.rds")
dir.create("bambu_output", showWarnings = FALSE)
writeBambuOutput(se, path = "bambu_output/")
cat("Bambu finished:", format(Sys.time()), "\n")
show(se)
