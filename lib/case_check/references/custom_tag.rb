module CaseCheck
  
  # Reference as cf_name (or CF_name)
  class CustomTag < Reference
    attr_reader :expected_path, :resolved_to

    class << self
      attr_accessor :directories

      def search(source)
        refs = []
        char_offset = 0
        /<(CF_(\w+))/i.scan(source.content) do |md|
          refs << self.new(source, md[1], source.line_of(char_offset + md.begin(0)))
          char_offset += md[0].size + md.pre_match.size
          remaining = md.post_match
        end
        refs
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