# DNAfrAIlib

A database of DNA fragility (inside human cell nucleus) associated k-meric features for genomic sequence-driven machine learning.

## Setup

Clone the project:

```
git clone https://github.com/SahakyanLab/DNAfrAIlib.git
```

## Generate the feature matrix

Please run the below bash script to automatically concatenate all k-meric susceptibility scores into one feature matrix. It will also download the quantum mechanical hexameric parameters from [DNAkmerQM](https://github.com/SahakyanLab/DNAkmerQM/tree/master/6-mer).

```bash
bash get_tables.sh
```