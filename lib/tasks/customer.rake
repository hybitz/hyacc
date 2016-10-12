require 'rake'

namespace :hyacc do
  namespace :customer do

    desc '重複した取引先を検索します'
    task :duplicate => :environment do
      Customer.connection.execute('select code from customers group by code having count(*) > 1').each do |array|
        code = array.first
        puts
        puts code

        Customer.where(:code => code).order(:name).each do |c|
          puts c.attributes.slice('id', 'code', 'name').to_yaml
        end

        puts
        puts
      end
    end
  end
end