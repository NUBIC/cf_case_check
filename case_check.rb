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
end

# Extend File with case-insensitive utility functions
class File
  # Determines if the given filename maps exactly to an existing file, even
  # if the underlying filesystem is case-insensitive
  def self.exists_exactly?(name, base=nil)
    first, rest = File.expand_path(name, '/')[1, name.size].split('/', 2)
    base ||= ''
    actual_files = Dir[File.join(base, '*')]
    candidate = File.join(base, first)
    actual_files.include?(candidate) && (!rest || self.exists_exactly?(rest, candidate))
  end
  
  # Finds the true filename for the file which can be accessed as "name" 
  # case-insensitively
  def self.case_insensitive_canonical_name(name, base=nil)
    first, rest = File.expand_path(name, '/')[1, name.size].split('/', 2)
    base ||= ''
    actual_files = Dir[File.join(base, '*')].collect { |fn| fn[(base.length + 1) .. -1] }
    match =
      if actual_files.include?(first)
        first
      else
        actual_files.detect { |fn| fn.downcase == first.downcase }
      end
    if rest && match
      case_insensitive_canonical_name(rest, File.join(base, match))
    elsif match
      File.join(base, match)
    else
      nil
    end
  end
end