" Breif:    switch to last IM in insert mode, and english IM in other mode
" Author:   byhongda@163.com
" Date:     2020-02-08
" Version:  1.0.0

" script entrance checking {{{
" load once
if exists('g:autoim_loaded')
  finish
endif
let g:autoim_loaded = 1

" not windows
if (has("win32") || has("win95") || has("win64") || has("win16"))
  finish
endif

" not ssh
if exists('$SSH_TTY')
  finish
endif

" no command binary
if !executable("fcitx-remote")
  finish
endif
" }}}

" save compatible options
let s:keepcpo = &cpo
set cpo&vim

" main process {{{
" bind autocmds
function SetupAutoIM()
  augroup autoim
    au!
    au InsertEnter * call s:RestorePreviousIM()
    au InsertLeave * call s:SaveAndToEnglish()
  augroup END
endfunction

function s:RestorePreviousIM()
  let t = system("fcitx-remote -s " . g:autoim_last_im)
endfunction

function s:SaveAndToEnglish()
  " save current IM state
  let g:autoim_last_im = system("fcitx-remote -n")
  " change to english, if necessary
  if g:autoim_last_im != "com.apple.keylayout.ABC"
    let t = system("fcitx-remote -s com.apple.keylayout.ABC")
  endif
endfunction

set ttimeoutlen=50
" initialize variable
let g:autoim_last_im = "com.apple.keylayout.ABC"
call SetupAutoIM()
" }}}

" compatible for multiple-cursors plugin {{{
function s:EnterMultiCursorInsert()
  " disable autoim au during mutiple-cursors process
  au! autoim    
  call s:RestorePreviousIM()
endfunction

" vim-mutiple-cursors generates lots of InsertEnter events
" we will disable autoim at the first InsertEnter comming
function! Multiple_cursors_before()
  augroup autoim
    " disable normal autoim autocmds
    au!
    au InsertEnter * call s:EnterMultiCursorInsert()
  augroup END
endfunction

" leave multiple-cursors insert and resume to normal autoim
function! Multiple_cursors_after()
  call s:SaveAndToEnglish()
  call SetupAutoIM()
endfunction
" }}}

" restore compatible coptions
let &cpo=s:keepcpo
unlet s:keepcpo

" vim: set ts=2 sts=2 sw=2 expandtab :
