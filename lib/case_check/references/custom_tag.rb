module CaseCheck
  
  # Reference as cf_name (or CF_name)
  class CustomTag < Reference
    attr_reader :expected_path, :resolved_to

    class << self
      attr_accessor :directories

      def search(source)
        source.scan(/<(CF_(\w+))/i) do |match_data, line_number|
          self.new(source, match_data[1], line_number)
        end
      end
    end

    def initialize(source, text, line)
      super
      @expected_path = text[3, text.size] + ".cfm"
      @resolved_to = resolve
    end

    def type_name
      'customtag'
    end

    private

    def resolve
      [File.dirname(source.filename), self.class.directories].flatten.inject(nil) do |resolved, dir|
        resolved || resolve_in(dir)
      end
    end

    def resolve_in(dir)
      exact_path = File.expand_path(expected_path, dir)
      return exact_path if File.exists_exactly?(exact_path)
      File.case_insensitive_canonical_name(exact_path)
    end
  end
  
end