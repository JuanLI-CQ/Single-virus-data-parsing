# requird file for following process: 20240529-2_filter_dedup.fa, 20240529-2_uniq_barcode.csv
# files thaht will be generated afterwards: barcodes_gt1.list, 20240529-2_filter_dedup_gt1.fa 

for fasta in ../seq*_filter_dedup.fa; do
	id=`basename $fasta _filter_dedup.fa`
	# get a list of barcodes that have great than 1 of number of matched reads and the number of matched reads appended behind the barcode with "_"
	grep -v Barcord_ ../${id}_uniq_barcode.csv | awk -F ',' '($2 > 1) {print $1"_"$2}'  > ${id}_barcodes_gt1.list

	# grep all read based on the barcode list retrived above
	cat ${id}_barcodes_gt1.list | cut -d '_' -f1-3 | xargs -I {} -P 50 grep -A1 {}  $fasta > ${id}_filter_dedup_gt1.fa

	# replace barcode "singleX_XXX_XXX" to "singleX_XXX_XXX_readnumner"
	while read barcode; do 
		j=${barcode%_*}; 
		echo $j; 
		grep -A1 $j ${id}_filter_dedup_gt1.fa | sed "s/$j/$barcode/g" >> test.fa; 
	done < ${id}_barcodes_gt1.list
	mv test.fa ${id}_filter_dedup_gt1.fa

	# calculate the lenght of each read and append to the end of read id "singleX_XXX_XXX_readnumner_readlength"
	awk '/^>/{if (l!="") print l; print; l=0; next}{l+=length($0)}END{print l}' ${id}_filter_dedup_gt1.fa | paste - -  > test.txt
	cat ${id}_filter_dedup_gt1.fa | sed "s/--//g" | sed -r '/^\s*$/d' | paste - - > test.fa
	paste test.txt test.fa | cut -f 1,2,4 | sed 's/\t/_/' | tr -d $'\r' | tr "\t" "\n"> ${id}_filter_dedup_gt1.fa
	grep "^>" ${id}_filter_dedup_gt1.fa | cut -d '_' -f 12 | sort -n -r > ${id}_readlength_gt1.numbers
	rm test.txt test.fa
done
