module Assets
  def valid_asset_params
    {
      :name => '資産' + time_string,
    }
  end
  
  def invalid_asset_params
    {
      :name => '',
    }
  end
  
  def asset
    if @_asset.nil?
      @_asset = Asset.first
      jd = @_asset.journal_detail
      assert_equal 100_000, jd.amount
      assert_equal jd.amount, @_asset.amount
      assert asset.depreciations.clear
    end

    @_asset
  end
end
