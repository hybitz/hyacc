directory '/var/daddy' do
  user 'root'
  owner ENV['USER']
  group ENV['USER']
end
directory '/var/daddy/tmp'

include_recipe 'daddy::wkhtmltopdf'
