require 'enumerator'

module CaseCheck

class ColdfusionSource
  attr_accessor :internal_references, :content, :filename
  
  def self.create(filename)
    f = File.expand_path(filename)
    new(f, File.read(f))
  end
  
  def initialize(filename, content = nil)
    @filename = filename
    self.content = content
  end
  
  def analyze
    begin
      [CustomTag, Cfmodule, Cfinclude, Cfc].each do |reftype|
        internal_references.concat reftype.search(self)
      end
    rescue => e
      $stderr.puts "Analyzing #{filename} failed: #{e}"
      e.backtrace.each { |l| $stderr.puts "  #{l}" }
    end
  end
  
  def internal_references
    @internal_references ||= []
  end
  
  def inexact_internal_references
    internal_references.reject { |ir| ir.resolution == :exact }
  end
  
  # returns the line number (1-based) on which the given character index lies
  def line_of(i)
    return nil if i >= content.size
    char_ct = 0
    l = 0
    while char_ct <= i
      char_ct += lines[l].size
      l += 1
    end
    l
  end
  
  def content=(c)
    @lines = nil
    @content = c
  end
  
  def lines
    return @lines if @lines
    @lines = []
    content.split(/(\r\n|\r|\n)/).each_slice(2) { |line_and_br| @lines << line_and_br.join('') }
    @lines
  end
  
  # Scans the content for the given RE, yielding the MatchData for each match
  # and the line number on which it occurred
  def scan(re, &block)
    results = []
    char_offset = 0
    re.scan(content) do |md|
      results << (yield [md, line_of(char_offset + md.begin(0))])
      
      char_offset += md[0].size + md.pre_match.size
      remaining = md.post_match
    end
    results
  end
  
  # Scans the content for opening and/or self-closing tags with the given
  # name. Yields the full text of the tag, a parsed representation of the
  # attributes, and the line number back to the provided block.
  def scan_for_tag(tag, &block)
    scan(/<#{tag}(.*?)>/mi) do |md, l|
      attributes = ['"', "'", nil].collect { |q|
        attribute_re(q).scan(md[1].gsub(%r(/$), ''))
      }.flatten.inject({}) { |attrs, amd|
        attrs[normalize_attribute_key(amd[1])] = amd[2]
        attrs
      }
      yield md[0], attributes, l
    end
  end
  
  def attribute_re(q)
    if q
      /(\w+)\s*=\s*#{q}([^#{q}]*?)#{q}/
    else
      /(\w+)\s*=\s*([^'"\s]+)/
    end
  end
  
  private
  
  def normalize_attribute_key(key)
    key.downcase.to_sym
  end
end

end