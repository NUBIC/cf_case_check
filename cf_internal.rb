# Models of various sorts of file references within CF code

# base class
class InternalReference < Struct.new(:source, :text, :line)
  # abstract methods
  # - expected_path
  #   returns the exact relative path to which this reference refers
  # - resolved_to
  #   returns the absolute file to which this reference seems to point, if one could be found

  # Returns :exact, :case_insensitive, or nil depending on whether
  # the reference could be resolved on a case_sensitive FS, 
  # only on a case_insensitive FS, or not at all 
  def resolution
    return nil unless resolved_to
    case_sensitive_match? ? :exact : :case_insensitive
  end
  
  protected
  
  def case_sensitive_match?
    resolved_to[-1 * expected_path.size, expected_path.size] == expected_path
  end
end

class Regexp
  # Like String#scan, except that it returns an array of MatchData instead of strings
  # Works incrementally (returning nil) if given a block
  def scan(s)
    data = []
    remaining = s
    while md = self.match(remaining)
      if block_given?
        yield md
      else
        data << md
      end
      remaining = md.post_match
    end
    block_given? ? nil : data
  end
end

class CustomTagReference < InternalReference
  attr_reader :expected_path
  
  class << self
    attr_accessor :directories
    
    def search(source)
      refs = []
      char_offset = 0
      /<(CF_(\w+))/i.scan(source.content) do |md|
        refs << CustomTagReference.new(source, md[1], source.line_of(char_offset + md.begin(0)))
        char_offset += md[0].size + md.pre_match.size
        remaining = md.post_match
      end
      refs
    end
  end
  
  def initialize(source, text, line)
    super
    @expected_path = text[3, text.size] + ".cfm"
  end
end