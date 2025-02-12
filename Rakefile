$:.unshift File.expand_path('../lib', __FILE__)
require 'installer'

namespace :dotfiles do
  desc "install dotfiles"
  task :install do
    Installer.run do
      log       "Installing into #{home} from #{root}..."

      link_dirs %w[oh-my-zsh zsh vim bin tmux]
      link_rcs  %w[zsh vim]

      mkdir     "#{home}/.oh-my-zsh/custom/themes"
      mkdir     "#{home}/.config/nvim"

      link      "#{home}/.zsh/#{theme}", "#{home}/.oh-my-zsh/custom/themes/#{theme}"
      link      "#{root}/tmux/tmux.conf",     "#{home}/.tmux.conf"
      link      "#{root}/nvim/init.vim",      "#{home}/.config/nvim/init.vim"

      log       "\n\n Now run `source #{home}/.zshrc`\n\n"
    end
  end
end

