function! tweetnotify#notify(msg)
  let &titlestring=a:msg
  redraw
  return ""
endfunction
