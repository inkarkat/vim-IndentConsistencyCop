" IndentConsistencyCop/CopyAndPreserveIndent.vim: Tweak indent-related editing settings when inconsistencies are ignored.
"
" DEPENDENCIES:
"
" Copyright: (C) 2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! IndentConsistencyCop#CopyAndPreserveIndent#Adapt() abort
    if get(b:indentconsistencycop_result, 'isIgnore', 0) && ! get(b:indentconsistencycop_result, 'isOff', 0)
	if ! exists('b:IndentConsistencyCop_SaveCopyAndPreserveIndent')
	    let b:IndentConsistencyCop_SaveCopyAndPreserveIndent = [&copyindent, &preserveindent]
	endif

	setlocal copyindent
	if IndentConsistencyCop#GetSettingFromIndentSetting(get(b:indentconsistencycop_result, 'bufferSettings', '')) !=# 'sts'
	    " Because of the tab-space combination, 'preserveindent' doesn't
	    " make sense with softtabstop.
	    setlocal preserveindent
	endif
    elseif exists('b:IndentConsistencyCop_SaveCopyAndPreserveIndent')
	let [&l:copyindent, &l:preserveindent] = b:IndentConsistencyCop_SaveCopyAndPreserveIndent
	unlet b:IndentConsistencyCop_SaveCopyAndPreserveIndent
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
