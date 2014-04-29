" Test Consistent, but guessed wrong setting: This is tab, not sts4. 

let g:indentconsistencycop_choices = ['wrong', 'tabstop']

edit test053.txt
IndentConsistencyCop

let g:indentconsistencycop_choices = ['change']
IndentConsistencyCop

call vimtest#Quit()

