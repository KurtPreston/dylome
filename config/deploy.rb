require 'bundler/capistrano'

set :application, "dylome"
set :repository,  "git@github.com:KurtPreston/dylome.git"
set :deploy_to, "/var/www/dylome"

set :scm, :git
set :ssh_options, { :forward_agent => true }

server "tefnut", :app, :web, :db, :primary => true

after "deploy:restart", "deploy:cleanup"

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
