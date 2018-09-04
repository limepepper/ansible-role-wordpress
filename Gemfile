#
# This file was originally generated by ansible. if you run ansible again
# your changes will be lost
#

source 'https://rubygems.org'

# jenkins is remote, so no local paths
if ENV['JENKINS_HOME']
  gem 'inspec', git: 'https://github.com/limepepper/inspec', branch: 'master'
  gem 'kitchen-digitalocean',
      git: 'https://github.com/limepepper/kitchen-digitalocean',
      branch: 'firewall-add'
  gem 'kitchen-inspec'

elsif ENV['DEV_ENV'] == 'TERRAFORM'
  gem 'inspec'
  gem 'kitchen-digitalocean', path: '/home/tomhodder/git/kitchen-digitalocean'
  gem 'kitchen-inspec'
  gem 'kitchen-terraform', path: '/home/tomhodder/git/kitchen-terraform'

elsif ENV['LOCAL_DEV']
  gem 'inspec'
  gem 'kitchen-digitalocean', path: '/home/tomhodder/git/kitchen-digitalocean'
  # gem 'kitchen-inspec', :path => '/home/tomhodder/git/kitchen-inspec'
  gem 'kitchen-inspec'
  gem 'kitchen-vagrant'
  gem 'rubocop'

else
  gem 'inspec'
  gem 'kitchen-digitalocean'
  gem 'kitchen-inspec'
  gem 'kitchen-vagrant'

end

group :testing do
  gem 'kitchen-ansiblepush'
  gem 'net-ssh'
  gem 'test-kitchen', '~> 1.8'
end
