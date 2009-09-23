require File.join(File.dirname(__FILE__), %w[spec_helper])

module CaseCheck

describe ColdfusionSource do
  describe "line_of" do
    def actual_line_of(content, i)
      ColdfusionSource.new("dc", content).line_of(i)
    end
    
    it "is always line 1 for a single line file" do
      actual_line_of("some text", 3).should == 1
    end
    
    it "can find something on the last line" do
      actual_line_of("some\ntext\nhere", 13).should == 3
    end
    
    it "is 1 for character 0" do
      actual_line_of("some text", 0).should == 1
    end
  end
  
  describe "scan" do
    def perform_scan(content, re)
      ColdfusionSource.new("dc", content).scan(re) do |md, l|
        [md[0], l]
      end
    end
    
    it "finds one instance" do
      actual = perform_scan("123 abc", /[a-z]+/)
      actual.should have(1).match
      actual.first.should == ['abc', 1]
    end
    
    it "finds multiple instances" do
      actual = perform_scan("abc def 123 four", /[a-z]+/)
      actual.should have(3).matches
      actual[0].should == ['abc', 1]
      actual[1].should == ['def', 1]
      actual[2].should == ['four', 1]
    end
    
    it "finds instances on multiple lines" do
      actual = perform_scan(<<-TEXT, /[a-z]+/)
        for
        23
        answers
      TEXT
      actual.should have(2).matches
      actual[0].should == ['for', 1]
      actual[1].should == ['answers', 3]
    end
  end
  
  describe "scan for tag" do
    def perform_scan(content, tag)
      ColdfusionSource.new("dc", content).scan_for_tag(tag) do |text, attributes, l|
        { :text => text, :attributes => attributes, :line_number => l }
      end
    end
    
    it "finds a tag with no attributes" do
      actual = perform_scan("text <cfabort>more text", "cfabort")
      actual.should have(1).match
      actual.first[:text].should == "<cfabort>"
      actual.first[:attributes].should == { }
      actual.first[:line_number].should == 1
    end
    
    it "finds an XML-style self-closing tag with no attributes" do
      actual = perform_scan("text <cfabort/>more text", "cfabort")
      actual.should have(1).match
      actual.first[:text].should == "<cfabort/>"
      actual.first[:attributes].should == { }
      actual.first[:line_number].should == 1
    end
    
    it "finds a single-line tag with attributes" do
      actual = perform_scan("and then <cflog text='in the middle'> something happens", 'cflog')
      actual.should have(1).match
      actual.first[:text].should == "<cflog text='in the middle'>"
      actual.first[:attributes].should have(1).attribute
      actual.first[:attributes][:text].should == 'in the middle'
      actual.first[:line_number].should == 1
    end
    
    it "finds a single-line self-closing tag with attributes" do
      actual = perform_scan("and then <cflog text='in the middle'/> something happens", 'cflog')
      actual.should have(1).match
      actual.first[:text].should == "<cflog text='in the middle'/>"
      actual.first[:attributes].should have(1).attribute
      actual.first[:attributes][:text].should == 'in the middle'
      actual.first[:line_number].should == 1
    end
    
    it "finds attributes which are surrounded by single quotes" do
      actual = perform_scan("and then <cflog text='in the middle'/> something happens", 'cflog')
      actual.should have(1).match
      actual.first[:attributes].should have(1).attribute
      actual.first[:attributes][:text].should == 'in the middle'
    end
    
    it "finds attributes which are surrounded by double quotes" do
      actual = perform_scan(%q(and then <cflog text="in the middle"/> something happens), 'cflog')
      actual.should have(1).match
      actual.first[:attributes].should have(1).attribute
      actual.first[:attributes][:text].should == 'in the middle'
    end
    
    it "finds multiple tags" do
      actual = perform_scan(<<-CFM, "cfparam")
        <cfparam name="foo" default="42">
        <cfparam name="bar" default="11">
      CFM
      actual.should have(2).matches
      actual[0][:attributes].should == { :name => 'foo', :default => '42' }
      actual[1][:attributes].should == { :name => 'bar', :default => '11' }
      actual[1][:line_number].should == 2
    end
    
    it "finds tags that are spread over multiple lines" do
      actual = perform_scan(<<-CFM, "cfmodule")
        <html>
        <title>
          <cfmodule
            name="whatever"
            >
        </title></html>
      CFM
      actual.should have(1).match
      actual.first[:attributes].should == { :name => 'whatever' }
    end
    
    it "is flexible about whitespace around '='" do
      actual = perform_scan(<<-CFM, "cfparam")
        <cfparam name ="foo" default= "42">
        <cfparam name="bar" default = "11">
        <cfparam name= baz default = 19>
      CFM
      actual.should have(3).matches
      actual[0][:attributes].should == { :name => 'foo', :default => '42' }
      actual[1][:attributes].should == { :name => 'bar', :default => '11' }
      actual[2][:attributes].should == { :name => 'baz', :default => '19' }
    end
    
    it "matches unquoted attributes" do
      actual = perform_scan(<<-CFM, "cfinclude")
        <cfinclude template=GetAccountIDStringMatch.cfm >
        <cfinclude template=alpha option=beta>
      CFM
      actual.should have(2).matches
      actual[0][:attributes].should == { :template => 'GetAccountIDStringMatch.cfm' }
      actual[1][:attributes].should == { :template => 'alpha', :option => 'beta' }
    end
    
    it "downcases attribute keys" do
      actual = perform_scan(%q(<cfabort NOW='later'>), 'cfabort')
      actual.first[:attributes].keys.should include(:now)
    end
    
    it "matches tags without regard to case" do
      actual = perform_scan(%q(Time to go <CFABORT/>), 'cfAbort')
      actual.should have(1).matches
      actual.first[:text].should == '<CFABORT/>'
    end
  end
end

end # module

