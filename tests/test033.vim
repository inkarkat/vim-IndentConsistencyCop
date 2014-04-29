" Test Inconsistent buffer settings (noexpandtab should be expandtab). 

let g:indentconsistencycop_choices = ['change']

edit test033.txt
IndentConsistencyCop

call vimtest#Quit()

