require 'fileutils'
require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe CaseCheck::CustomTag do
  before(:each) do
    CaseCheck::CustomTag.directories = %w(/tmp/ctr_specs/customtags)
    CaseCheck::CustomTag.directories.each { |d| FileUtils.mkdir_p d }

    @source = create_test_source("/tmp/ctr_specs/theapp/quux.cfm", <<-CFM)
      <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
      <html>
      <head>
      	<title>Delete Risk Factors</title>
      </head>

      <body>
      		<CFQUERY NAME="DELETEPD" datasource=#application.db#>
      		UPDATE T_BRST_CIGALCHL 
      		SET IS_DELETED = 'Y',
      		CHANGED_DATE = SYSDATE,
      		CHANGED_BY = '#session.netid#',
      		CHANGED_IP= '#cgi.remote_addr#'
      		WHERE PATIENT_ID = #URL.PATIENT_ID#
      		</CFQUERY>

      		<CF_ActivityLog activity_type="DELETE T_BRST_CIGALCHL" target="PATIENT_ID = #URL.PATIENT_ID#">


      <CFOUTPUT>
      <CF_DeleteRecordLog 
      PATIENT_ID=#URL.PATIENT_ID#
      SSN="#URL.SSN#"
      LAST_NAME="#URL.LAST_NAME#"
      FIRST_NAME="#URL.FIRST_NAME#"
      MIDDLE_NAME="#URL.MI#"
      DESCRIPTION="Alcohol & Cigarettes"
      TABLE_NAME="T_BRST_CIGALCHL"
      REVERSED_CODE="PATIENT_ID = #URL.PATIENT_ID#"
      >
      </CFOUTPUT>

      </body>
      </html>

      <SCRIPT LANGUAGE = "JavaScript1.2">
       this.window.close();
      </SCRIPT>
    CFM
  end
  
  after(:each) do
    FileUtils.rm_r '/tmp/ctr_specs'
  end
  
  def actual_search
    CaseCheck::CustomTag.search(@source)
  end
  
  it "has a human-readable name" do
    actual_search.first.type_name.should == 'customtag'
  end
  
  it "translates lower case cf_ style" do
    @source.content = <<-CFM
      <div align="center"><cf_checkuserpermissions groups="Admin"> 
      <input type="submit" name="submit" value="Save" >
      </cf_checkuserpermissions> 
      </div>
    CFM
    
    actual_search.should have(1).reference
    actual_search.first.expected_path.should == "checkuserpermissions.cfm"
  end
  
  it "translates upper case CF_ style" do
    @source.content = %q(<CF_ActivityLog activity_type="INSERT T_BRST_INSURANCE_SELECT" target="INSURANCE_ID=#QID.ID#">)
    
    actual_search.should have(1).reference
    actual_search.first.expected_path.should == "ActivityLog.cfm"
  end
  
  it "terminates correctly for self-closing tags" do
    @source.content = %q(<cf_abc/>and then some)
    actual_search.first.text.should == "cf_abc"
  end
  
  it "finds multiple refs in a single body" do
    actual_search.should have(2).references
    actual_search.first.expected_path.should == "ActivityLog.cfm"
    actual_search.last.expected_path.should == "DeleteRecordLog.cfm"
  end
  
  it "records the line number for each match" do
    actual_search.should have(2).references
    actual_search.first.line.should == 17
    actual_search.last.line.should == 21
  end
  
  it "records the text for each match" do
    actual_search.should have(2).references
    actual_search.first.text.should == "CF_ActivityLog"
    actual_search.last.text.should == "CF_DeleteRecordLog"
  end
  
  it "resolves nothing if file not found" do
    actual_search.first.resolved_to.should be_nil
    actual_search.first.resolution.should be_nil
  end
  
  it "resolves an exactly matching file in the same directory as the source if it exists" do
    expected_file = "/tmp/ctr_specs/theapp/ActivityLog.cfm"
    FileUtils.touch expected_file
    actual_search.first.resolved_to.should == expected_file
    actual_search.first.resolution.should == :exact
  end
  
  it "resolves the case-insensitive equivalent in the same directory as the source if it exists" do
    expected_file = "/tmp/ctr_specs/theapp/ActivityLOG.cfm"
    FileUtils.touch expected_file
    actual_search.first.resolved_to.should == expected_file
    actual_search.first.resolution.should == :case_insensitive
  end
  
  it "resolves the exact file from one of the customtag directories if it exists" do
    expected_file = CaseCheck::CustomTag.directories.last + "/ActivityLog.cfm"
    FileUtils.touch expected_file
    actual_search.first.resolved_to.should == expected_file
    actual_search.first.resolution.should == :exact
  end
  
  it "resolves the case-insensitive equivalent from one of the customtag directories if it exists" do
    expected_file = CaseCheck::CustomTag.directories.last + "/activitylog.cFM"
    FileUtils.touch expected_file
    actual_search.first.resolved_to.should == expected_file
    actual_search.first.resolution.should == :case_insensitive
  end
end