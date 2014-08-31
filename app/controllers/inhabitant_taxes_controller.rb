class InhabitantTaxesController < Base::BasicMasterController
  view_attribute :title => '住民税'
  view_attribute :ym_list, :only => :index

  def create
    upload
  end

  # CSVフォーマットからモデル登録用にコンバート
  def make_array(csv_array)
    model_array = []
    model_array << csv_array[0]  # 年月
    model_array << csv_array[1]  # employee_id
    model_array << csv_array[2]  # amount
  end

  def inhabitant_tax_params
    params.require(:inhabitant_tax).permit(:employee_id, :amount)
  end

end
