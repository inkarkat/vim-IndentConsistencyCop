" Test no configured highlighting.

let g:indentconsistencycop_highlighting = ''
let g:IndentConsistencyCop_AltHighlighting = {}
let g:IngoLibrary_ConfirmChoices = ['Ignore']

edit test053.txt
IndentConsistencyCop
call vimtest#Quit()
