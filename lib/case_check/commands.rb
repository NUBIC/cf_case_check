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
        
        opts.on("-v", "--verbose", "Show all references, including the ones which can be resolved exactly.") do |v|
          @options.verbose = true
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
    
    def verbose?
      @options.verbose
    end
    
    private
    
    def read_config!
      @configuration = 
        if File.exist?(configuration_file)
          Configuration.new(configuration_file)
        end
    end
  end
  
  class Checker
    def initialize(params)
      @params = params
      CaseCheck.status_stream.print "Reading source files "
      @sources = Dir["#{params.directory}/**/*.cf[mc]"].collect do |f|
        CaseCheck.status_stream.print '.'
        ColdfusionSource.create(f)
      end
      CaseCheck.status_stream.puts
      CaseCheck.status_stream.print "Analyzing "
      @sources.each do |s|
        CaseCheck.status_stream.print '.'
        s.analyze
      end
      CaseCheck.status_stream.puts "\n"
    end
    
    def sources
      @sources.reject { |src| @params.verbose? ? src.internal_references.empty? : src.inexact_internal_references.empty? }.
        collect { |src| FilteredSource.new(src, @params.verbose?) }
    end
    
    def reference_count
      sources.inject(0) { |c, s| c + s.internal_references.size }
    end
  end
  
  class FilteredSource
    attr_reader :src
    
    def initialize(source, include_exact_matches)
      @src = source
      @include_exact = include_exact_matches
    end
    
    def internal_references
      @include_exact ? src.internal_references : src.inexact_internal_references
    end
  end
  
end