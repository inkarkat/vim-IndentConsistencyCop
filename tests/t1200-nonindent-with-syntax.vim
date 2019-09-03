" Test limiting g:indentconsistencycop_non_indent_pattern to certain syntax items.

setlocal tabstop=8 softtabstop=2 shiftwidth=2 expandtab
setfiletype c
syntax on
call vimtest#SkipAndQuitIf(! exists('g:syntax_on'), 'Need support for :syntax on')

call setline(1, ['/* here', ' * some', ' * comment', ' */', '    stuff', '      also', '  here'])
echomsg 'Comment detected by syntax'
IndentConsistencyCop

call setline(1, '!*no comment')
echomsg 'Broken comment'
let g:IngoLibrary_ConfirmChoices = ['highlight', 'not buffer settings']
IndentConsistencyCop

syntax off
echomsg 'Broken comment without syntax highlighting'
IndentConsistencyCop

call vimtest#Quit()
