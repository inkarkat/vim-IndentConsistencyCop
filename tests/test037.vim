" Test Inconsistent with one erroneous tab line.

let g:IngoLibrary_ConfirmChoices = ['highlight', 'not best guess']

edit test037.txt
IndentConsistencyCop

let g:IngoLibrary_ConfirmChoices = ['highlight', 'not chosen setting', 'spaces', '2']
IndentConsistencyCop

call vimtest#Quit()

