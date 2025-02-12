directory '/var/daddy' do
  user 'root'
  owner ENV['USER']
  group ENV['USER']
end
directory '/var/daddy/tmp'

package 'sqlite-devel' do
  user 'root'
end

include_recipe 'daddy::mysql::client'
include_recipe 'daddy::wkhtmltopdf'

case ENV['RAILS_ENV']
when 'production'
  execute 'bundle' do
    command <<-EOF
      bundle config unset without
      bundle config set without 'development test'
      bundle install -j2
    EOF
  end
else
  execute 'bundle' do
    command <<-EOF
      bundle config unset without
      bundle install -j2
    EOF
  end
end
