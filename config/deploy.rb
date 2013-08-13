require 'rvm/capistrano' # Для работы rvm
require 'bundler/capistrano' # Для работы bundler. При изменении гемов bundler автоматически обновит все гемы на сервере, чтобы они в точности соответствовали гемам разработчика. 

set :application, "tarantula"
set :domain, "192.168.24.181"
role :web, domain
role :app, domain
role :db, domain, :primary => true

set :user, "user"
set :deploy_to, "/home/#{user}/#{application}"
set :use_sudo, false

default_run_options[:pty] = true
default_environment['LD_LIBRARY_PATH'] = "#{ENV["ORACLE_HOME"]}lib"
default_environment['NLS_LANG']='AMERICAN_AMERICA.CL8MSWIN1251'

set :repository, "git@github.com:evgeniy-khatko/tarantula.git"
set :branch, "master"
set :scm, "git"
set :scm_verbose, true
set :deploy_via, :remote_cache # Указание на то, что стоит хранить кеш репозитария локально и с каждым деплоем лишь подтягивать произведенные изменения. Очень актуально для больших и тяжелых репозитариев.

set :app_port, 80

namespace :deploy do
	task(:start) {}
	task(:stop) {}

	desc 'Restart Application'
	task :restart, :roles => :app, :except => { :no_release => true } do
	 run "#{try_sudo} touch #{File.join current_path,'tmp','restart.txt'}"
	end

	desc "Symlinks the database.yml"
	task :symlink_db, :roles => :app do
		run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
	end

	desc "Symlinks the Gemfiles"
	task :symlink_gemfiles, :roles => :app do
		run "ln -nfs #{deploy_to}/shared/Gemfile #{release_path}/Gemfile"
		run "ln -nfs #{deploy_to}/shared/Gemfile.lock #{release_path}/Gemfile.lock"
	end

	task :symlink_reports_folder, :roles => :app do
		run "ln -nfs #{deploy_to}/shared/reports/ #{release_path}/public"
		run "ln -nfs #{deploy_to}/shared/attachment_files/ #{release_path}/attachment_files"
	end

	task :my, :roles => :app do
    run "echo 1"
	end

  task :precompile, :role => :app do
    run "cd #{release_path}/ && RAILS_ENV=production bundle exec rake assets:precompile --trace"
  end
end

after 'deploy:update_code', 'deploy:symlink_db', 'deploy:symlink_reports_folder', 'deploy:precompile'
