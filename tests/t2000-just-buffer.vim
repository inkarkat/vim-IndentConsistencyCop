" Test just adapting the buffer settings.

edit test051.txt
let g:IngoLibrary_ConfirmChoices = ['just change buffer settings', 'to best guess']
IndentConsistencyCop

let g:IngoLibrary_ConfirmChoices = ['just change buffer settings', 'soft tabstop', '2']
IndentConsistencyCop

call vimtest#Quit()
