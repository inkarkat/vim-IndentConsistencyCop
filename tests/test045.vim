" Test Inconsistent with buffer settings. 

let g:indentconsistencycop_choices = ['change']

edit test045.txt
IndentConsistencyCop

call vimtest#Quit()

