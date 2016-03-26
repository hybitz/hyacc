module AssetUtil
  include HyaccErrors
  
  def self.create_asset_code(fiscal_year)
    next_value = Sequence.next_value(Asset, fiscal_year)
    (fiscal_year.to_i * 10000 + next_value).to_s
  end

  def self.clear_asset_from_details(jh)
    jh.journal_details.each do |jd|
      jd.asset = nil
    end
  end

  def get_assets(jh)
    ret = []
    
    jh.journal_details.each do |jd|
      ret << jd.asset if jd.asset
    end
    
    ret
  end
  
  def validate_assets(new_journal, old_journal = nil)
    if old_journal.nil?
      validate_assets_on_create( new_journal )
    elsif new_journal.nil?
      validate_assets_on_delete(old_journal)
    else
      validate_assets_on_update( new_journal, old_journal )
    end
  end
  
  private

  def validate_assets_on_create(new_journal)
  end
  
  def validate_assets_on_update(new_journal, old_journal)
    get_assets(old_journal).each do |a|
      # ステータスが「償却待」以降の資産がある場合はエラー
      unless a.status_created?
        raise HyaccException.new(ERR_CANNOT_CHANGE_ASSET_NOT_STATUS_CREATED)
      end
    end
  end
  
  def validate_assets_on_delete(old_journal)
    validate_assets_on_update(nil, old_journal)
  end
end
