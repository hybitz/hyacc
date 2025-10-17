directory '/var/daddy' do
  user 'root'
  owner ENV['USER']
  group ENV['USER']
end
directory '/var/daddy/tmp'

directory '/data' do
  user 'root'
end
directory '/data/hyacc' do
  user 'root'
  owner ENV['USER']
  group ENV['USER']
end

package 'sqlite-devel' do
  user 'root'
end

include_recipe 'daddy::mysql::client'
include_recipe 'daddy::wkhtmltopdf'
