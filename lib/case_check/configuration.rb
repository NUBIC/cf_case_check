require 'pathname'
require 'yaml'

module CaseCheck

class Configuration
  def initialize(filename)
    @filename = filename
    @doc = YAML.load_file(@filename)
    apply
  end
  
  private
  
  def apply
    read_custom_tag_dirs
    read_cfc_dirs
    read_substitutions
  end
  
  def read_custom_tag_dirs
    CustomTag.directories = absolutize_directories(@doc['custom_tag_directories'] || [])
  end
  
  def read_cfc_dirs
    Cfc.directories = absolutize_directories(@doc['cfc_directories'] || [])
  end
  
  def read_substitutions
    if @doc['substitutions']
      @doc['substitutions'].each_pair do |re, repl|
        CaseCheck::Reference.substitutions << [Regexp.new(re, Regexp::IGNORECASE), repl]
      end
    end
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