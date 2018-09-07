# val_user = attribute('user', default: 'alice', description: 'An identification for the user')
# array of sites/strings to test, passed in from .kitchen.yml
url_endpoints = attribute('url_endpoints', description: 'Urls / strings to search')

# my_services = yaml(content: inspec.profile.file('services.yml')).params
vars_json = json('/var/cache/ansible/attributes/hostvars.json')

vars = vars_json.params

control 'check-attributes' do
  impact 0.6
  title "Check attribtues for node: #{vars['ansible_hostname']}"
  desc '      Checking the hostvars cache is sensible  '
  describe file('/var/cache/ansible/attributes/hostvars.json') do
    it { should exist }
    #  its('mode') { should cmp 0644 }
  end
end

#                           _            _            _
#     __ _ _ __   __ _  ___| |__   ___  | |_ ___  ___| |_ ___
#    / _` | '_ \ / _` |/ __| '_ \ / _ \ | __/ _ \/ __| __/ __|
#   | (_| | |_) | (_| | (__| | | |  __/ | ||  __/\__ \ |_\__ \
#    \__,_| .__/ \__,_|\___|_| |_|\___|  \__\___||___/\__|___/
#         |_|

control 'check-apache' do
  impact 0.6
  title "Check apache for node: #{vars['ansible_hostname']}"
  desc "   Prevent unexpected settings.
    #{vars['wp_db_user']}
    #{vars['wp_db_pass']}
    #{vars['wp_db_host']}
  "

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
# test we are redirecting
# describe http("http://#{vars['site']}/some_non_existing_file", enable_remote_worker: true) do
#   its('status') { should cmp 301 }
# end

# #its('body') { should cmp 'pong' }

# Test the block of url_endpoints provided

control 'wp_sites-checks-1' do
  impact 0.6
  title 'wp_sites URL Checks'

  describe file('/tmp') do
    it { should be_directory }
  end

  # describe(vars['wp_sites']) do
  #   it { should match 'xxx' }
  # end

  vars['wp_sites_local'].each do |wp_site|
    describe(wp_site['url']) do
      it { should_not match 'xxx' }
    end

    describe(wp_site['url'].to_s.empty?) do
      it { should_not eq true }
    end

    # describe http(wp_site['url'].to_s, enable_remote_worker: true) do
    #   its('body') { should match(/Hello/) }
    # end

    # describe http(wp_site['url'].to_s, enable_remote_worker: false) do
    #   its('body') { should match(/Hello/) }
    # end

    # this creates a url to the local apache, using the external ipv4
    localurl = "#{wp_site['url_parsed']['scheme']}://#{vars['ansible_default_ipv4']['address']}"

    # extract this value, and set it into the Host header of the request
    host_header = wp_site['url_parsed']['hostname']

    describe(host_header) do
      it { should_not eq '' }
    end

    describe(localurl) do
      it { should_not eq '' }
    end

    describe http(localurl,
                  headers: { 'Host' => host_header }) do
      its('body') { should match(/Hello/) }
    end

    describe(wp_site['theme']) do
      it { should_not eq 'grgr22' }
    end

    theme = wp_site['theme']

    # themstyleurl = localurl + '/wp-content/themes/' + 'just-pink/style.css'
    themstyleur2 = localurl + '/wp-content/themes/' + theme + '/style.css'
    themstyleur3 = localurl + '/wp-content/themes/' + wp_site['theme'] + '/style.css'

    # describe(localurl.encoding) do
    #   it { should_not eq 'grgr22' }
    # end

    # describe(theme.encoding) do
    #   it { should_not eq 'grgr22' }
    # end

    # describe(wp_site['theme'].encoding) do
    #   it { should_not eq 'grgr22' }
    # end

    # describe(themstyleurl.encoding) do
    #   it { should_not eq 'grgr22' }
    # end

    # describe(themstyleur3.encoding) do
    #   it { should_not eq 'grgr22' }
    # end

    # describe(themstyleur2.encoding) do
    #   it { should_not eq 'grgr22' }
    # end

    # describe(themstyleurl) do
    #   it { should_not eq 'grgr22' }
    # end

    # describe http(themstyleurl,
    #       enable_remote_worker: true,
    #       headers: {'Host' => host_header}) do
    #   # its('body') { should match(/Hello/) }
    #   its('status') { should eq 200 }
    # end

    describe http(themstyleur2,
                  headers: { 'Host' => host_header }) do
      # its('body') { should match(/Hello/) }
      its('status') { should eq 200 }
    end

    describe http(themstyleur3,
                  headers: { 'Host' => host_header }) do
      # its('body') { should match(/Hello/) }
      its('status') { should eq 200 }
    end
  end
