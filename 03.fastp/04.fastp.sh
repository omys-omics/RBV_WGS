#!/bin/bash
#SBATCH --job-name=fastp
#SBATCH --partition=bi
#SBATCH --time=100:00:00
#SBATCH --mem=60G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=out.%j.fastp.txt
#SBATCH --array=1-17

module load conda
conda activate fastp

# define input and output directories
INDIR=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/01.raw.reads/colellalab-jccgc-bw-28892-5j0LwCzqxPqGyTEv
OUTDIR=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/03.fastp
#mkdir $OUTDIR

# get all fastq files
MSBs=`ls $INDIR/MSB*.fastq.gz`
UAMs=`ls $INDIR/UAM*.fastq.gz`
fastqs=`echo $MSBs $UAMs`

# get all unique identifiers
IDs=`basename -a $fastqs | sed 's/_S.*//' | sort | uniq`

# figure out which ID of this iteration of the array
ID=$(echo "$IDs" | sed -n "${SLURM_ARRAY_TASK_ID}p")
echo $ID

# define input read files and output read files
READ1=$INDIR/$ID*R1*.fastq.gz
READ2=$INDIR/$ID*R2*.fastq.gz
OUT1=$OUTDIR/$ID.R1.fastq.gz
OUT2=$OUTDIR/$ID.R2.fastq.gz
UNPAIRED1=$OUTDIR/$ID.U1.fastq.gz
UNPAIRED2=$OUTDIR/$ID.U2.fastq.gz

echo $READ1
echo $READ2
echo $OUT1
echo $OUT2
echo $UNPAIRED1
echo $UNPAIRED2

fastp -i $READ1 -I $READ2 -o $OUT1 -O $OUT2 --unpaired1 $UNPAIRED1 --unpaired2 $UNPAIRED2 \
--detect_adapter_for_pe \
-5 20 -3 20 -q 20 -u 10 -c \
-h $ID.fastp.html

#  -i read1 input file name (string)
#  -o read1 output file name (string [=])
#  -I read2 input file name (string [=])
#  -O read2 output file name (string [=])

# --detect_adapter_for_pe by default, the adapter sequence auto-detection is enabled for SE data only, turn on this option to enable it for PE data.

# -5 move a sliding window from front (5') to tail, drop the bases in the window if its mean quality < threshold, stop otherwise.
# -3 move a sliding window from tail (3') to front, drop the bases in the window if its mean quality < threshold, stop otherwise.
# -W the window size option shared by cut_front, cut_tail or cut_sliding. Range: 1~1000, default: 4 (int [=4])

# -q the quality value that a base is qualified. Default 15 means phred quality >=Q15 is qualified. (int [=15])
# -u how many percents of bases are allowed to be unqualified (0~100). Default 40 means 40% (int [=40])

# -n if one read's number of N base is >n_base_limit, then this read/pair is discarded. Default is 5 (int [=5])
# -e if one read's average quality score <avg_qual, then this read/pair is discarded. Default 0 means no requirement (int [=0])

# -c enable base correction in overlapped regions (only for PE data), default is disabled

# -h the html format report file name (string [=fastp.html])


