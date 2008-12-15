module CaseCheck
  
  # Reference as createObject("component", '...')
  class Cfc < Reference
    attr_reader :expected_path, :resolved_to
    
    class << self
      attr_writer :directories
      
      def directories
        @directories ||= []
      end
      
      def search(source)
        source.scan(/createObject\((.*?)\)/mi) do |match, l|
          args = match[1].split(/\s*,\s*/).collect { |a| a.gsub(/['"]/, '') }
          unless args.size == 2 && args.first =~ /component/i
            $stderr.puts "Non-CFC call on line #{l} of #{source.filename}: #{match[0]}"
          end
          new(source, args.last, l)
        end
      end
    end
    
    def initialize(source, text, line_number)
      super
      @expected_path = substituted_text.gsub('.', '/') + ".cfc"
      @resolved_to = search_path.inject(nil) do |resolved, dir|
        resolved || resolve_in(dir)
      end
    end
    
    protected
    
    def search_path
      [File.dirname(source.filename)] + self.class.directories
    end
    
    def case_sensitive_match?
      return true if super
      # According to the CF docs:
      #   "On UNIX systems, ColdFusion searches first for a file with a name
      #    that matches the specified component name, but is all lowercase.
      #    If it does not find the file, it looks for a filename that matches
      #    the component name exactly, with the identical character casing."
      resolved_to.ends_with?(expected_path_tail.downcase)
    end
    
  end

end