" Test Possibly consistent indent settings.

let g:IngoLibrary_ConfirmChoices = ['change']

edit test043.txt
IndentConsistencyCop

call vimtest#Quit()

