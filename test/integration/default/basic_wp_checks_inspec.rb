# my_services = yaml(content: inspec.profile.file('services.yml')).params
vars_json = json('/var/cache/ansible/attributes/hostvars.json')

vars = vars_json.params

control 'check-attributes-1' do
  impact 0.6
  title "Check attribtues for node: #{vars['ansible_hostname']}"
  desc '      Checking the hostvars cache is sensible  '
  describe file('/var/cache/ansible/attributes/hostvars.json') do
    it { should exist }
    # its('mode') { should cmp 0644 }
  end
  describe json('/var/cache/ansible/attributes/hostvars.json') do
    its('ansible_hostname') { should eq vars['ansible_hostname'] }
    # its(['cookbook_locks', 'omnibus', 'version']) { should eq('2.2.0')
  end
end

#   __        ______     ____ _     ___
#   \ \      / /  _ \   / ___| |   |_ _|
#    \ \ /\ / /| |_) | | |   | |    | |
#     \ V  V / |  __/  | |___| |___ | |
#      \_/\_/  |_|      \____|_____|___|
#

control 'wordpress-cli-1' do
  impact 1.0
  title 'check that the wordpress cli is correcly installed'

  describe file('/usr/local/bin/wp') do
    it { should be_file }
  end

  describe command('/usr/local/bin/wp --allow-root ') do
    its('stdout') { should match(/Manage WordPress through the command-line/) }
    its('exit_status') { should eq 0 }
  end
end

#                           _            _            _
#     __ _ _ __   __ _  ___| |__   ___  | |_ ___  ___| |_ ___
#    / _` | '_ \ / _` |/ __| '_ \ / _ \ | __/ _ \/ __| __/ __|
#   | (_| | |_) | (_| | (__| | | |  __/ | ||  __/\__ \ |_\__ \
#    \__,_| .__/ \__,_|\___|_| |_|\___|  \__\___||___/\__|___/
#         |_|

control 'wordpress-apache-1' do
  impact 0.6
  title "Check apache for node: #{vars['ansible_hostname']}"
  desc '   Prevent unexpected settings.  '

  describe service(vars['apache_service']) do
    it { should be_enabled }
    it { should be_installed }
    it { should be_running }
  end

  describe apache do
    its('user') { should eq vars['apache_user'] }
  end

  # describe package('php') do
  #   it { should_not be_installed }
  # end

  describe port(80) do
    it { should be_listening }
  end

  describe file('/tmp') do
    it { should be_directory }
  end

  # describe file('hello.txt') do
  #   its('content') { should match 'Hello World' }
  # end
end

#                              _   _            _
#    _ __ ___  _   _ ___  __ _| | | |_ ___  ___| |_ ___
#   | '_ ` _ \| | | / __|/ _` | | | __/ _ \/ __| __/ __|
#   | | | | | | |_| \__ \ (_| | | | ||  __/\__ \ |_\__ \
#   |_| |_| |_|\__, |___/\__, |_|  \__\___||___/\__|___/
#              |___/        |_|

# https://www.inspec.io/docs/reference/resources/mysql_session/

control 'wordpress-mysql-1' do
  impact 0.6
  title 'MySQL Checks'
  desc '   Prevent unexpected settings.  '
  # mysql_base_package: python2-mysql
  # mysql_python_package: MySQL-python
  # mysql_server_package: mysql-server
  # mysql_service_name: mariadb
  describe service(vars['mysql_service_name']) do
    it { should be_enabled }
    it { should be_installed }
    it { should be_running }
  end

  describe port(3306) do
    it { should be_listening }
  end
end
