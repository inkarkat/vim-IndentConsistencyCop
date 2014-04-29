" Test Inconsistent indent settings. 

let g:indentconsistencycop_choices = ['change']

edit test040.txt
IndentConsistencyCop

call vimtest#Quit()

