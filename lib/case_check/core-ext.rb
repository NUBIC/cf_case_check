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
