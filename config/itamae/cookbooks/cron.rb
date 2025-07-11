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

execute 'merge_cron' do
  command <<~CMD
    grep -v 'rake hyacc:notification' #{hyacc_root}/tmp/current_cron \
    > #{hyacc_root}/tmp/filtered_cron

    cat #{hyacc_root}/tmp/filtered_cron #{hyacc_root}/tmp/hyacc_cron \
    > #{hyacc_root}/tmp/merged_cron
  CMD
end


execute 'install_cron' do
  command "crontab #{hyacc_root}/tmp/merged_cron"
end