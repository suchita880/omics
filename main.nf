/* PSL LSR offering - Multi-omics data integration
Input data preparation - Multiple omics
iClusterPlus run - Integration */

/* Version - 1 : Nov 2021 
Processes GE and CNV data and integrates using iClusterPlus */

/*
For Gene expression (GE) data
ge_prep --> Preparation of GE data - output goes to ge_preprocess 
ge_preprocess --> Preprocessing of GE data - output goes to iclusterplus
For Copy Number Variation (CNV) data 
cnv_prep --> Preparation of CNV data - output goes to cnv_preprocess
cnv_preprocess --> Preprocessing of CNV data - output goes to iclusterplus
Integration step
iclusterplus --> Integrates upto 4 data sets */

/* Usage command on : nextflow run main.nf --resume */

ge_path=params.reads + params.ge_input_dir
Channel.fromPath(ge_path, type:'dir').set{ get_GE }

ge_sampleID_mappingfile_path=params.reads + params.ge_sampleID_mapping
Channel.fromPath(ge_sampleID_mappingfile_path).set{ ge_sampleID_mappingfile}

// Processing begins //
//Preparation of GE data //
process ge_prep {
	input:
	publishDir params.output_dir, overwrite: true, mode: 'copy',
	  saveAs: { filename -> "$filename"}

	container "xxx.dkr.ecr.<region>.amazonaws.com/ge_prep:latest"

	input:
	val ge_prep_file from params.ge_prep_file
	file geInputDir from get_GE.collect()
	file geSampleIDMappingfile from ge_sampleID_mappingfile
	val geMappingSampleIDColumn from params.ge_mappingsampleID_column
	val geMappingfilenameColumn from  params.ge_mappingfilename_column
	val geWorkflowType from params.ge_workflow_type 
	val outdir from params.output_dir
	val geOutputfile from params.ge_output_file
	val gePrepLogfile from params.ge_prep_logfile
	
	output:
	path "*.csv" into gefile
	path "*" into result

	script:

	"""

	Rscript --vanilla $ge_prep_file --input_dir $geInputDir --sampleId_fileName_mapping $geSampleIDMappingfile --sampleId_column $geMappingSampleIDColumn --fileName_column $geMappingfilenameColumn --workflow_type "$geWorkflowType" --output_dir . --output_file $geOutputfile --log_file $gePrepLogfile

	"""
}