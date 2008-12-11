require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe CaseCheck::Cfc do
  before(:each) do
    CaseCheck::Cfc.directories = %w(/tmp/cfc_specs/components)
    @source = create_test_source('/tmp/cfc_specs/theapp/quux.cfm', <<-CFM)
      <cfparam name="url.summaryType">
      <cfparam name="url.patient_id">
      <cfparam name="url.summaryId" default="0">

      <cfscript>
              utilsObj = CreateObject("component","bspore.Utils").init(datasource=application.personnel_db,username=session.netid,userIP=cgi.remote_addr);
              summaryObj = createObject("component","bspore.Summary").init(datasource=application.db,username=session.netid,userIP=cgi.remote_addr);
      </cfscript>
    CFM
  end
  
  after(:each) do
    FileUtils.rm_r '/tmp/cfc_specs'
  end
  
  def actual_search
    CaseCheck::Cfc.search(@source)
  end
  
  it "has a human-readable name" do
    actual_search.first.type_name.should == 'cfc'
  end
  
  it "finds multiple invocations" do
    actual_search.should have(2).references
  end
  
  it "finds lower case createObject style" do
    actual_search.last.expected_path.should == "bspore/Summary.cfc"
  end
  
  it "finds upper case CreateObject style" do
    actual_search.first.expected_path.should == "bspore/Utils.cfc"
  end
  
  it "resolves against an exact match" do
    expected_file = CaseCheck::Cfc.directories.last + "/bspore/Utils.cfc"
    touch expected_file
    actual_search.first.resolved_to.should == expected_file
    actual_search.first.resolution.should == :exact
  end
  
  it "resolves against an all-lowercase match as exact" do
    expected_file = CaseCheck::Cfc.directories.last + "/bspore/utils.cfc"
    touch expected_file
    actual_search.first.resolved_to.should == expected_file
    actual_search.first.resolution.should == :exact
  end
  
  it "resolves against an differently cased version as inexact" do
    expected_file = CaseCheck::Cfc.directories.last + "/BSpore/Utils.cfc"
    touch expected_file
    actual_search.first.resolved_to.should == expected_file
    actual_search.first.resolution.should == :case_insensitive
  end
end
