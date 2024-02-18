#!/usr/bin/bash

# get quantum mechanical parameters
mkdir DNAkmerQM/
wget -P DNAkmerQM/ https://github.com/SahakyanLab/DNAkmerQM/raw/master/6-mer/denergy.zip
unzip ./DNAkmerQM/denergy.zip -d DNAkmerQM/

for kmer in 6 8
do
    # uncompress all files if still uncompressed
    for file in $(find ./$kmer-mer -name "*.gz")
    do
        echo $file
        if [ -f "$file" ]
        then
            gunzip "$file"
        fi
    done

    # concatenate files
    Rscript Process_tables.R $kmer
done