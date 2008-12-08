require 'rubygems'
require 'spec'

require File.expand_path('../case_check', File.dirname(__FILE__))

describe CfInternalReference do
  class SampleInternalReference < CfInternalReference
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
    CustomTagReference.directories = %w(/tmp)
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
  
  it "translates lower case cf_ style" do
    @source.content = <<-CFM
      <div align="center"><cf_checkuserpermissions groups="Admin"> 
      <input type="submit" name="submit" value="Save" >
      </cf_checkuserpermissions> 
      </div>
    CFM
    
    refs = CustomTagReference.search(@source)
    refs.should have(1).reference
    refs.first.expected_path.should == "checkuserpermissions.cfm"
  end
  
  it "translates upper case CF_ style" do
    @source.content = %q(<CF_ActivityLog activity_type="INSERT T_BRST_INSURANCE_SELECT" target="INSURANCE_ID=#QID.ID#">)
    
    refs = CustomTagReference.search(@source)
    refs.should have(1).reference
    refs.first.expected_path.should == "ActivityLog.cfm"
  end
  
  it "terminates correctly for self-closing tags" do
    @source.content = %q(<cf_abc/>and then some)
    CustomTagReference.search(@source).first.text.should == "cf_abc"
  end
  
  it "finds multiple refs in a single body" do
    refs = CustomTagReference.search(@source)
    refs.should have(2).references
    refs.first.expected_path.should == "ActivityLog.cfm"
    refs.last.expected_path.should == "DeleteRecordLog.cfm"
  end
  
  it "records the line number for each match" do
    refs = CustomTagReference.search(@source)
    refs.should have(2).references
    refs.first.line.should == 17
    refs.last.line.should == 21
  end
  
  it "records the text for each match" do
    refs = CustomTagReference.search(@source)
    refs.should have(2).references
    refs.first.text.should == "CF_ActivityLog"
    refs.last.text.should == "CF_DeleteRecordLog"
  end
end