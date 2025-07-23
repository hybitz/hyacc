hyacc_root = Dir.pwd

template "#{hyacc_root}/tmp/hyacc_cron" do
  source 'templates/hyacc_cron.erb'
  variables(
    hyacc_root: hyacc_root,
    path: ENV['PATH'],
    rails_env: ENV['RAILS_ENV'] || 'development',
    user: ENV['USER']
  )
  mode '0644'
end

execute 'place /etc/cron.d/hyacc' do
  user 'root'
  command <<-EOF
    set -eu
    cp -f #{hyacc_root}/tmp/hyacc_cron /etc/cron.d/hyacc
    chmod 0644 /etc/cron.d/hyacc
  EOF
  not_if "diff #{hyacc_root}/tmp/hyacc_cron /etc/cron.d/hyacc"
end