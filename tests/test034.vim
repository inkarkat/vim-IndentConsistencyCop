" Test Very inconsistent large C source code.

let g:IndentConsistencyCop_IsFindBadMixEverywhere = 0
let g:IngoLibrary_ConfirmChoices = ['highlight', 'not buffer settings']

edit test034.txt
IndentConsistencyCop

call vimtest#Quit()

