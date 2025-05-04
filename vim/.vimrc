set expandtab
set tabstop=4
set list
set listchars=tab:>-

" Source local vim settings if they exist
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
