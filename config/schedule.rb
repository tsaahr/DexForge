set :output, "log/cron_log.log"

every 10.minutes do
  rake "cleanup:remove_old_wilds"
end
