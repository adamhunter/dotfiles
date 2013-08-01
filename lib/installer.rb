require 'fileutils'

class Installer
  include FileUtils

  attr_accessor :home, :root, :theme, :stdout, :stderr

  def initialize
    self.home   = %x[echo ~].chomp
    self.root   = File.expand_path('../..', __FILE__)
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
    return unless rm_sym destination
    log "linking #{source} to #{destination}..."
    ln_sf source, destination
  end

  def run(command)
    log command
    system command
  end

  def mkdir(dir)
    return if Dir.exists? dir
    log "Creating directory #{dir}..."
    super dir
  end

  def rm_sym(path)
    if !File.exists? path
      log "No such symlink at #{path}, skipping removal"
      true
    elsif File.symlink? path
      log "Removing #{path}..."
      rm path
      true
    else
      log "#{path} is not a symlink, skipping removal..."
      return unless File.symlink? path
      false
    end
  end

  def handle_config_dir
    return unless File.directory? "#{home}/.config"
    link "#{root}/config/powerline", "#{home}/.config/powerline"
  end
end
