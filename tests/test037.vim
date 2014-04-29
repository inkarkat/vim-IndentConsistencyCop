" Test Inconsistent with one erroneous tab line. 

let g:indentconsistencycop_choices = ['highlight', 'not best guess']

edit test037.txt
IndentConsistencyCop

let g:indentconsistencycop_choices = ['highlight', 'not chosen setting', 'spaces', '2']
IndentConsistencyCop

call vimtest#Quit()

