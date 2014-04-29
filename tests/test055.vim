" Test Consistent indentation 'sts4'. 

let g:indentconsistencycop_choices = []

edit test055.txt
IndentConsistencyCop

call vimtest#Quit()

