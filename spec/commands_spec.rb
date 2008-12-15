require File.join(File.dirname(__FILE__), %w[spec_helper])

describe CaseCheck::Params do
  def config_file(filename, contents)
    FileUtils.mkdir_p File.dirname(filename)
    File.open(filename, 'w') { |f| f.write contents }
  end
  
  def actual_params(*argv)
    CaseCheck::Params.new(argv.flatten)
  end
  
  describe "--dir directory" do
    before do
      @dirname = "/tmp/cftest"
      FileUtils.mkdir_p @dirname
    end
    
    after do
      FileUtils.rm_rf @dirname
    end
    
    it "makes the directory available" do
      actual = actual_params('--dir', @dirname)
      actual.directory.should == @dirname
    end
    
    it "defaults the directory to the current" do
      actual_params.directory.should == '.'
    end
    
    it "reads the configuration directory/cf_case_check.yml" do
      config_file File.join(@dirname, "cf_case_check.yml"), <<-YAML
        components:
          - /tmp/baz
      YAML
      actual_params('--dir', @dirname)
      CaseCheck::Cfc.directories.should == %w(/tmp/baz)
    end
    
    it "prefers an explicitly named configuration file if both are available" do
      config_file File.join(@dirname, "cf_case_check.yml"), <<-YAML
        components:
          - /tmp/quux
      YAML
      config_file File.join(@dirname, "another.yml"), <<-YAML
        components:
          - /tmp/qurt
      YAML
      actual_params('--dir', @dirname, '--config', File.join(@dirname, 'another.yml'))
      CaseCheck::Cfc.directories.should == %w(/tmp/qurt)
    end
  end
  
  describe "--config filename" do
    before do
      @filename = "/tmp/foo.yml"
      config_file @filename, <<-YAML
        components:
          - /tmp/bar
      YAML
      CaseCheck::Cfc.directories = nil
    end
    
    after do
      FileUtils.rm_rf @filename
    end
    
    it "loads the configuration" do
      actual_params('--config', @filename)
      CaseCheck::Cfc.directories.should == %w(/tmp/bar)
    end
  end
  
  describe "--version" do
    it "prints to configured stderr" do
      CaseCheck.should_receive(:exit)
      actual_params('--version')
      CaseCheck.status_stream.string.should == "cf_case_check #{CaseCheck.version}\n"
    end
  end
  
  describe "--help" do
    it "prints to configured stderr" do
      CaseCheck.should_receive(:exit)
      actual_params('--help')
      CaseCheck.status_stream.string.should include("cf_case_check")
      CaseCheck.status_stream.string.should include("config")
      CaseCheck.status_stream.string.should include("dir")
    end
  end
  
  describe "--verbose" do
    it "sets the verbose flag" do
      actual_params('--verbose').should be_verbose
      actual_params('-v').should be_verbose
    end
    
    it "does not set the verbose flag when omitted" do
      actual_params.should_not be_verbose
    end
  end
end