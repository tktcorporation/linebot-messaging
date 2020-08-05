lock '3.11.0'

set :application, 'linebot-messaging'
set :repo_url, 'git@github.com:tktcorporation/linebot-messaging.git'
# set :user, 'centos'
set :user, 'user'
set :use_sudo, false
set :pty, true
# set :staging, :production
set :keep_releases, 2

set :deploy_to, "/var/www/linebot-messaging"

set :log_level, :debug

# puma の設定
set :puma_threads,    [4, 16]
set :puma_workers,    0
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.access.log"
set :puma_error_log,  "#{release_path}/log/puma.error.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true

# rbenv の設定
set :rbenv_type, :user
set :rbenv_ruby, File.read('.ruby-version').strip
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w[rake gem bundle ruby rails puma pumactl]

# シンボリックリンク貼る系（dir）
set :linked_dirs, fetch(:linked_dirs, []).push(
  'log',
  'tmp/pids',
  'tmp/cache',
  'tmp/sockets',
  'vendor/bundle',
  'public/system',
  'public/uploads',
  'node_modules'
)
# シンボリックリンク貼る系（file）
set :linked_files, fetch(:linked_files, []).push(
  'config/master.key',
  '.env'
)

#set :npm_flags, "--prefer-offline --production --no-progress"
#set :npm_roles, :app

#set :yarn_flags, "--prefer-offline --production --no-progress"
#set :yarn_roles, :app

# pumaの追加タスク
namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end
  before :start, :make_dirs
end

# デプロイ用の追加タスク
namespace :deploy do
  desc 'Make sure local git is in sync with remote.'
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  desc 'reload the database with seed data'
  task :seed do
    on roles(:db) do
      with rails_env: fetch(:rails_env) do
        within release_path do
          execute :bundle, :exec, :rake, 'db:seed'
        end
      end
    end
  end

  before :starting,     :check_revision
  before :check,        'setup:config'
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  after  :migrate,      :seed

end

namespace :setup do
  desc 'setup config'
  task :config do
    on roles(:app) do |host|
      # rails5.2以前だとmaster.keyではなくて、secret.ymlになるはずです。
      %w[master.key].each do |f|
        upload! "config/#{f}", "#{shared_path}/config/#{f}"
      end

      # %w[.env].each do |f|
      #   upload! "#{f}", "#{shared_path}/#{f}"
      # end
    end
  end

  desc 'setup nginx'
  task :nginx do
    on roles(:app) do |host|
      # 後ほど作成するnginxのファイル名を記述してください
      %w[Rails.application.credentials.dig(:nginx, :conf_file_name)].each do |f|
        upload! "config/#{f}", "#{shared_path}/config/#{f}"
        sudo :cp, "#{shared_path}/config/#{f}", "/etc/nginx/conf.d/#{f}"
        sudo "nginx -s reload"
      end
    end
  end
end


# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
# set :ssh_options, {
#     keys: %w(~/.ssh/example.pem),
#     auth_methods: %w(public_key)
# }
# ssh_command = 'ssh centos@0.0.0.0 -W %h:%p'
# set :ssh_options, proxy: Net::SSH::Proxy::Command.new(ssh_command)
# namespace :deploy do
#   task :restart do
#     invoke 'unicorn:restart'
#   end
# end
# after 'deploy:publishing', 'deploy:restart'

# set :unicorn_pid, "/var/tmp/unicorn.pid"
# set :unicorn_config_path, "/var/www/linebot-messaging/current/config/unicorn/production/unicorn.rb"
# set :unicorn_rack_env, "production"

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
