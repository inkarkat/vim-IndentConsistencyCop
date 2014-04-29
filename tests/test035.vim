" Test Inconsistent large C++ source code. 

let g:indentconsistencycop_choices = ['highlight', 'not buffer settings']

edit test035.txt
IndentConsistencyCop

call vimtest#Quit()

