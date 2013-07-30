require 'fileutils'

class Installer
  include FileUtils
  methods = %w[cd pwd mkdir mkdir_p rmdir ln ln_s ln_sf cp cp_r mv rm rm_r rm_rf install chmod chmod_R chown chown_R touch]
  methods.each do |method|
    class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def #{method}(*args)
        log "#{method} \#{args.map(&:inspect).join(', ')}"
        super
      end
    RUBY
  end

  attr_accessor :home, :root, :stdout, :stderr

  def initialize
    self.home   = %x[echo ~].chomp
    self.root   = File.expand_path('..', __FILE__)
    self.stdout = STDOUT
    self.stderr = STDERR
  end

  def self.run(&block)
    new.instance_eval(&block)
  end

  def log(*messages)
    messages.each { |message| stdout.puts message }
  end

  def link_dir(*names)
    names.each { |name| ln_s "#{root}/#{name}", "#{home}/.#{name}", force: true }
  end

  def link_rc(*names)
    names.each { |name| ln_s "#{home}/.#{name}/#{name}rc", "#{home}/.#{name}rc", force: true }
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
      log      "Installing into #{home} from #{root}..."
      link_dir *%w[oh-my-zsh zsh vim]
      link_rc  *%w[zsh vim]
      log      "run `source #{home}/.zshrc`"
    end
  end
end
