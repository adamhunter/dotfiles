#! /usr/bin/env sh

home=$HOME
root=`pwd`
theme="justbake"
link_dirs=(oh-my-zsh .zsh .vim bin config tmux)
link_rcs=(zsh vim)

if [ ! -x `brew` ] || [ ! -d "${home}/.oh-my-zsh" ]; then
  echo "=== This setup script require homebrew (http://brew.sh) and oh-my-zsh(http://ohmyz.sh) to be installed"
  exit 1
else
  echo "=== Brew and oh-my-zsh installed. Proceeding."
fi

echo "=== Installing into ${home} from ${root}"

if [ ! -d "${home}/.config" ]; then
  echo "=== Creating .config dir in ${home}"
  mkdir "${home}/.config"
fi

echo "=== Linking powerline directory"
ln -s "#{root}/config/powerline", "#{home}/.config/powerline"

for dir in ${link_dirs[@]}; do

 if [ -L "${root}/${dir}" ]; then
   echo "=== Found symlink at ${root}/${dir}...removing"
   rm -rf "${root}/${dir}"
 fi

 echo "=== Linking ${home}/${dir} to ${root}/${dir}"
 ln -s "${home}/${dir} ${root}/${dir}"
done

for dir in ${link_rcs[@]}; do
  echo "=== Linking ${home}/.${dir}/${dir}/.${dir}rc to ${home}/.${dir}rc"
  ln -s "${home}/.${dir}/${dir}/.${dir}rc" "${home}/.${dir}rc"
done

echo "=== Creating directory ${home}/.oh-my-zsh/custom/themes\n"
mkdir -p "${home}/.oh-my-zsh/custom/themes"

echo "=== Linking oh-my-zsh themes from ${home}/.zsh/${theme} to ${home}/.oh-my-zsh/custom/themes/${theme}"
ln -s "${home}/.zsh/${theme}.zsh-theme", "${home}/.oh-my-zsh/custom/themes/${theme}.zsh-theme"

echo "=== Linking tmux config from ${root}/tmux/tmux.conf to${home}/.tmux.conf"
ln -s "${root}/tmux/tmux.conf", "${home}/.tmux.conf"

echo "\n\n Now run `source ${home}/.zshrc`\n\n"
exit 0
