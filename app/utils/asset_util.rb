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

  def self.get_assets(jh)
    ret = []

    jh.journal_details.each do |jd|
      ret << jd.asset if jd.asset
    end

    ret
  end

  def self.receipt_edit_only?(jh)
    get_assets(jh).any? {|a| !a.status_created?}
  end

  def self.validate_assets(new_journal, old_journal = nil)
    if old_journal.present?
      if new_journal.present?
        validate_assets_on_update(new_journal, old_journal)
      else
        validate_assets_on_update(nil, old_journal)
      end
    end
  end

  private

  def self.validate_assets_on_update(new_journal, old_journal)
    get_assets(old_journal).each do |a|
      # ステータスが「償却待」以降の資産がある場合はエラー
      unless a.status_created?
        raise HyaccException.new(ERR_CANNOT_CHANGE_ASSET_NOT_STATUS_CREATED)
      end
    end
  end
end
