control 'V-61683' do
  title 'Use of external executables must be authorized.'
  desc  "Information systems are capable of providing a wide variety of
  functions and services. Some of the functions and services, provided by
  default, may not be necessary to support essential organizational operations
  (e.g., key missions, functions).

      It is detrimental for applications to provide, or install by default,
  functionality exceeding requirements or mission objectives. Examples include,
  but are not limited to, installing advertising software, demonstrations, or
  browser plugins not related to requirements or providing a wide array of
  functionality not required for the mission.

      Applications must adhere to the principles of least functionality by
  providing only essential capabilities.

      DBMS's may spawn additional external processes to execute procedures that
  are defined in the DBMS, but stored in external host files (external
  procedures). The spawned process used to execute the external procedure may
  operate within a different OS security context than the DBMS and provide
  unauthorized access to the host system.
  "
  impact 0.5
  tag "gtitle": 'SRG-APP-000141-DB-000093'
  tag "gid": 'V-61683'
  tag "rid": 'SV-76173r1_rule'
  tag "stig_id": 'O121-C2-011800'
  tag "fix_id": 'F-67597r1_fix'
  tag "cci": ['CCI-000381']
  tag "nist": ['CM-7 a', 'Rev_4']
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
  tag "check": "Review the database for definitions of application executable
  objects stored external to the database.

  Determine if there are methods to disable use or access, or to remove
  definitions for external executable objects.

  Verify any application executable objects listed are authorized by the ISSO.

  If any are not, this is a finding.

  - - - - -
  To check for external procedures, execute the following query which will
  provide the libraries containing external procedures, the owners of those
  libraries, users that have been granted access to those libraries, and the
  privileges they have been granted.  If there are owners other than the owners
  that Oracle provides, then there may be executable objects stored either in the
  database or external to the database that are called by objects in the
  database. Check to see that those owners are authorized to access those
  libraries. If there are users that have been granted access to libraries
  provided by Oracle, check to see that they are authorized to access those
  libraries.

  (connect as sysdba)
  set linesize 130
  column library_name format a25
  column name format a15
  column owner format a15
  column grantee format a15
  column privilege format a15
  select library_name,owner,  '' grantee, '' privilege
  from dba_libraries where file_spec is not null
  minus
  (
  select library_name,o.name owner,  '' grantee, '' privilege
    from dba_libraries l,
         sys.user$ o,
         sys.user$ ge,
         sys.obj$ obj,
         sys.objauth$ oa
   where l.owner=o.name
     and obj.owner#=o.user#
     and obj.name=l.library_name
     and oa.obj#=obj.obj#
     and ge.user#=oa.grantee#
     and l.file_spec is not null
  )
  union all
  select library_name,o.name owner, --obj.obj#,oa.privilege#,
         ge.name grantee,
         tpm.name privilege
    from dba_libraries l,
         sys.user$ o,
         sys.user$ ge,
         sys.obj$ obj,
         sys.objauth$ oa,
         sys.table_privilege_map tpm
   where l.owner=o.name
     and obj.owner#=o.user#
     and obj.name=l.library_name
     and oa.obj#=obj.obj#
     and ge.user#=oa.grantee#
     and tpm.privilege=oa.privilege#
     and l.file_spec is not null;
  /"
  tag "fix": "Disable use of or remove any external application executable
  object definitions that are not authorized.

  Revoke privileges granted to users that are not authorized access to external
  applications."

  sql = oracledb_session(user: attribute('user'), password: attribute('password'), host: attribute('host'), service: attribute('service'), sqlplus_bin: attribute('sqlplus_bin'))

  dba_users = sql.query("select library_name,owner,  '' grantee, '' privilege
  from dba_libraries where file_spec is not null
  minus
  (
  select library_name,o.name owner,  '' grantee, '' privilege
    from dba_libraries l,
         sys.user$ o,
         sys.user$ ge,
         sys.obj$ obj,
         sys.objauth$ oa
   where l.owner=o.name
     and obj.owner#=o.user#
     and obj.name=l.library_name
     and oa.obj#=obj.obj#
     and ge.user#=oa.grantee#
     and l.file_spec is not null
  )
  union all
  select library_name,o.name owner, --obj.obj#,oa.privilege#,
         ge.name grantee,
         tpm.name privilege
    from dba_libraries l,
         sys.user$ o,
         sys.user$ ge,
         sys.obj$ obj,
         sys.objauth$ oa,
         sys.table_privilege_map tpm
   where l.owner=o.name
     and obj.owner#=o.user#
     and obj.name=l.library_name
     and oa.obj#=obj.obj#
     and ge.user#=oa.grantee#
     and tpm.privilege=oa.privilege#
     and l.file_spec is not null;").column('owner').uniq
  if dba_users.empty?
    impact 0.0
    describe 'There are no oracle DBA users, control N/A' do
      skip 'There are no oracle DBA users, control N/A'
    end
  else
    dba_users.each do |user|
      describe "oracle DBA users: #{user}" do
        subject { user }
        it { should be_in attribute('allowed_dbadmin_users') }
      end
    end
  end
end
