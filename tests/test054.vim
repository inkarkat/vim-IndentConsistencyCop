" Test Contains one spc2 line, rest is spc4. 

let g:indentconsistencycop_choices = ['highlight', 'not buffer settings']

edit test054.txt
IndentConsistencyCop

call vimtest#Quit()

