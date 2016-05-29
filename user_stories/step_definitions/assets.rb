もし /^少額資産として一括償却$/ do
  assert @branch
  assert @asset_code

  with_capture do
    visit_assets(:branch => @branch)
  end

  with_capture do
    find_tr '#asset_container', @asset_code do
      click_on '編集'
    end
    assert has_dialog?
  end

  with_capture do    
    within_dialog do
      select '一括償却', :from => 'asset_depreciation_method'
      fill_in 'asset_depreciation_limit', :with => '0'
      click_on '償却待に設定'
    end
    
    assert has_no_dialog?
    assert has_selector?('.notice')
  end

  with_capture do
    find_tr '#asset_container', @asset_code do
      click_on '編集'
    end
    assert has_dialog?
  end

  with_capture do    
    within_dialog do
      accept_confirm do
        click_on '償却実行'
      end
    end
    
    assert has_no_dialog?
    assert has_selector?('.notice')
  end

  with_capture do
    find_tr '#asset_container', @asset_code do
      click_on '参照'
    end
      
    within_dialog do
      click_on '償却情報を表示'
    end
  end
end
