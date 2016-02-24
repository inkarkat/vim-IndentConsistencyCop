" Test Inconsistent Perl script.

let g:IngoLibrary_ConfirmChoices = ['highlight', 'not buffer settings']

edit test030.txt
IndentConsistencyCop

call vimtest#Quit()

