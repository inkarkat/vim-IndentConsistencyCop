" Test With a maximum indent of 8, is spc4, but the majority is spc8.
" Tests that the inconsistent verdict of spc8 / spc4 is turned around by
" examining the buffer settings to spc4.

edit test069.txt
IndentConsistencyCop

call vimtest#Quit()
