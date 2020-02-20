" Test finding badmix after indent by default.

let g:IngoLibrary_ConfirmChoices = ['highlight wrong indents', 'illegal indents only']

edit IsFindBadMixEverywhere.txt
IndentConsistencyCop

call vimtest#Quit()
