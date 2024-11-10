" Test consistent 'badmix'

let g:IngoLibrary_ConfirmChoices = ['ignore']

edit test072.txt
IndentConsistencyCop

call vimtest#Quit()
