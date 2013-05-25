# config/unicorn.rb

worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
timeout 30
preload_app true

app_dir = "" # == set this to the deploy_to value in the capistrano recipe

working_directory File.join(app_dir, "current")
shared_path = File.join(app_dir, "shared")

listen "127.0.0.1:3402"
pid "#{shared_path}/pids/unicorn.pid"

stderr_path "#{shared_path}/log/unicorn.stderr.log"
stdout_path "#{shared_path}/log/unicorn.stdout.log"

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts "Unicorn master intercepting TERM and sending myself QUIT instead"
    Process.kill "QUIT", Process.pid
  end

  defined?(DB) and DB.disconnect
end

after_fork do |server, worker|
  Signal.trap "TERM" do
    puts "Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT"
  end
end
