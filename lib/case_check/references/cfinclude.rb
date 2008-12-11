module CaseCheck
  
  # Reference as <cfinclude template=
  class Cfinclude < Reference
    attr_accessor :expected_path, :resolved_to
    
    def self.search(source)
      source.scan_for_tag('cfinclude') do |text, attributes, line_number|
        new(source, attributes[:template], line_number)
      end
    end

    def initialize(source, text, line)
      super
      @expected_path = text
      @resolved_to = resolve_in(File.dirname(source.filename))
    end
  end
  
end