#! /usr/bin/env sh

home="~"
root=`pwd`
theme="justbake"
link_dirs=(oh-my-zsh zsh vim bin config tmux)
link_rcs=(zsh vim)

for dir in ${link_dirs[@]}; do
  link -s "${home}/${dir} ${root}/${dir}"
done

for dir in ${link_rcs[@]}; do
  link -s "${home}/.${dir}/${dir}/${dir}rc" "${home}/${dir}rc"
done

mkdir -p "${home}/.oh-my-zsh/custom/themes"

link -s "${home}/.zsh/${theme}",  "${home}/.oh-my-zsh/custom/themes/${theme}"
link -s "${root}/tmux/tmux.conf", "${home}/.tmux.conf"

echo "\n\n Now run `source ${home}/.zshrc`\n\n"
exit 0
