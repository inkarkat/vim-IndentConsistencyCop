" Test Inconsistent Perl script. 

let g:indentconsistencycop_choices = ['highlight', 'not buffer settings']

edit test030.txt
IndentConsistencyCop

call vimtest#Quit()

