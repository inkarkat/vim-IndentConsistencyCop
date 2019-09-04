" Test cop with filtering of block alignment.

let g:IndentConsistencyCop_line_filters = [function('IndentConsistencyCop#BlockAlignment#Filter')]
let g:IngoLibrary_ConfirmChoices = ['highlight', 'not buffer settings']

edit BlockAlignment.txt
IndentConsistencyCop
call vimtest#Quit()
