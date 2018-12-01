lock '3.11.0'

set :application, 'linebot-messaging-app'
set :repo_url, 'git@github.com:tktcorporation/linebot-messaging-app.git'
set :user, 'centos'
set :linked_dirs, %w(tmp/pids tmp/sockets log node_modules)
set :use_sudo, false
# set :staging, :production
set :keep_releases, 3
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

set :ssh_options, {
    keys: %w(~/.ssh/hassyadai_with_tkt),
    auth_methods: %w(public_key)
}
ssh_command = 'ssh centos@13.113.141.0 -W %h:%p'
set :ssh_options, proxy: Net::SSH::Proxy::Command.new(ssh_command)

namespace :deploy do
  task :restart do
    invoke 'unicorn:restart'
  end
end
after 'deploy:publishing', 'deploy:restart'

set :unicorn_pid, "/var/tmp/unicorn.pid"
set :unicorn_config_path, "/var/www/linebot-messaging/current/config/unicorn/production/unicorn.rb"
set :unicorn_rack_env, "production"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  # after :restart, :clear_cache do
  #   on roles(:web), in: :groups, limit: 3, wait: 10 do
  #     # Here we can do anything such as:
  #     # within release_path do
  #     #   execute :rake, 'cache:clear'
  #     # end
  #   end
  # end

end
