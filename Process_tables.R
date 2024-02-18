suppressPackageStartupMessages(suppressWarnings(library(data.table)))
suppressPackageStartupMessages(suppressWarnings(library(dplyr)))

args <- commandArgs(trailingOnly = TRUE)
kmer <- as.integer(args[1])

# load all breakage files
files <- list.files(path = paste0("./", kmer, "-mer"), pattern = ".csv", full.names = TRUE)
df_breaks <- lapply(files, fread)
df_breaks <- rbindlist(df_breaks)

# load QM parameters
# only keep heat of formation and ionisation potential differences
df_qm <- fread("./DNAkmerQM/denergy.txt", showProgress = FALSE)
cols_to_keep <- c(1, which(grepl(pattern = "dEhof", x = colnames(df_qm))))
df_qm <- df_qm[, ..cols_to_keep]

# only keep columns matching with query data frame
if(kmer == 6){
    rows.to.keep <- match(tail(colnames(df_breaks), -1), df_qm$seq)
    df_qm <- df_qm[rows.to.keep,]
} else if(kmer == 8){
    # if breakage k-mer > QM kmers, then use a sliding window approach
    query_kmers <- tail(colnames(df_breaks), -1)
    len <- 3

    # rolling window substring
    list_kmer_vals <- lapply(1:len, function(x){
        first_kmer <- substring(
            text = query_kmers,
            first = x, 
            last = x+5
        )
        first_kmer_ind <- match(first_kmer, df_qm$seq)
        first_kmer_vals <- df_qm[first_kmer_ind, -"seq"]
    })

    # average all
    list_kmer_vals <- list_kmer_vals[[1]]+list_kmer_vals[[2]]+list_kmer_vals[[3]]
    df_qm <- list_kmer_vals / len
    df_qm[, seq := query_kmers]
}

# calculate z-scores for each value per column
df_qm_norm <- apply(df_qm[, -"seq"], 2, scale, center = TRUE, scale = TRUE)
df_qm_norm <- as.data.frame(t(df_qm_norm))

# add original kmer column back
colnames(df_qm_norm) <- df_qm$seq
params <- rownames(df_qm_norm)

# save results
df_qm_norm <- df_qm_norm %>% 
    dplyr::mutate(category = params, .before = 1) %>% 
    as.data.table(.) 

fwrite(
    df_qm_norm,
    file = paste0("./", kmer, "-mer/QM_PARAMETERS.csv"),
    showProgress = FALSE
)

# concatenate files
df_concat <- rbind(df_breaks, df_qm_norm)
df_concat <- as.data.table(df_concat)

# save files
fwrite(
    df_concat, 
    paste0("QueryTable_kmer-", kmer, "_zscore.csv"),
    showProgress = FALSE
)