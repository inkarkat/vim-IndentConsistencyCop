" Test Inconsistent: spc4 with one badmix.

let g:IngoLibrary_ConfirmChoices = ['highlight', 'not buffer settings']

edit test062.txt
IndentConsistencyCop

call vimtest#Quit()

