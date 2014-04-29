" Test Inconsistent: spc4 with one badmix and one spc1. 

let g:indentconsistencycop_choices = ['highlight', 'not buffer settings']

edit test061.txt
IndentConsistencyCop

call vimtest#Quit()

