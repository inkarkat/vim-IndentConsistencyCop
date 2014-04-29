" Test Inconsistent buffer settings. 

let g:indentconsistencycop_choices = ['change']

edit test014.txt
IndentConsistencyCop

call vimtest#Quit()

