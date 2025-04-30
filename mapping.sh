reference_path="../references"

# # activate conda env singlevirus
# conda activate singlevirus

# # index reference
# bwa index -a is ${reference_path}/Bacteriophage_T1_T4_T7_RefGenomes.fasta
# samtools faidx ${reference_path}/Bacteriophage_T1_T4_T7_RefGenomes.fasta
# gatk CreateSequenceDictionary -R ${reference_path}/Bacteriophage_T1_T4_T7_RefGenomes.fasta -O ${reference_path}/Bacteriophage_T1_T4_T7_RefGenomes.dict
# awk '{print $1"\t""0""\t"$2}' ${reference_path}/Bacteriophage_T1_T4_T7_RefGenomes.fasta.fai > ${reference_path}/Bacteriophage_T1_T4_T7_RefGenomes.fasta.bed

# mkdir mapping
dos2unix de_barcode/count_readlength/seq*_barcodes_gt1.list

for brc_list in de_barcode/count_readlength/seq*_barcodes_gt1.list; do
    id=$(basename "$brc_list" _barcodes_gt1.list)
    echo -e "NC_005833.1_len\tMapped_reads\tMapped_len\tMapped_Cov\tNC_000866.4_len\tMapped_reads\tMapped_len\tMapped_Cov\tNC_001604.1_len\tMapped_reads\tMapped_len\tMapped_Cov" > mapping/${id}.coverage
    while read brc; do
        echo de_barcode/count_readlength/${id}_filter_dedup_gt1.fa
        echo ${brc}
        grep -A1 ${brc} de_barcode/count_readlength/${id}_filter_dedup_gt1.fa > mapping/tmp.fa
        # mapping against reference using BWA
        bwa aln ${reference_path}/Bacteriophage_T1_T4_T7_RefGenomes.fasta mapping/tmp.fa > mapping/R1.sai
        bwa samse ${reference_path}/Bacteriophage_T1_T4_T7_RefGenomes.fasta mapping/R1.sai mapping/tmp.fa >mapping/sample.sam
        samtools view -Sb mapping/sample.sam > mapping/sample.bam
        samtools view -b -h -F 0x04 mapping/sample.bam > mapping/sample_aligned.bam
        samtools sort -m 10G mapping/sample_aligned.bam -o mapping/sample_aligned.sorted.bam  
        bedtools bamtobed -i mapping/sample_aligned.sorted.bam -tag NM | bedtools coverage -a ${reference_path}/Bacteriophage_T1_T4_T7_RefGenomes.fasta.bed -b stdin | cut -f3,4,5,7 | paste -sd ',' | sed "s/\t/,/g" >> mapping/${id}.coverage
        rm tmp.fa mapping/R1.sai mapping/sample.sam mapping/sample.bam mapping/sample_aligned.bam mapping/sample_aligned.sorted.bam
    done< ${brc_list}

    sed "s/\t/,/g" mapping/${id}.coverage > tmp
    mv tmp mapping/${id}.coverage
    cut -d ',' -f1,2,3,4,5,8 ${id}_filter_vs_viral_db_filt_sorted.csv > tmp
    paste tmp mapping/${id}.coverage | awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$11"\t"$12"\t"$13"\t"$14"\t"$5"\t"$15"\t"$16"\t"$17"\t"$18"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10}' \
        | sed 's/\t/,/g'> ${id}_filter_vs_viral_db_filt_sorted_T147.csv
    rm tmp
done

