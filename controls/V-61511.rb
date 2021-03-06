control 'V-61511' do
  title "Access to DBMS software files and directories must not be granted to
  unauthorized users."
  desc "The DBMS software libraries contain the executables used by the DBMS
  to operate. Unauthorized access to the libraries can result in malicious
  alteration or planting of operational executables. This may in turn jeopardize
  data stored in the DBMS and/or operation of the host system."
  impact 0.5
  tag "gtitle": 'SRG-APP-000516-DB-999900'
  tag "gid": 'V-61511'
  tag "rid": 'SV-76001r1_rule'
  tag "stig_id": 'O121-BP-025400'
  tag "fix_id": 'F-67427r1_fix'
  tag "cci": ['CCI-000366']
  tag "nist": ['CM-6 b', 'Rev_4']
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
  tag "check": "For UNIX Systems:

  log on using the Oracle software owner account and enter the command:

    umask

  If the value returned is 022 or more restrictive, this is not a finding.

  If the value returned is less restrictive than 022, this is a finding.

  The first number sets the mask for user/owner file permissions. The second
  number sets the mask for group file permissions. The third number sets file
  permission mask for other users. The list below shows the available settings:

  0 = read/write/execute
  1 = read/write
  2 = read/execute
  3 = read
  4 = write/execute
  5 = write
  6 = execute
  7 = no permissions

  Setting the umask to 022 effectively sets files for user/owner to read/write,
  group to read and other to read. Directories are set for user/owner to
  read/write/execute, group to read/execute and other to read/execute.

  For Windows Systems:
  Review the permissions that control access to the Oracle installation software
  directories (e.g. \\Program Files\\Oracle\\).

  DBA accounts, the DBMS process account, the DBMS software
  installation/maintenance account, SA accounts if access by them is required for
  some operational level of support such as backups, and the host system itself
  require access.

  Compare the access control employed with that documented in the System Security
  Plan.

  If access controls do not match the documented requirement, this is a finding.

  If access controls appear excessive without justification, this is a finding."
  tag "fix": "For UNIX Systems:

  Set the umask of the Oracle software owner account to 022. Determine the shell
  being used for the Oracle software owner account:

    env | grep -i shell

  Startup files for each shell are as follows (located in users $HOME directory):

    C-Shell (CSH) = .cshrc
    Bourne Shell (SH) = .profile
    Korn Shell (KSH) = .kshrc
    TC Shell (TCS) = .tcshrc
    BASH Shell = .bash_profile or .bashrc

  Edit the shell startup file for the account and add or modify the line:

    umask 022

  Log off and logon, then enter the umask command to confirm the setting.

  Note: To effect this change for all Oracle processes, a reboot of the DBMS
  server may be required.

  For Windows Systems:
  Restrict access to the DBMS software libraries to the fewest accounts that
  clearly require access based on job function.

  Document authorized access controls and justify any access grants that do not
  fall under DBA, DBMS process, ownership, or SA accounts."
  umask = command('umask').stdout.strip

  describe 'The system umask' do
    subject { umask }
    it { should be >= '0022' }
  end
end
