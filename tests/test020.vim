" Test Also includes some spc2, badtab and badsts. 

let g:indentconsistencycop_choices = ['highlight', 'not best guess']

edit test020.txt
IndentConsistencyCop

call vimtest#Quit()

