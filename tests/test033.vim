" Test Inconsistent buffer settings (noexpandtab should be expandtab).

let g:IngoLibrary_ConfirmChoices = ['change']

edit test033.txt
IndentConsistencyCop

call vimtest#Quit()

