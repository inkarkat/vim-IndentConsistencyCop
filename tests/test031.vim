" Test Inconsistent XSLT file.

let g:IngoLibrary_ConfirmChoices = ['highlight', 'not buffer settings']

edit test031.txt
IndentConsistencyCop

call vimtest#Quit()

