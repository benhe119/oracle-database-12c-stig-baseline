control 'V-61663' do
  title 'The system must protect audit tools from unauthorized deletion.'
  desc  "Protecting audit data also includes identifying and protecting the
  tools used to view and manipulate log data.

      Depending upon the log format and application, system and application log
  tools may provide the only means to manipulate and manage application and
  system log data.

      It is, therefore, imperative that access to audit tools be controlled and
  protected from unauthorized access.

      Applications providing tools to interface with audit data will leverage
  user permissions and roles identifying the user accessing the tools and the
  corresponding rights the user enjoys in order make access decisions regarding
  the access to audit tools.

      Audit tools include, but are not limited to, OS-provided audit tools,
  vendor-provided audit tools, and open source audit tools needed to successfully
  view and manipulate audit information system activity and records.

      If an attacker were to gain access to audit tools, he could analyze audit
  logs for system weaknesses or weaknesses in the auditing itself.  An attacker
  could also manipulate logs to hide evidence of malicious activity.
  "
  impact 0.5
  tag "gtitle": 'SRG-APP-000123-DB-000204'
  tag "gid": 'V-61663'
  tag "rid": 'SV-76153r1_rule'
  tag "stig_id": 'O121-C2-009800'
  tag "fix_id": 'F-67577r1_fix'
  tag "cci": ['CCI-001495']
  tag "nist": ['AU-9', 'Rev_4']
  tag "false_negatives": nil
  tag "false_positives": nil
  tag "documentable": false
  tag "mitigations": nil
  tag "severity_override_guidance": false
  tag "potential_impacts": nil
  tag "third_party_tools": nil
  tag "mitigation_controls": nil
  tag "responsibility": nil
  tag "ia_controls": nil
  tag "check": "Review access permissions to tools used to view or modify audit
  log data. These tools may include the DBMS itself or tools external to the
  database.

  If appropriate permissions and access controls are not applied to prevent
  unauthorized deletion of these tools, this is a finding."
  tag "fix": "Add or modify access controls and permissions to tools used to
  view or modify audit log data. Only authorized personnel must be able to delete
  these tools."

  sql = oracledb_session(user: attribute('user'), password: attribute('password'), host: attribute('host'), service: attribute('service'), sqlplus_bin: attribute('sqlplus_bin'))

  users_allowed_access_to_audit_info = sql.query("SELECT GRANTEE, TABLE_NAME, PRIVILEGE
      FROM DBA_TAB_PRIVS where owner='AUDSYS';").column('grantee').uniq
  if users_allowed_access_to_audit_info.empty?
    impact 0.0
    describe 'There are no oracle users allowed access to audit information, control N/A' do
      skip 'There are no oracle users allowed access to audit information'
    end
  else
    users_allowed_access_to_audit_info.each do |user|
      describe "oracle users: #{user} allowed access to audit information" do
        subject { user }
        it { should be_in attribute('allowed_audit_users') }
      end
    end
  end
end
