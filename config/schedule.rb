 # Example:
 #
require File.expand_path(File.dirname(__FILE__) + "/environment")
#
rails_env = ENV["RAILS_ENV"] || :development
set :environment, rails_env
 # set :output, "/path/to/my/cron_log.log"
set :output, "log/cron.log"
 #
every 20.minutes do
  begin
    runner "Manager.remindcheck_and_push"
  rescue => e
    Rails.logger.error("aborted runner task")
    raise e
  end
end
