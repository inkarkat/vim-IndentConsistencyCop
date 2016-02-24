" Test Inconsistent: Contains one spc8 and some badmix.

let g:IngoLibrary_ConfirmChoices = ['highlight', 'not buffer settings']

edit test060.txt
IndentConsistencyCop

call vimtest#Quit()

