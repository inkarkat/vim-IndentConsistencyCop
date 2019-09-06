" IndentConsistencyCop.vim: Is the buffer's indentation consistent and does it conform to tab settings?
"
" DEPENDENCIES:
"   - Requires Vim 7.0 or higher.
"
" Copyright: (C) 2006-2019 by Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

" Avoid installing twice or when in compatible mode
if exists('g:loaded_indentconsistencycop') || (v:version < 700)
    finish
endif
let g:loaded_indentconsistencycop = 1


"- configuration --------------------------------------------------------------

if ! exists('g:indentconsistencycop_highlighting')
    let g:indentconsistencycop_highlighting = 'sglmf:3'
endif
if g:indentconsistencycop_highlighting =~# 'm'
    highlight def link IndentConsistencyCop Error
endif

if ! exists('g:indentconsistencycop_non_indent_pattern')
    let g:indentconsistencycop_non_indent_pattern = [' \*\%([*/ \t]\|$\)', '^Comment$', 'FoldMarker$']
endif
if ! exists('g:IndentConsistencyCop_IgnorePatterns')
    let g:IndentConsistencyCop_IgnorePatterns = [['^\s\+', 'podVerbatimLine']]
endif

if ! exists('g:IndentConsistencyCop_UnacceptableIndentSettings')
    let g:IndentConsistencyCop_UnacceptableIndentSettings = ['spc1', 'sts1']
endif
if ! exists('g:IndentConsistencyCop_line_filters')
    if v:version < 702 | runtime autoload/IndentConsistencyCop/Pattern.vim | endif  " The Funcref doesn't trigger the autoload in older Vim versions.
    if v:version < 702 | runtime autoload/IndentConsistencyCop/BlockAlignment.vim | endif  " The Funcref doesn't trigger the autoload in older Vim versions.
    let g:IndentConsistencyCop_line_filters = [function('IndentConsistencyCop#Pattern#Filter'), function('IndentConsistencyCop#BlockAlignment#Filter')]
endif

if ! exists('g:IndentConsistencyCop_MenuExtensions')
    let g:IndentConsistencyCop_MenuExtensions = {}
endif

if ! exists('g:IndentConsistencyCop_IsCopyAndPreserveIndent')
    let g:IndentConsistencyCop_IsCopyAndPreserveIndent = 1
endif
if g:IndentConsistencyCop_IsCopyAndPreserveIndent
    augroup IndentConsistencyCop
	autocmd! User IndentConsistencyCop call IndentConsistencyCop#CopyAndPreserveIndent#Adapt()
    augroup END
endif



"- commands ------------------------------------------------------------------

" Ensure indent consistency within the range / buffer, and - if achieved -, also
" check consistency with buffer indent settings.
command! -bar -range=% -nargs=? -complete=customlist,IndentConsistencyCop#IndentSettingComplete IndentConsistencyCop call IndentConsistencyCop#IndentConsistencyCop(<line1>, <line2>, 1)

" Remove the highlighting of inconsistent lines and restore the normal view for
" this buffer.
command! -bar IndentConsistencyCopOff call IndentConsistencyCop#TurnOff()

" Only check indent consistency within range / buffer. Don't check the
" consistency with buffer indent settings. Prefer this command to
" IndentConsistencyCop if you don't want your buffer indent settings
" changed, or if you only want to check a limited range of the buffer that you
" know does not conform to the buffer indent settings.
command! -bar -range=% -nargs=? -complete=customlist,IndentConsistencyCop#IndentSettingComplete IndentRangeConsistencyCop call IndentConsistencyCop#IndentConsistencyCop(<line1>, <line2>, 0)

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
