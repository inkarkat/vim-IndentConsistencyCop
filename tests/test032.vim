" Test Inconsistent Java source code. 

let g:indentconsistencycop_choices = ['highlight', 'not best guess']

edit test032.txt
IndentConsistencyCop

call vimtest#Quit()

