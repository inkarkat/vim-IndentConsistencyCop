" Test consistent indentation 'spc1', forbidden by g:IndentConsistencyCop_UnacceptableIndentSettings.
" Has inconsistent buffer settings (sts, sw should be 1, not 2).

let g:IngoLibrary_ConfirmChoices = ['highlight', 'not buffer settings']

edit test071.txt
IndentConsistencyCop

call vimtest#Quit()
