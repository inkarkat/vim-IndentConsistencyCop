" Test extending the menu.

let s:action = ''
function! TestDummyAction()
    let s:action = 'dummy'
endfunction
function! MinimalDummyAction()
    let s:action = 'minimal'
endfunction

let g:IndentConsistencyCop_MenuExtensions = {
\   'Test Dummy': {
\       'priority': 100,
\       'choice':   'Test &Dummy',
\       'Action':   function('TestDummyAction')
\   },
\   'Minimal Dummy': {
\       'Action':   function('MinimalDummyAction')
\   }
\}

edit test051.txt

call vimtest#StartTap()
call vimtap#Plan(2)

let g:IngoLibrary_ConfirmChoices = ['Test Dummy']
IndentConsistencyCop
call vimtap#Is(s:action, 'dummy', 'dummy action invoked')

let g:IngoLibrary_ConfirmChoices = ['Minimal Dummy']
IndentConsistencyCop
call vimtap#Is(s:action, 'minimal', 'minimal dummy action invoked')

call vimtest#Quit()
