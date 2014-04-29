" Test Inconsistent: Contains one spc8 and some badmix. 

let g:indentconsistencycop_choices = ['highlight', 'not buffer settings']

edit test060.txt
IndentConsistencyCop

call vimtest#Quit()

