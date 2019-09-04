" Test cop with filtering of matched lines with simple pattern and syntax.

syntax on
call vimtest#SkipAndQuitIf(! exists('g:syntax_on'), 'Need support for :syntax on')

let g:IndentConsistencyCop_line_filters = [function('IndentConsistencyCop#Pattern#Filter')]
let g:IndentConsistencyCop_IgnorePatterns = ['^\s\+####D', ['^\s\+', 'testExclusion']]

edit pattern.txt
syntax match testExclusion "\S.*\$$"

IndentConsistencyCop
call vimtest#Quit()
