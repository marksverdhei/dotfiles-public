# If slurm isnt installed, define a remote 
if ! cmd_exists 'slurm'; then
  # SLURM_CLUSTER=yourcluster
  # SLURM_USERNAME=yourname
  # SLURM_PREFIX="ssh -n ${SLURM_USERNAME}@${SLURM_CLUSTER}"
  #
  # alias slurm='${SLURM_PREFIX} slurm'
  # alias sacct='${SLURM_PREFIX} sacct'
  # alias sbatch='${SLURM_PREFIX} slurm'
  # alias squeue='${SLURM_PREFIX} squeue'
  # alias srun='${SLURM_PREFIX} srun'
  # alias scontrol='${SLURM_PREFIX} scontrol'
  # alias scancel='${SLURM_PREFIX} scancel'
  alias lzs='turm --user ${SLURM_USERNAME} --remote ${SLURM_USERNAME}@${SLURM_CLUSTER}'
else
  alias lzs='turm --user $USER'
fi

alias sa='sacct'
alias sb='sbatch'
alias sq='squeue'
alias sr='srun'
alias sco='scontrol'
alias sca='scancel'

alias squ='squeue -u $USER'
alias sps='squeue -u $USER'
