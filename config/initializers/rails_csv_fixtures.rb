require 'active_record/fixtures'

module RailsCsvFixtures
  module CsvFixtures

    def read_csv_fixture_files(*args)
      fixtures = fixtures() || {}
      reader = CSV.parse(erb_render(IO.read(csv_file_path(*args))))
      header = reader.shift
      i = 0
      reader.each do |row|
        data = {}
        row.each_with_index do |cell, j|
          next if cell.nil?
          data[header[j].to_s.strip] = cell.to_s.strip
        end
        class_name = (args.second || @class_name)
        fixtures["#{class_name.to_s.underscore}_#{i+=1}"] = ActiveRecord::Fixture.new(data, model_class)
      end
      fixtures
    end

  end
end
