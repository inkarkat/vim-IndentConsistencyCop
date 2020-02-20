" Test cop with filtering of matched lines.

let g:IndentConsistencyCop_line_filters = [function('IndentConsistencyCop#Pattern#Filter')]
let g:IndentConsistencyCop_IgnorePatterns = ['^\s\+####D']

edit pattern.txt
1,/^__END__$/IndentConsistencyCop
call vimtest#Quit()
