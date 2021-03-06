require "bundler/capistrano"

set :application, "mdwn.in"
set :repository,  "git://github.com/madx/mdwn.in.git"

set :scm, "git"
set :use_sudo, false

set :deploy_via, :remote_cache
set :ssh_options, { forward_agent: true }

# Set your deploy user and deploy directory
set :user, "YOUR DEPLOY USER"
set :deploy_to, "DEPLOY DIRECTORY"

# Set your server address
role :web, "example.com"
role :db,  "example.com", :primary => true

set :keep_releases, 3
after "deploy:restart", "deploy:cleanup"

set :normalize_asset_timestamps, false

set :unicorn_pid, "#{fetch(:shared_path)}/pids/unicorn.pid"
set :unicorn_sock, "#{fetch(:shared_path)}/sockets/unicorn.sock"
set :unicorn_conf, "#{fetch(:current_path)}/config/unicorn.rb"

set :bundle_flags, "--deployment --quiet --binstubs"

# If you are using rbenv, modify an uncomment the following lines
# set :default_environment, {
#   'PATH' => "SHIMS_PATH:BIN_PATH:$PATH"
# }

# Unicorn control tasks
namespace :deploy do
  task :restart do
    old_pid = run("cat #{unicorn_pid}")
    run "OLD_PID=`cat #{unicorn_pid}`; if [ -f #{unicorn_pid} ]; then kill -USR2 $OLD_PID; sleep 2 ; kill -QUIT $OLD_PID ; else cd #{current_path} && bin/unicorn -c #{unicorn_conf} -E #{rails_env} -D; fi"
  end
  task :start do
    run "cd #{current_path} && bin/unicorn -c #{unicorn_conf} -E #{rails_env} -D"
  end
  task :stop do
    run "if [ -f #{unicorn_pid} ]; then kill -QUIT `cat #{unicorn_pid}`; fi"
  end
end

after 'deploy:update_code' do
  run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  run "ln -nfs #{shared_path}/config/deploy.rb #{release_path}/config/deploy.rb"
  run "ln -nfs #{shared_path}/config/unicorn.rb #{release_path}/config/unicorn.rb"
end
