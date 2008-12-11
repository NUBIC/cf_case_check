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
    read_custom_tag_dirs
    read_cfc_dirs
  end
  
  def read_custom_tag_dirs
    CustomTag.directories = absolutize_directories(@doc['customtags'] || [])
  end
  
  def read_cfc_dirs
    Cfc.directories = absolutize_directories(@doc['components'] || [])
  end
  
  private
  
  def absolutize_directories(dirs)
    dirs.to_a.collect { |d|
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