require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe CaseCheck::Cfmodule::Name do
  before(:each) do
    # cfmodule with the name attribute searches in the custom tag directories
    CaseCheck::CustomTag.directories = %w(/tmp/cfmod_specs/customtags)
    CaseCheck::CustomTag.directories.each { |d| FileUtils.mkdir_p d }
    
    @source = create_test_source("/tmp/cfmod_specs/theapp/quux.cfm", <<-CFM)
      <cfsetting showdebugoutput="No" />
      <cfif StructKeyExists(url,'protocol_id') AND StructKeyExists(url,'affiliate_id')>
        <cfif session.theSecurityBaseObj.HasRoleAtAffiliate(Role='TeamLeader',AffiliateID=url.affiliate_id)>
          <cfscript>
            variables.protocolDao = CreateObject('component', '#application.pathToComponents#ProtocolDAO').init(datasource=application.db,
                              username=session.netid,
                                              userIP=cgi.remote_addr);

            variables.protocolDao.updateProtocol(protocolID=url.protocol_id, gcrcNumber=form.value);
          </cfscript>

          <cfoutput>#form.value#</cfoutput>

          <cfmodule name="notis.ActivityLog" type="UPDATE GCRC" target="#url.protocol_id#">
        </cfif>
      </cfif>
    CFM
  end
  
  after(:each) do
    FileUtils.rm_r '/tmp/cfmod_specs'
  end
  
  def actual_search
    CaseCheck::Cfmodule.search(@source)
  end
  
  it "has a human-readable name" do
    actual_search.first.type_name.should == 'cfmodule with name'
  end
  
  it "converts the dotted name into a slashed path" do
    actual_search.first.expected_path.should == "notis/ActivityLog.cfm"
  end
  
  it "resolves against the configured custom tag directories" do
    expected_file = CaseCheck::CustomTag.directories.last + "/notis/ActivityLog.cfm"
    touch expected_file
    actual_search.first.resolved_to.should == expected_file
    actual_search.first.resolution.should == :exact
  end
  
  it "does not resolve against subdirectories of the custom tag directories" do
    expected_file = CaseCheck::CustomTag.directories.last + "/subdir/notis/ActivityLog.cfm"
    touch expected_file
    actual_search.first.resolved_to.should be_nil
  end
  
  it "resolves case-insensitively against the configured custom tag directories" do
    expected_file = CaseCheck::CustomTag.directories.last + "/notis/ActiviTYLog.cfm"
    touch expected_file
    actual_search.first.resolved_to.should == expected_file
    actual_search.first.resolution.should == :case_insensitive
  end
  
  it "finds multiple cfmodule references" do
    @source.content = <<-CFM
      <cfmodule name="etc"/>
      <cfmodule name="etal">
    CFM
    actual_search.should have(2).references
  end
  
  it "finds the cfmodule tag without regard to case" do
    @source.content = <<-CFM
      <cfMODule name="whatever">
    CFM
    actual_search.should have(1).reference
  end
  
  it "performs substitutions before resolving" do
    @source.content = <<-CFM
      <cfmodule name="#application.myroot#whatever">
    CFM
    CaseCheck::Reference.substitutions << [/#application.myroot#/, 'etc.']
    actual_search.first.expected_path.should == 'etc/whatever.cfm'
  end
end

describe CaseCheck::Cfmodule::Template do
  before(:each) do
    @source = create_test_source("/tmp/cfmod_specs/theapp/quux.cfm", <<-CFM)
      <CFOUTPUT>
              <CFIF StoredQueryID GT 0>
              storedqueryid : #StoredQueryID#
                      <CFModule Template="GetTheStoredStatement.cfm" datasource="#tablespace#" QueryName="#StoredQueryName#" 
                              category="#querycategory#"  sq_id=#StoredQueryID#>
                      <CFSET sqlstatement=TheStoredStatement>
              </CFIF>
      </CFOUTPUT>
    CFM
  end
  
  after(:each) do
    FileUtils.rm_r '/tmp/cfmod_specs'
  end
  
  def actual_search
    CaseCheck::Cfmodule.search(@source)
  end
  
  it "has a human-readable name" do
    actual_search.first.type_name.should == 'cfmodule with template'
  end
  
  it "uses the template path as the path" do
    actual_search.first.expected_path.should == "GetTheStoredStatement.cfm"
  end
  
  it "resolves against file directory" do
    expected_file = "/tmp/cfmod_specs/theapp/GetTheStoredStatement.cfm"
    touch expected_file
    actual_search.first.resolved_to.should == expected_file
    actual_search.first.resolution.should == :exact
  end
  
  it "resolves against file directory case-insensitively" do
    expected_file = "/tmp/cfmod_specs/theapp/GetTheSTOREDStatement.cfm"
    touch expected_file
    actual_search.first.resolved_to.should == expected_file
    actual_search.first.resolution.should == :case_insensitive
  end
  
  it "finds multiple cfmodule references" do
    @source.content = <<-CFM
      <cfmodule template="etc"/>
      <cfmodule template="etal">
    CFM
    actual_search.should have(2).references
  end
  
  it "finds the cfmodule tag without regard to case" do
    @source.content = <<-CFM
      <cfMODule template="whatever">
    CFM
    actual_search.should have(1).reference
  end

  
  it "performs substitutions before resolving" do
    @source.content = <<-CFM
      <cfmodule template="#application.somePath#whatever.cfm">
    CFM
    CaseCheck::Reference.substitutions << [/#application.somePath#/, 'etc/']
    actual_search.first.expected_path.should == 'etc/whatever.cfm'
  end
end