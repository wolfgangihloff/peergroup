require "bundler/capistrano"

set :application, "peergroup"
set :user, "peergroup"
set :deploy_to, "/var/www/vhosts/kb.ihloff.de/htdocs/peergroup"

set :domain, "s15395856.onlinehome-server.info"
set :rails_env, "production"

role :app, domain
role :web, domain
role :db,  domain, :primary => true

set :scm, :git
set :repository, "git://github.com/wolfgangihloff/peergroup.git"
set :branch, ENV["BRANCH"] || "master"
set :deploy_via, :remote_cache
set :use_sudo, false

# variables for bundler gem
set :bundle_without, [:development, :test]

after "deploy:update_code", "deploy:link"
after "deploy", "deploy:cleanup"

namespace :deploy do
  task :default do
    set :migrate_target, :latest
    update_code
    migrate
    symlink
    node.restart
    apache.restart
  end

  task :restart, :roles => :app, :except => {:no_release => true} do
    apache.restart
  end

  task :link do
    run "ln -nfs #{shared_path}/config/database.yml #{latest_release}/config/database.yml"
    run "ln -nfs #{shared_path}/config/redis.yml #{latest_release}/config/redis.yml"
    run "ln -nfs #{shared_path}/app-node/config.json #{latest_release}/app-node/config.json"
  end

  namespace :apache do
    task :restart do
      run "touch #{File.join(current_path, 'tmp', 'restart.txt')}"
    end
  end

  namespace :node do
    %w(start stop restart).each do |action|
      task action do
        run "/etc/init.d/node-peergroup #{action}"
      end
    end
  end
end
