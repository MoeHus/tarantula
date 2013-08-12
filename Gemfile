source "http://rubygems.org"

gem 'rails', '~> 3.2.6'
gem 'mysql2'
gem 'prawn', '~> 0.5.0.1'
gem 'prawn-core', '~> 0.5.0.1', :require => 'prawn/core'
gem 'prawn-layout', '~> 0.2.0.1', :require => 'prawn/layout'
gem 'prawn-format', '~> 0.2.0.1', :require => 'prawn/format'
gem 'spreadsheet', '~> 0.6.5'
gem 'libxml-ruby', :require => 'libxml_ruby'
gem 'faker'
gem 'json'
gem 'rake'
gem 'jquery-rails'
gem 'therubyracer'
gem 'delayed_job_active_record'
gem 'daemons'
gem 'memcache-client'
gem 'rb-readline'
gem 'rubyzip', :require => 'zip/zip'
gem 'passenger'
gem 'odf-report', :git => 'https://github.com/sandrods/odf-report'
# Gems needed only for integration with oracle hosted jira
group :oracle_enabled do
  gem 'activerecord-oracle_enhanced-adapter', '~> 1.4.0'
  gem 'ruby-oci8', '>= 2.0.4' 
end
# Only development gems
group :development do
  gem 'capistrano'
  gem 'rvm-capistrano'
  gem 'git-up'
  gem 'debugger'
  gem 'linecache19', :git => 'git://github.com/mark-moseley/linecache'
  gem 'ruby-debug-base19x', '~> 0.11.30.pre4'
  gem 'ruby-debug19'
  gem 'rack-debug'
end
# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end
