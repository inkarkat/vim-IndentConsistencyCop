" Test Inconsistent large C++ source code.

let g:IngoLibrary_ConfirmChoices = ['highlight', 'not buffer settings']

edit test035.txt
IndentConsistencyCop

call vimtest#Quit()

