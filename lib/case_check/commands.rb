require 'optparse'
require 'ostruct'

module CaseCheck
  
  class Params
    def initialize(argv, name='cf_case_check')
      @options = OpenStruct.new
      
      opts = OptionParser.new do |opts|
        opts.banner = "Usage: #{name} [options]"
        
        opts.on("-d", "--dir DIRECTORY", 
                "The application root from which to search.  Defaults to the current directory.") do |p|
          @options.directory = p
        end
        
        opts.on("-c", "--config CONFIGYAML", 
                "The configuration file which includes the directories to search for custom tags and CFCs.") do |p|
          @options.configfile = p
        end

        opts.on_tail("-h", "--help", "Show this message") do
           CaseCheck.status_stream.puts opts
           CaseCheck.exit
        end
        
        opts.on_tail("--version", "Show version") do
          CaseCheck.status_stream.puts "#{name} #{CaseCheck.version}"
          CaseCheck.exit
        end
      end.parse!(argv)
      
      read_config!
    end
    
    def directory
      @options.directory || '.'
    end
    
    def configuration_file
      @options.configfile || File.join(directory, "cf_case_check.yml")
    end
    
    private
    
    def read_config!
      @configuration = 
        if File.exist?(configuration_file)
          Configuration.new(configuration_file)
        end
    end
  end
  
end