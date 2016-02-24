" Test Inconsistent with one erroneous tab line.

edit test037.txt

let g:IngoLibrary_ConfirmChoices = ['highlight', 'not best guess']
IndentConsistencyCop

let g:IngoLibrary_ConfirmChoices = ['highlight', 'not chosen setting', 'spaces', '2']
IndentConsistencyCop

call vimtest#Quit()
