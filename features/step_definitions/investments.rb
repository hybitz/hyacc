# #TODO: テストが不安定なため一時退避
# 前提 /^有価証券の追加ダイアログを開いている$/ do
#   visit '/bs/investments?finder[fiscal_year]=2009&commit=表示'
#   assert wait_until { has_selector?('input[value="表示"]') }
#   capture
#   click_on '表示'
#   assert wait_until { has_selector?('a.add') }
#   capture
#   click_link '新しい取引を追加'
#   assert wait_until { has_dialog?("有価証券 追加") }
#   assert wait_until { has_selector?('#investment_yyyymmdd') }
# end
  
# もし /^取引日フィールドに手動で文字を入力しようとする$/ do
#   assert has_selector?('#investment_yyyymmdd')
#   field = find('#investment_yyyymmdd')
#   field.click
#   field.send_keys('2024-01-01')
# end

# ならば /^入力ができないことを確認する$/ do
#   assert has_selector?('#investment_yyyymmdd')
#   field = find('#investment_yyyymmdd')
#   capture
#   assert_equal '', field.value
# end