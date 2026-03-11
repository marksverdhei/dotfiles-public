alias hfum="hf upload --private --repo-type model"
alias hfud="hf upload --private --repo-type dataset"

alias hfsm="hf cache scan | awk 'NR > 2 {print \$1}' | fzf"
alias cpm='hfsm | xcp'

alias test-tokenizer='testok $(hfm)'
alias test-model='hfpipe $(hfm)'
