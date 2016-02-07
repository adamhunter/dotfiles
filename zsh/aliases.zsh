# Helpful aliases
alias bx="bundle exec"
alias :q="exit"
alias :t="tail -n1000 -f $@"
alias :p="ps aux | grep -v grep | grep $@ -i --color=auto"
alias :spec="bundle exec rspec $@"

# default filetype actions
alias -s js="vim"
alias -s coffee="vim"
alias -s rb="vim"
alias -s haml="vim"
alias -s pdf="open"

# alias tmux='TERM=screen-256color-bce tmux'
