require File.join(File.dirname(__FILE__), %w[spec_helper])

describe CaseCheck::ColdfusionSource do
  describe "line_of" do
    def actual_line_of(content, i)
      CaseCheck::ColdfusionSource.new("dc", content).line_of(i)
    end
    
    it "is always line 1 for a single line file" do
      actual_line_of("some text", 3).should == 1
    end
    
    it "can find something on the last line" do
      actual_line_of("some\ntext\nhere", 13).should == 3
    end
  end
end

