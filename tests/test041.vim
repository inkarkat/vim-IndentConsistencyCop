" Test Consistent indent settings.

let g:IngoLibrary_ConfirmChoices = []

edit test041.txt
IndentConsistencyCop

call vimtest#Quit()

