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
