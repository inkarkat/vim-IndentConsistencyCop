" Test Inconsistent: spc4 with one badmix and one spc1.

let g:IngoLibrary_ConfirmChoices = ['highlight', 'not buffer settings']

edit test061.txt
IndentConsistencyCop

call vimtest#Quit()

