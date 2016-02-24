" Test cop with filtering of block alignment.

let g:IndentConsistencyCop_line_filters = [function('IndentConsistencyCop#Filter#BlockAlignment')]
let g:IngoLibrary_ConfirmChoices = ['highlight', 'not buffer settings']

edit BlockAlignment.txt
IndentConsistencyCop
call vimtest#Quit()
