" Test Inconsistent buffer settings.

let g:IngoLibrary_ConfirmChoices = ['change']

edit test014.txt
IndentConsistencyCop

call vimtest#Quit()

