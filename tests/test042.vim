" Test Consistent indent settings. 

let g:indentconsistencycop_choices = []

edit test042.txt
IndentConsistencyCop

call vimtest#Quit()

