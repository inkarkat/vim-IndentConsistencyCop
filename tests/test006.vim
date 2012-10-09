" Test Consistent indentation, but only small indents. Possibly wrong 'noexpandtab'. 

let g:indentconsistencycop_choices = ['wrong', 'soft tabstop', '2']

edit test006.txt
IndentConsistencyCop

call vimtest#Quit()

