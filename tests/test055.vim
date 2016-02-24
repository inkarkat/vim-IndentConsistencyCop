" Test Consistent indentation 'sts4'.

let g:IngoLibrary_ConfirmChoices = []

edit test055.txt
IndentConsistencyCop

call vimtest#Quit()

