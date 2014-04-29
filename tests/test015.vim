" Test Inconsistent buffer settings. 

let g:indentconsistencycop_choices = ['change']

edit test015.txt
IndentConsistencyCop

call vimtest#Quit()

