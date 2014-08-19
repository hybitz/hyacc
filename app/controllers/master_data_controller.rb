class MasterDataController < Base::HyaccController

  # 都道府県一覧を取得する
  def get_prefectures
    @prefectures = super
    render :text=>@prefectures.to_json
  end

end
