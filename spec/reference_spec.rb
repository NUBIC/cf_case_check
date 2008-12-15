require 'fileutils'

require File.join(File.dirname(__FILE__), %w[spec_helper])

describe CaseCheck::Reference do
  class SampleReference < CaseCheck::Reference
    attr_accessor :expected_path, :resolved_to
    
    def initialize(expected_path, resolved_to, line=0, text=nil)
      self.expected_path = expected_path
      self.resolved_to = resolved_to
      self.line = line
      self.text = text
    end
  end
  
  describe 'default resolution' do
    it 'is exact when resolved_to ends with expected_path' do
      SampleReference.new("/foo/patient.cfm", "/home/cfcode/apps/notis/foo/patient.cfm").resolution.should == :exact
    end
  
    it 'is exact when resolved_to ends with expected_path, disregarding ../.' do
      SampleReference.new(".././foo/patient.cfm", "/home/cfcode/apps/notis/foo/patient.cfm").resolution.should == :exact
    end
  
    it 'is case sensitive when resolved_to ends with something else' do
      SampleReference.new("/foo/Patient.cfm", "/home/cfcode/apps/notis/foo/patient.cfm").resolution.should == :case_insensitive
    end
  
    it 'is unresolved without resolved_to' do
      SampleReference.new("/foo/patient.cfm", nil).resolution.should be_nil
    end
  end
  
  describe "text substitution" do
    it "has none by default" do
      CaseCheck::Reference.substitutions.should == []
    end
    
    it "subs in the first matching option" do
      CaseCheck::Reference.substitutions << [/#application#/i, 'foo'] << [/#app.*?#/i, 'bar']
      SampleReference.new(nil, nil, 0, "#application#/quux").substituted_text.should == "foo/quux"
    end
    
    it "returns the original text if there are no matching subs" do
      SampleReference.new(nil, nil, 0, "#application#/quux").substituted_text.should == "#application#/quux"
    end
  end
  
  describe 'default message' do
    it "indicates when it is unresolved" do
      SampleReference.new("/foo/patient.cfm", nil, 11, "FOO_Patient").message.should == 
        "Unresolved sample reference on line 11: FOO_Patient"
    end

    it "indicates when it is exactly resolved" do
      SampleReference.new("/foo/patient.cfm", "/home/cfcode/apps/notis/foo/patient.cfm", 11, "foo_patient").message.should == 
        "Exactly resolved sample reference on line 11 from foo_patient to /home/cfcode/apps/notis/foo/patient.cfm"
    end

    it "indicates when it is only case-insensitively resolved" do
      SampleReference.new("/foo/Patient.cfm", "/home/cfcode/apps/notis/foo/patient.cfm", 11, "foo_Patient").message.should == 
        "Case-insensitively resolved sample reference on line 11 from foo_Patient to /home/cfcode/apps/notis/foo/patient.cfm"
    end
  end
end

