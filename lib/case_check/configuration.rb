require 'pathname'
require 'yaml'

module CaseCheck

class Configuration
  def initialize(filename)
    @filename = filename
    @doc = YAML.load_file(@filename)
    apply
  end
  
  def [](k)
    @doc[k]
  end
  
  private
  
  def apply
    read_customtag_dirs
  end
  
  def read_customtag_dirs
    dirs = @doc['customtags'] || []
    CustomTagReference.directories = dirs.to_a.collect { |d|
      p = Pathname.new(d)
      if p.absolute?
        p
      else
        Pathname.new(File.dirname(@filename)) + p
      end
    }.collect { |p| p.to_s }
  end
end

end