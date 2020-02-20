" Test consistent indentation 'spc1'.
" Has inconsistent buffer settings (sts, sw should be 1, not 2).

let g:IndentConsistencyCop_UnacceptableIndentSettings = ''
let g:IngoLibrary_ConfirmChoices = ['ignore']

edit test071.txt
IndentConsistencyCop

call vimtest#Quit()
