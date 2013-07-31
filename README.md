dotfiles
========

Installing the dotfiles will remove any conflicting .zshrc .vimrc directories.
It will try to remove .zsh and .vim but will fail unless they are symlinks.

```zsh
git clone --recursive git@github.com:adamhunter/dotfiles.git
cd dotfiles
rake dotfiles:install
```
