" Test With a maximum indent of 8, is spc4, but the majority is spc8.
" Inconsistent buffer settings of sts4 prevent turn-around of verdict.

let g:IngoLibrary_ConfirmChoices = ['highlight', 'not chosen setting', 'spaces', '4']

edit test070.txt
IndentConsistencyCop

call vimtest#Quit()
