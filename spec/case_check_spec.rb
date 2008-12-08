require 'rubygems'
require 'spec'
require 'fileutils'

require File.expand_path('../case_check', File.dirname(__FILE__))

describe ColdFusionSource do
  describe "line_of" do
    def actual_line_of(content, i)
      ColdFusionSource.new("dc", content).line_of(i)
    end
    
    it "is always line 1 for a single line file" do
      actual_line_of("some text", 3).should == 1
    end
    
    it "can find something on the last line" do
      actual_line_of("some\ntext\nhere", 13).should == 3
    end
  end
end

describe File, ' extensions ' do
  before do
    @tmpdir = "/tmp/case_check_spec"
    FileUtils.mkdir_p(File.dirname(@tmpdir))
  end
  
  after do
    FileUtils.rm_rf(@tmpdir)
  end
  
  def touch(filename)
    full = testfile(filename)
    FileUtils.mkdir_p(File.dirname(full))
    File.open(full, 'w') { }
    full
  end
  
  def testfile(filename)
    File.join(@tmpdir, filename)
  end
  
  describe "#exists_exactly?" do
    it "does not include insensitive file matches" do
      touch("some_file")
      File.exists_exactly?(testfile("some_File")).should be_false
    end
    
    it "does not include insensitive directory matches" do
      touch("Bar/quUx")
      File.exists_exactly?(testfile("bAr/quUx")).should be_false
    end
    
    it "does not have a problem with files that don't exist at all" do
      File.exists_exactly?(testfile("nope")).should be_false
    end
    
    it "does match exact file paths" do
      touch("qUuX/foo")
      File.exists_exactly?(testfile("qUuX/foo")).should be_true
    end
  end
  
  describe "#case_insensitive_canonical_name" do
    it "finds exact matches" do
      touch("baz/bar.foo")
      File.case_insensitive_canonical_name(testfile("baz/bar.foo")).should == testfile("baz/bar.foo")
    end
    
    it "finds matches with case-insensitive matching directories" do
      touch("baZ/baR/foo")
      File.case_insensitive_canonical_name(testfile("baz/bar/foo")).should == testfile("baZ/baR/foo")
    end
    
    it "finds matches with case-insensitive matching filenames" do
      touch("baz/bar/fOz")
      File.case_insensitive_canonical_name(testfile("baz/bar/FOZ")).should == testfile("baz/bar/fOz")
    end
    
    it "finds no match for non-existent files" do
      File.case_insensitive_canonical_name(testfile("quux")).should be_nil
    end
    
    it "handles path navigation" do
      touch("baz/bar/foo/quux")
      File.case_insensitive_canonical_name(testfile("baz/bar/quod/../fOO/quux")).should == testfile("baz/bar/foo/quux")
    end
  end
end