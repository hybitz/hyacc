前提 /^資産の編集画面を表示している$/ do
  visit '/bs'
  click_on '減価償却'
  assert page.has_selector?('table#asset_container')
  capture
  click_on '編集'
  assert wait_until { has_selector?("div.ui-dialog", visible: true) }
  assert has_selector?("span.ui-dialog-title", text: /減価償却　編集/)
ensure
  capture
end

もし /^資産管理の減価償却をクリックする$/ do
  click_on '資産管理'
  click_on '減価償却'
end

ならば /^減価償却の一覧に遷移する$/ do
  assert has_title?('減価償却')
  assert_url '/bs/assets$'
end


もし /^償却方法を変更した時、償却限度額は以下のようにリセットされる$/ do |ast_table|
  rows = normalize_table(ast_table)
  rows.shift
  details = []
  rows.each do |r|
    details << r
  end
  
  details.each do |d|
    current_method = d[0]
    current_limit = d[1]
    new_method = d[2]
    new_limit = d[3]

    case current_limit
    when "1円"
      select current_method, from: 'asset[depreciation_method]'
      fill_in 'asset[depreciation_limit]', with: 1
      current_limit = 1
    when "1円以外", "0円以外"
      select current_method, from: 'asset[depreciation_method]'
      fill_in 'asset[depreciation_limit]', with: 10
      current_limit = 10
    when "0円(リセット有)"
      select "定率法", from: 'asset[depreciation_method]'
      fill_in 'asset[depreciation_limit]', with: 1
      select "一括償却", from: 'asset[depreciation_method]'
    when "0円(リセット無)"
      select "定率法", from: 'asset[depreciation_method]'
      fill_in 'asset[depreciation_limit]', with: 0
      select "一括償却", from: 'asset[depreciation_method]'
      current_limit = 0
    end

    select new_method, from: 'asset[depreciation_method]'

    case new_limit
    when "0円"
      assert_equal 0, find("#asset_depreciation_limit").value.to_i
    when "1円"
      assert_equal 1, find("#asset_depreciation_limit").value.to_i 
    when "元のまま"
      assert_equal current_limit, find("#asset_depreciation_limit").value.to_i
    end
  end
end