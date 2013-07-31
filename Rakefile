require 'fileutils'

class Installer
  include FileUtils

  attr_accessor :home, :root, :theme, :stdout, :stderr

  def initialize
    self.home   = %x[echo ~].chomp
    self.root   = File.expand_path('..', __FILE__)
    self.theme  = "agnoster2.zsh-theme"
    self.stdout = STDOUT
    self.stderr = STDERR
  end

  def self.run(&block)
    new.instance_eval(&block)
  end

  def log(*messages)
    messages.each { |message| stdout.puts message }
  end

  def link_dirs(names)
    names.each { |name| link "#{root}/#{name}", "#{home}/.#{name}" }
  end

  def link_rcs(names)
    names.each { |name| link "#{home}/.#{name}/#{name}rc", "#{home}/.#{name}rc" }
  end

  def link(source, destination)
    log "linking #{source} to #{destination}..."
    rm destination if File.exist? destination
    ln_sf source, destination
  end

  def run(command)
    log command
    exec command
  end
end

namespace :dotfiles do
  desc "install dotfiles"
  task :install do
    Installer.run do
      log       "Installing into #{home} from #{root}..."

      link_dirs %w[oh-my-zsh zsh vim bin]
      link_rcs  %w[zsh vim]

      mkdir     "#{home}/.oh-my-zsh/custom/themes"

      link      "#{home}/.zsh/#{theme}", "#{home}/.oh-my-zsh/custom/themes/#{theme}"
      link      "#{root}/tmux.conf",     "#{home}/.tmux.conf"

      log       "\n\n Now run `source #{home}/.zshrc`\n\n"
    end
  end
end
