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

もし /^償却方法を変更した時、償却限度額は以下のように自動変更される$/ do |ast_table|
  rows = normalize_table(ast_table)

  current_method = nil

  rows[1..-1].each do |r|
    current_method = r[0] if r[0].present?
    current_limit = r[1]
    new_method = r[2]
    new_limit = r[3]

    select current_method, from: 'asset[depreciation_method]'

    case current_limit
    when "0円"
      fill_in 'asset[depreciation_limit]', with: 0
      current_limit = 0
    when "1円"
      fill_in 'asset[depreciation_limit]', with: 1
      current_limit = 1
    else
      fill_in 'asset[depreciation_limit]', with: 2
      current_limit = 2
    end

    select new_method, from: 'asset[depreciation_method]'

    case new_limit
    when "0円にする"
      assert_equal 0, find("#asset_depreciation_limit").value.to_i
    when "1円にする"
      assert_equal 1, find("#asset_depreciation_limit").value.to_i
    else
      assert_equal current_limit, find("#asset_depreciation_limit").value.to_i
    end
  end
end