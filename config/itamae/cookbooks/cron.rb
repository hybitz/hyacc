hyacc_root = Dir.pwd

execute 'backup_crontab' do
  command "crontab -l > #{hyacc_root}/tmp/current_cron || touch #{hyacc_root}/tmp/current_cron"
end

template "#{hyacc_root}/tmp/hyacc_cron" do
  source 'templates/hyacc_cron.erb'
  variables(
    hyacc_root: hyacc_root,
    rails_env: ENV['RAILS_ENV'] || 'development'
  )
end

template "#{hyacc_root}/tmp/merged_cron" do
  source 'templates/merged_cron.erb'
  variables(hyacc_root: hyacc_root)
end

execute 'install_cron' do
  command "crontab #{hyacc_root}/tmp/merged_cron"
end