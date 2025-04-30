for fasta_file in `ls de_barcode/*.fa | grep -v dedup | grep seq `; do
	path=`dirname $fasta_file`
	echo -e "Currently process file in the directory: $path"
	file_b=`basename ${fasta_file} .fa`
	file_b_2=`basename ${fasta_file} _filter.fa`
	echo -e "Currently process file: ${file_b}"

	# mkdir ${path}/duplicates blast
	# cat $fasta_file | seqkit rmdup -s -i -o ${path}/${file_b}_dedup.fa -d ${path}/duplicates/${file_b}_duplicates.fa -D ${path}/duplicates/${file_b}_duplicates.detail.txt
	# blastn -task blastn -db ../references/viral.1.1.genomic.fna -query ${path}/${file_b}_dedup.fa -out blast/${file_b}_vs_viral_db.blastn -outfmt '6 qlen qseqid sseqid ssciname stitle pident length mismatch gapopen qstart qend sstart send evalue bitscore' -max_target_seqs 5 -num_threads 16 -evalue 1E-20

	# blastn=blast/${file_b}_vs_viral_db.blastn
	# awk '!seen[$2]++' $blastn | cut -f2,5 | sed 's/,/\t/g' | cut -f1,2 | sed 's/ /_/g' > blast/${file_b}_vs_viral_db_filt.blastn
	# cut -f5 $blastn | cut -d ',' -f1 | sed 's/ /_/g' | sort | uniq > blast/${file_b}_aligned_phages.txt
	# cut -f2 $blastn | cut -d '_' -f8-10 | sort |  uniq > blast/${file_b}_matched_barcodes.txt

	# while read brc; do
	# 	grep $brc blast/${file_b}_vs_viral_db_filt.blastn > sub.tmp
	# 	obn=`grep $brc de_barcode/${file_b_2}_uniq_barcode.csv | cut -d ',' -f2`
	# 	bn=`cat sub.tmp | wc -l`
	# 	echo -e "${brc}\n${obn}\n${bn}" >> tmp
	# 	while read phg; do
	# 		pn=`grep $phg sub.tmp | wc -l`
	# 		echo -e "$pn" >> tmp
	# 	done < blast/${file_b}_aligned_phages.txt
	# 	cat tmp | xargs >> blast/${file_b}_vs_viral_db_filt_sorted.blastn
	# 	rm tmp sub.tmp
	# done < blast/${file_b}_matched_barcodes.txt

	echo -e "Barcode\nread\nblast_read" > tmp
	cat blast/${file_b}_aligned_phages.txt >> tmp
	cat tmp | xargs | sed 's/ /,/g' > ${file_b}_vs_viral_db_filt_sorted.csv
	cat blast/${file_b}_vs_viral_db_filt_sorted.blastn | sort -t ' ' -n -r -k2 | sed 's/ /,/g' >> ${file_b}_vs_viral_db_filt_sorted.csv
	rm tmp
done
