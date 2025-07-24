template "/etc/cron.d/hyacc" do
  source 'templates/hyacc_cron.erb'
  variables(
    hyacc_root: Dir.pwd,
    path: ENV['PATH'],
    rails_env: ENV['RAILS_ENV'] || 'development',
    user: ENV['USER']
  )
  user 'root'
  owner 'root'
  group 'root'
  mode '0644'
end

execute 'restorecon cron file' do
  user 'root'
  command 'restorecon /etc/cron.d/hyacc'
  only_if 'test -f /etc/cron.d/hyacc'
end