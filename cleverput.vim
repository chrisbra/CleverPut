
let s:debug = 1
fu! <sid>Warn(msg) "{{{3
    echohl WarningMsg
    echomsg 'Cleverput: '. a:msg
    echohl Normal
endfu

fu! <sid>TrimSpaces() "{{{3
    let _a  = winsaveview()
    " Reset some silly vi options
    let [ _gd, _ed, _magic, _ic ] = [ &gd, &ed, &l:magic, &ic ]
    setlocal gd&vim ed&vim magic&vim ic&vim

    try
	let chg = [ getpos("'[")[1:2], getpos("']")[1:2] ]
	let pat = []
	if chg[0][1] > 1 &&
	    \ match(getline(chg[0][0]), '^\s\+\%'. chg[0][1]. 'c') == -1
	    call add(pat, '\%(\(\s*\)\ze\%'. chg[0][0]. 'l\%'. chg[0][1]. 'c\)')
	endif
	if (chg[1][1]+1) < col('$') &&
	    \ match(getline(chg[1][1]), '\%'. chg[1][1]. 'c\s\+$') == -1
	    call add(pat, '\%(\%'. chg[1][0]. 'l\%'. (chg[1][1]+1). 'c\(\s*\)\)')
	endif

    "    let pat = '\%(\(\s*\)\ze\%'. chg[0][0]. 'l\%'. chg[0][1]. 'c\)\|\%('.
    "	    \ '\%'. chg[1][0]. 'l\%'. (chg[1][1]+1). 'c\(\s*\)\)' 
	" This should be safe, there can't by a slash in the pattern
	exe "'[,']". 's/\%(\%'. chg[0][0]. 'l\%'. chg[0][1]. 'c\s\+\)\|'. 
	    \ '\%(\s\+\%'. chg[1][0]. 'l\%'. chg[0][1]. 'c\)//ge' 
	if !empty(pat)
	    exe printf("'[,']s/%s/ /ge", join(pat, '\|'))
	endif
    catch
	" noop
	if s:debug
	    call <sid>Warn("Error: ". v:exception)
	endif
    finally
	let  [ &gd, &ed, &magic, &ic ] = [ _gd, _ed, _magic, _ic ]
	" Put the cursor on the last pasted char
	let _a.col = chg[1][1]
	call winrestview(_a)
    endtry
endfu


" Mappings: {{{3 
nnoremap <silent>  p p:<c-u>call <sid>TrimSpaces()<cr>
nnoremap <silent>  P P:<c-u>call <sid>TrimSpaces()<cr>
