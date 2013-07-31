$:.unshift File.expand_path('../lib', __FILE__)
require 'installer'

namespace :dotfiles do
  desc "install dotfiles"
  task :install do
    Installer.run do
      log       "Installing into #{home} from #{root}..."

      link_dirs %w[oh-my-zsh zsh vim bin python config]
      link_rcs  %w[zsh vim]

      handle_config_dir

      mkdir     "#{home}/.oh-my-zsh/custom/themes"

      link      "#{home}/.zsh/#{theme}", "#{home}/.oh-my-zsh/custom/themes/#{theme}"
      link      "#{root}/tmux.conf",     "#{home}/.tmux.conf"

      log       "Installing powerline..."
      run       "cd lib/powerline && python setup.py install --root=#{home}/.python"

      log       "\n\n Now run `source #{home}/.zshrc`\n\n"
    end
  end
end

