module CaseCheck
  
  # Reference as <cfmodule name= or <cfmodule template=
  class Cfmodule < Reference
    attr_reader :expected_path, :resolved_to

    class << self
      def search(source)
        source.scan_for_tag('cfmodule') do |text, attributes, line_number|
          if attributes.keys.include?(:name)
            Name.new(source, attributes[:name], line_number)
          elsif attributes.keys.include?(:template)
            Template.new(source, attributes[:template], line_number)
          else
            $stderr.puts "Neither name nor template for cfmodule on line #{line_number} of #{source.filename}"
          end
        end.compact
      end
    end
    
    class Name < Cfmodule
      def initialize(source, text, line)
        super
        @expected_path = text.gsub('.', '/') + ".cfm"
        @resolved_to = CustomTag.directories.inject(nil) do |resolved, dir|
          resolved || resolve_in(dir)
        end
      end
      
      def type_name
        "cfmodule with name"
      end
    end
    
    class Template < Cfmodule
      def initialize(source, text, line)
        super
        @expected_path = text
        @resolved_to = resolve_in(File.dirname(source.filename))
      end
      
      def type_name
        "cfmodule with template"
      end
    end
  end
  
end
