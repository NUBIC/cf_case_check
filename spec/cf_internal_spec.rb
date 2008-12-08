require 'rubygems'
require 'spec'
require 'fileutils'

require File.expand_path('../case_check', File.dirname(__FILE__))

describe InternalReference do
  class SampleInternalReference < InternalReference
    attr_accessor :expected_path, :resolved_to
    
    def initialize(expected_path, resolved_to)
      self.expected_path = expected_path
      self.resolved_to = resolved_to
    end
  end
  
  describe 'default resolution' do
    it 'is exact when resolved_to ends with expected_path' do
      SampleInternalReference.new("/foo/patient.cfm", "/home/cfcode/apps/notis/foo/patient.cfm").resolution.should == :exact
    end
  
    it 'is case sensitive when resolved_to ends with something else' do
      SampleInternalReference.new("/foo/Patient.cfm", "/home/cfcode/apps/notis/foo/patient.cfm").resolution.should == :case_insensitive
    end
  
    it 'is unresolved without resolved_to' do
      SampleInternalReference.new("/foo/patient.cfm", nil).resolution.should be_nil
    end
  end
end

describe CustomTagReference do
  before do
    CustomTagReference.directories = %w(/tmp/customtags)
    CustomTagReference.directories.each { |d| FileUtils.mkdir_p d }
    @source = ColdFusionSource.new("quux.cfm")

    @source.content = <<-CFM
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
  
  after do
    CustomTagReference.directories.each { |d| FileUtils.rm_r d }
  end
  
  def actual_search
    CustomTagReference.search(@source)
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
  
  it "resolves the exact file if it exists" do
    expected_file = CustomTagReference.directories.last + "/ActivityLog.cfm"
    File.open(expected_file, 'w') { }
    actual_search.first.resolved_to.should == expected_file
    actual_search.first.resolution.should == :exact
  end
  
  it "resolves the case-insensitive equivalent if it exists" do
    expected_file = CustomTagReference.directories.last + "/activitylog.cFM"
    File.open(expected_file, 'w') { }
    actual_search.first.resolved_to.should == expected_file
    actual_search.first.resolution.should == :case_insensitive
  end
end