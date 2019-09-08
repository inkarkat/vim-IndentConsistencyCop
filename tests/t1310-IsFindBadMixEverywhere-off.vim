" Test turning off finding badmix after indent for the buffer.

edit IsFindBadMixEverywhere.txt
let b:IndentConsistencyCop_IsFindBadMixEverywhere = 0

IndentConsistencyCop

call vimtest#Quit()
