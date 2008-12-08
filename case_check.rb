require 'enumerator'
require File.expand_path('cf_internal', File.dirname(__FILE__))

class ColdFusionSource
  attr_accessor :internal_references, :content, :filename
  
  def self.create(filename)
    f = File.expand_path(filename)
    new(f, File.read(f))
  end
  
  def initialize(filename, content = nil)
    @filename = filename
    self.content = content
  end
  
  def internal_references
    @internal_references ||= []
  end
  
  # returns the line number (1-based) on which the given character index lies
  def line_of(i)
    return nil if i >= content.size
    char_ct = 0
    l = 0
    while char_ct < i
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
  
  private
  
  def analyze
    
  end
end