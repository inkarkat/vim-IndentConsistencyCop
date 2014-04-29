" Test Inconsistent indentation. 

let g:indentconsistencycop_choices = ['highlight', 'not buffer settings']

edit test013.txt
IndentConsistencyCop

call vimtest#Quit()