end

control 'site-url-endpoint-checks-1' do
  impact 0.6
  title 'Site URL Checks'

  if url_endpoints
    url_endpoints.each do |urlobj|
      # raise "string must exist" unless urlobj['string']
      # raise "Site must exist" unless urlobj['site']

      # describe command('php -v') do
      #   its('exit_status') { should eq 1 }
      # end

      describe(urlobj['site']).to_s.empty? do
        it { should_not eq true }
      end

      describe(urlobj['string']).to_s.empty? do
        it { should_not eq true }
      end

      # describe urlobj do
      #   its('fetch("string")') { should_not eq '' }
      # end

      describe http((urlobj['site']).to_s, enable_remote_worker: true) do
        its('body') { should match(/#{urlobj['string']}/) }
      end
    end
  end
end

control 'site-as-configured-check-1' do
  impact 0.6
  title 'Check the generated sites'

  if vars_json && vars_json.wp_site_persist
    vars_json.wp_site_persist.each do |wp_site|
      describe(wp_site['web_servername']).to_s.empty? do
        it { should_not eq true }
      end

      describe wp_site['web_servername'] do
        it { should_not be_nil }
        it { should_not be_empty }
      end

      describe wp_site['web_docroot'] do
        it { should_not be_nil }
        it { should_not be_empty }
      end

      describe wp_site['wp_db_user'] do
        it { should_not be_nil }
        it { should_not be_empty }
      end

      describe wp_site['wp_db_pass'] do
        it { should_not be_nil }
        it { should_not be_empty }
      end

      describe wp_site['wp_db_host'] do
        it { should_not be_nil }
        it { should_not be_empty }
      end

      describe wp_site['wp_db_name'] do
        it { should_not be_nil }
        it { should_not be_empty }
      end
      # describe (urlobj['string']).to_s.empty? do
      #   it { should_not eq true }
      # end

      describe file((wp_site['web_docroot']).to_s) do
        it { should exist }
        it { should be_directory }
        #  its('mode') { should cmp 0644 }
      end

      describe http("http://#{wp_site['web_servername']}/feed/", enable_remote_worker: true) do
        its('status') { should cmp 200 }
        its('body') { should match(%r{<title>.*<\/title>}) }
        its('body') { should match(%r{<pubDate>.*<\/pubDate>}) }
        its('headers.Content-Type') { should match %r{application\/rss\+xml} }
      end

      sql = mysql_session(wp_site['wp_db_user'], wp_site['wp_db_pass'], wp_site['wp_db_host'])

      describe sql.query("show databases like '#{wp_site['wp_db_name']}';"), :sensitive do
        its('stdout') { should match(/#{wp_site['wp_db_name']}/) }
      end

      describe sql.query("show tables in #{wp_site['wp_db_name']};"), :sensitive do
        its('exit_status') { should eq(0) }
      end

      describe sql.query("show tables in #{wp_site['wp_db_name']};"), :sensitive do
        its('stdout') { should match(/wp_term_relationships/) }
      end
      # SELECT option_name FROM `role_wordpress11`.`wp_options` WHERE option_name = 'image_default_size';
      describe sql.query("SELECT option_name FROM #{wp_site['wp_db_name']}.wp_options WHERE option_name = 'image_default_size';") do
        its('stdout') { should include 'image_default_size' }
        # its('stdout') { should include 'admin  localhost' }
        # its('stdout') { should include 'user  %' }
        # its('stdout') { should include 'user  localhost' }
      end
    end
  end
end

#                              _   _            _
#    _ __ ___  _   _ ___  __ _| | | |_ ___  ___| |_ ___
#   | '_ ` _ \| | | / __|/ _` | | | __/ _ \/ __| __/ __|
#   | | | | | | |_| \__ \ (_| | | | ||  __/\__ \ |_\__ \
#   |_| |_| |_|\__, |___/\__, |_|  \__\___||___/\__|___/
#              |___/        |_|

# https://www.inspec.io/docs/reference/resources/mysql_session/

control 'mysql-1' do
  impact 0.6
  title 'MySQL Checks'
  desc 'check mysql stuff'

  describe service(vars['mysql_service_name']) do
    it { should be_enabled }
    it { should be_installed }
    it { should be_running }
  end

  describe port(3306) do
    it { should be_listening }
  end
end
