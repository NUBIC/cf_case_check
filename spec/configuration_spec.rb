require 'fileutils'
require File.join(File.dirname(__FILE__), %w[spec_helper])

describe CaseCheck::Configuration do
  before do
    @filename = "/tmp/cf_case_check/config.yml"
  end
  
  after do
    if File.exist?(@filename)
      FileUtils.rm_rf @filename
    end
  end
  
  def config_file(contents)
    FileUtils.mkdir_p File.dirname(@filename)
    File.open(@filename, 'w') { |f| f.write contents }
  end
  
  def read_config
    CaseCheck::Configuration.new(@filename)
  end
  
  it "reads customtag directories" do
    config_file <<-YAML
      customtags:
        - /var/www/customtags
        - /home/cf/customtags
    YAML
    read_config
    CaseCheck::CustomTag.directories.should == %w(/var/www/customtags /home/cf/customtags)
  end
  
  it "resolves relative customtag directories against the config file directory" do
    config_file <<-YAML
      customtags:
        - zappo/customtags
    YAML
    read_config
    CaseCheck::CustomTag.directories.should == %w(/tmp/cf_case_check/zappo/customtags)
  end
end