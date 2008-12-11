# Models of various sorts of file references within CF code

require 'rubygems'
require 'activesupport'

module CaseCheck

# base class
class Reference < Struct.new(:source, :text, :line)
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
  
  def message
    start = 
      case resolution
      when :exact
        "Exactly resolved"
      when :case_insensitive
        "Case-insensitively resolved"
      else
        "Unresolved"
      end
    msg = "#{start} #{type_name} on line #{line}"
    if resolution
      "#{msg} from #{text} to #{resolved_to}"
    else
      "#{msg}: #{text}"
    end
  end
  
  def type_name
    self.class.name.split('::').last.underscore.gsub('_', ' ')
  end
  
  protected
  
  def case_sensitive_match?
    tail = expected_path.split('/').reject { |pe| pe == '.' }.join('/').gsub(%r((\.\./)+), '')
    resolved_to[-1 * tail.size, tail.size] == tail
  end

  def resolve_in(dir)
    File.case_insensitive_canonical_name(File.expand_path(expected_path, dir))
  end
end

end # module CaseCheck

CaseCheck.require_all_libs_relative_to(__FILE__, 'references')
