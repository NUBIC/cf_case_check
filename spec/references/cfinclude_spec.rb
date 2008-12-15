require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe CaseCheck::Cfinclude do
  before(:each) do
    @source = create_test_source("/tmp/cfinc_specs/theapp/quux.cfm", <<-CFM)
      <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN"
            "http://www.w3.org/TR/REC-html40/loose.dtd">
      <HTML>
      <HEAD>
        <TITLE>Pick Permissions Report Options</TITLE>
        <META NAME="generator" CONTENT="BBEdit 5.1.1">

      <CFPARAM NAME="Session.Output_Type" DEFAULT="Browser">

      <cfinclude template="../header_plain.html">
      <h1>Pick Permissions Report Options</h1>

    CFM
  end
  
  after(:each) do
    FileUtils.rm_r '/tmp/cfinc_specs'
  end
  
  def actual_search
    CaseCheck::Cfinclude.search(@source)
  end
  
  it "has a human-readable name" do
    actual_search.first.type_name.should == 'cfinclude'
  end
  
  it "uses the template path as the path" do
    actual_search.first.expected_path.should == "../header_plain.html"
  end
  
  it "resolves against file directory" do
    expected_file = "/tmp/cfinc_specs/header_plain.html"
    touch expected_file
    actual_search.first.resolved_to.should == expected_file
    actual_search.first.resolution.should == :exact
  end
  
  it "resolves against file directory case-insensitively" do
    expected_file = "/tmp/cfinc_specs/headER_plain.html"
    touch expected_file
    actual_search.first.resolved_to.should == expected_file
    actual_search.first.resolution.should == :case_insensitive
  end
  
  it "finds multiple cfincludes" do
    @source.content = <<-CFM
      <cfinclude template="etc"/>
      And then something else happened.
      <cfinclude template="etal">
    CFM
    actual_search.should have(2).references
  end
  
  it "finds the cfinclude tag without regard to case" do
    @source.content = <<-CFM
      <CFInclude template="whatever">
    CFM
    actual_search.should have(1).reference
  end
  
  it "performs substitutions before resolving" do
    @source.content = <<-CFM
      <cfinclude template="#application.myroot#whatever.cfm">
    CFM
    CaseCheck::Reference.substitutions << [/#application.myroot#/, 'etc/']
    actual_search.first.expected_path.should == 'etc/whatever.cfm'
  end
end