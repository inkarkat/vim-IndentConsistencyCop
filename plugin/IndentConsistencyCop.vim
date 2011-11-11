" IndentConsistencyCop.vim: Is the buffer's indentation consistent and does it conform to tab settings?
"
" DEPENDENCIES:
"   - Requires Vim 7.0 or higher. 
"   - Requires IndentConsistencyCop.vim autoload script. 
"
" Copyright: (C) 2006-2010 by Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.21.022	31-Dec-2010	Moved functions from plugin to separate autoload
"				script. 
"				Split off documentation into separate help file. 
"	...
"	0.01	08-Oct-2006	file creation

" Avoid installing twice or when in compatible mode
if exists('g:loaded_indentconsistencycop') || (v:version < 700)
    finish
endif
let g:loaded_indentconsistencycop = 1


"- configuration --------------------------------------------------------------
if ! exists('g:indentconsistencycop_highlighting')
    let g:indentconsistencycop_highlighting = 'sglmf:3'
endif

if ! exists('g:indentconsistencycop_non_indent_pattern')
    let g:indentconsistencycop_non_indent_pattern = ' \*[*/ \t]'
endif

if g:indentconsistencycop_highlighting =~# 'm'
    highlight def link IndentConsistencyCop Error
endif


"- commands ------------------------------------------------------------------
" Ensure indent consistency within the range / buffer, and - if achieved -, also
" check consistency with buffer indent settings. 
command! -bar -range=% IndentConsistencyCop call IndentConsistencyCop#IndentConsistencyCop(<line1>, <line2>, 1)

" Remove the highlighting of inconsistent lines and restore the normal view for
" this buffer. 
command! -bar IndentConsistencyCopOff call IndentConsistencyCop#ClearHighlighting()

" Only check indent consistency within range / buffer. Don't check the
" consistency with buffer indent settings. Prefer this command to
" IndentConsistencyCop if you don't want your buffer indent settings
" changed, or if you only want to check a limited range of the buffer that you
" know does not conform to the buffer indent settings. 
command! -bar -range=% IndentRangeConsistencyCop call IndentConsistencyCop#IndentConsistencyCop(<line1>, <line2>, 0)

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
