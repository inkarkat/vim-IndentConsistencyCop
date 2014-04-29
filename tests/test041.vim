" Test Consistent indent settings. 

let g:indentconsistencycop_choices = []

edit test041.txt
IndentConsistencyCop

call vimtest#Quit()

