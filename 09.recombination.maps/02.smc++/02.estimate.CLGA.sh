#!/bin/bash
#SBATCH --job-name=smc++
#SBATCH --partition=sixhour
#SBATCH --time=6:00:00
#SBATCH --mem=250G
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --output=outputs/out.%j.estimate.txt

date

species=CLGA
echo $species



in_files=`ls /kuhpc/scratch/bi/b686w673/009.RBV.WGS/09.recombination.maps/02.smc++/$species/smcs.mask/*.smc`
out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/09.recombination.maps/02.smc++/$species/estimate.mask


smc++ estimate --ftol 0.001 --cores 24 --timepoints 10 1000000 --spline cubic --base $species.ftol1e-3 -o $out_dir --polarization-error 0.5 8.7e-9 $in_files
  #--timepoints This command specifies the starting and ending time points of the model. It accepts two numbers t1 tK specifying the starting and ending time points of the model (in generations). If not specified, SMC++ will use an heuristic to calculate the model time points points automatically
  #--spline {cubic,pchip,piecewise} controls the functional form used to fit the model
  #--base base for file output
  #--polarization-error 
    # if the identity of the ancestral allele is not known, these options can be used to specify a prior over it
    # default setting is 0.5, i.e. the identity of the ancestral allele is not known
  #-o output directory
  # mutation rate
  # input files
  # --thinning This parameter controls the frequency with which the full CSFS is emitted (see paper for details). Decreasing the value of this parameter will cause the likelihood to depend more strongly on frequency spectrum information in the undistinguished portion of the sample, potentially leading to more accurate results in the recent past.
  # --ftol This parameter specifies a threshold for stopping the EM algorithm when the relative improvement in log-likelihood becomes small. The default value is 1e-4. If the tolerance is epsilon and x'/x are the new and old estimates, the algorithm will terminate when [loglik(x') - loglik(x)] / loglik(x) < epsilon. Increasing values of epsilon will cause the optimizer to stop earlier, potentially preventing overfitting.

date






