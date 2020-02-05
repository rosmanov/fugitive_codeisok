" Fugitive upstream provider for Codeisok
" Copyright © 2020 Ruslan Osmanov <ruslan.osmanov@corp.badoo.com>
if exists('g:autoloaded_fugitive_codeisok')
  finish
endif
let g:autoloaded_fugitive_codeisok = 1

function! s:function(name) abort
  return function(substitute(a:name,'^s:',matchstr(expand('<sfile>'), '<SNR>\d\+_'),''))
endfunction

"{{{
function! s:codeisok_url(opts, ...) abort
  if a:0 || type(a:opts) != type({})
    return ''
  endif
  let path = substitute(a:opts.path, '^/', '', '')

  let repo = matchstr(a:opts.remote, '\(:\)\@<=.*\.git$')
  if repo ==# ''
    return ''
  endif

  let base_url = exists('g:fugitive_codeisok_url_base') ? g:fugitive_codeisok_url_base : 'https://codeisok.badoojira.com'

  let root = base_url . '/?a=blob&p=' . repo

  if path =~# '^\.git/refs/heads/'
    return root . '&h=' . path[16:-1]
  elseif path =~# '^\.git/refs/tags/'
    return root . '&h=' .path[15:-1]
  elseif path =~# '^\.git\>'
    return root
  endif

  let commit = a:opts.repo.rev_parse('HEAD')

  if get(a:opts, 'type', '') ==# 'tree' || a:opts.path =~# '/$'
    let url = root . '&hb=' . commit . '&f=' . path
  elseif get(a:opts, 'type', '') ==# 'blob' || a:opts.path =~# '[^/]$'
    let url = root . '&hb=' . commit . '&f=' . path
    if get(a:opts, 'line1')
      let url .= '#L' . a:opts.line1
      " Line ranges seem to be unspported in Codeisok
      if get(a:opts, 'line2')
        let url .= ':' . a:opts.line2
      endif
    endif
  else
    let url = root . '&hb=' . commit
  endif
  return url
endfunction
"}}}
"
if !exists('g:fugitive_browse_handlers')
  let g:fugitive_browse_handlers = []
endif

call insert(g:fugitive_browse_handlers, s:function('s:codeisok_url'))
" vim: et ts=2 sts=2 sw=2 fdm=marker
