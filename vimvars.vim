" ==============================================================================
function! Vimvars_search (args_hash)
" ==============================================================================
  let l:args_hash = {}

  " --- Process Args
  if (len(a:args_hash['positional_args']) < 1) echoerr "ERROR: No args received in Vimvars_search() !!"
    return {}
  endif

  let     l:args_hash['search_string']     = ''
  if (len(a:args_hash['positional_args']) >= 1)
    let   l:args_hash['search_string']  
    \   = a:args_hash['positional_args'][0]
  endif

  " --- Write Vim vars to file

  "suppress display of warning W11 re vimvars.vim file
  let      l:autoread_original_value  = &autoread
  if       l:autoread_original_value == 0
    setlocal autoread
  endif 

  let      l:vimvars_filepath = tempname()
  execute 'redir! > ' . l:vimvars_filepath 
  " NOTE-DOC-VIM-execute(): needed, b/c otherewise writes to 'l:vimvars_filepath'
  " wanted to write to the vim temporary dir, set via 'set directory'
  " however, below does not work, so using built-in tempname()
  " which is actually a filepath.
  "   let      g:file_output_dir = &directory
  "   redir! > g:file_output_dir . '/vimvars.vim'
  " NOTE-DOC-VIM: putting :redir into func called w/ 'silent' 
  " suppresses echo to screen
  " NOTE-DOC-VIM: '!' overwrites existing file
  " the ! is superfluous wrt Vim tempname() operation

  let
  " output ALL vars, to screen if no `redir` as above

  redir END

  " restore
  if         l:autoread_original_value == 0
    setlocal noautoread
  endif 

  " --- Search file & display results

  botright copen
  " results from below search in the window at the very BOTTOM OF THE SCREEN
  " b/c some vimvars can have very long values, so want to spread values across
  " the full horizonatal of the screen, rather than crunching display into
  " lines that are too narrow.

  " Want vars at begin of each line  --
  let     g:execute_arg = 'vimgrep /' . l:args_hash['search_string'] . '/j  l:vimvars_filepath'
  execute g:execute_arg 
  " 'j' assures that the buffer in the window from which command is invoked is 
  " not replaced by l:vimvars_filepath, per Quckfix default behavior -- just need 
  " list of vimvars in quickfix window

 "let     g:execute_arg = 'Ack ' . l:args_hash['search_string'] . ' vimvars.vim'
 "not using Ack b/c it cannot be scoped to look at just one file, and does not
 "have a modifier equivalent to 'j' in :vimgrep
 "also, vimgrep is vim-built-in, Ack is plugin w/ perl dep

  " --- Remove vimgrep output that's cruft in local context
  copen 
  "first, ensure we're at Quckfix window

  let      l:modifiable_original_value  = &modifiable
  if       l:modifiable_original_value == 0
    setlocal modifiable
  endif 

  %s/^.*| // 
  " cruft from line begin to 2nd '|' -- e.g.
  "    vimvars.vim|60 col 1| NERDUsePlaceHolders    1
  sort

  " restore
  if         l:modifiable_original_value == 0
    setlocal nomodifiable
  endif 

  "N.B. Cruft removal for Ack:
  "%s/^.* \d\{1,\}:// 
  " cruft from line begin to ':' -- e.g.
  "    vimvars.vim|69| 1:smarterms_external_terminal_cmd_string_default  Y
  " there will be 1 or more digits in front of the ':' -- almost always 1 or 2
endfunction
" ------------------------------------------------------------------------------
command!  -range -nargs=*     VV   :silent! call Vimvars_search ({
         \  'positional_args' : [<f-args>]     
\}) 
" ==============================================================================
command!  -range -nargs=*     VVst :silent! call Vimvars_search ({
         \  'positional_args' : ['^terminal']     
\}) 
" ==============================================================================
