require 'csv'

class InhabitantCsv
  
  attr_accessor :kanji_first_name
  attr_accessor :kanji_last_name
  attr_accessor :address
  attr_accessor :amounts
  attr_accessor :csv_string
  attr_accessor :employee_id
  
  def self.load(file, current_company)
    list = []
    linked = true
    CSV.readlines(file.path).each do |row|
      next unless row[5].present?

      model_array = []
      model_array << row[5]  # 漢字氏名
      model_array << row[4]  # 住所
      model_array << row[9..20].join(",")  # 金額
      model_array << row
      ic = new_by_array(model_array, current_company)
      linked = false unless ic.employee_id
      list << ic
    end
    return list, linked
  end
  
  def self.new_by_array(arr, current_company)
    ic = InhabitantCsv.new
    ic.kanji_first_name = arr[0].split(/　/)[1]
    ic.kanji_last_name = arr[0].split(/　/)[0]
    ic.address = arr[1]
    ic.amounts = arr[2]
    ic.csv_string = arr[3]
    ic.employee_id = ic.find_employee_id(current_company)
    ic
  end
  
  def self.create_csv(params)
    inhabitant_csv = params[:inhabitant_csv]
    year = params[:finder][:year]
    next_yaer = (year.to_i + 1).to_s
    return if inhabitant_csv.nil?
    inhabitant_csv.each do |key, value|
      employee_id = value[:employee_id]
      amounts = value[:amounts].split(",")
      ["06","07","08","09","10","11","12","01","02","03","04","05"].each_with_index do |mm, i|
        ym = i <= 6 ? (year + mm).to_i : (next_yaer + mm).to_i
        it = InhabitantTax.where(:ym => ym, :employee_id => employee_id).first
        it = InhabitantTax.new(:ym => ym, :employee_id => employee_id) if it.nil?
        it.amount = amounts[i]
        it.save!
      end
    end
  end
  
  def find_employee_id(current_company)
    e = Employee.where(:last_name => kanji_last_name, :first_name => kanji_first_name, :company_id => current_company.id)
    e.length == 1 ? e[0].id : nil
  end
end
