" Test Inconsistent: spc4 with one badmix. 

let g:indentconsistencycop_choices = ['highlight', 'not buffer settings']

edit test062.txt
IndentConsistencyCop

call vimtest#Quit()
