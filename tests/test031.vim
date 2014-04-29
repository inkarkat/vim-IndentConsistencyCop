" Test Inconsistent XSLT file. 

let g:indentconsistencycop_choices = ['highlight', 'not buffer settings']

edit test031.txt
IndentConsistencyCop

call vimtest#Quit()

