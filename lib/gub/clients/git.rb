require 'open3'

module Gub
  class Git
    attr_accessor :default_options
    
    def sync remote
      self.checkout('master')
      self.fetch(remote)
      self.merge("#{remote}/master")
      self.push('origin', '--all')
    end
    
    def remotes
      `git remote -v | grep fetch | awk '{print $2}' | cut -d ':' -f 2`.split("\n").split(' ').map(&:chop)
    end
    
    # Due to clone being a Ruby magic method, we have to override it
    def clone repo, *args
      self.run('clone', repo, *args)
    end
    
    def method_missing meth, *args, &block
      self.run(meth, *args)
    end
    
    
    def run command, *args
      command = command.to_s
      default_options = []
      default_options << '-q'
      cmd = []
      cmd << 'git'
      cmd << command
      if args.any?
        arguments = args
        unless ['clone', 'remote', 'checkout'].include?(command)
          arguments = arguments.zip(default_options).flatten!
        end
        cmd << arguments.join(' ').to_s
      end
      cmd_line = cmd.join(' ')
      Gub.log.debug "Running git command: #{cmd_line}"
      out = `#{cmd_line}`.split("\n").map(&:strip)
      out
    end
  end
end