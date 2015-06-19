ならば /^帳票出力に遷移する$/ do
  assert has_title?('帳票出力')
  assert_url '/report$'
end

ならば /^源泉徴収に遷移する$/ do
  assert has_title?('源泉徴収')
  assert_url '/withholding_slip$'
end

ならば /^給与所得の源泉徴収等の法定調書合計表の一覧に遷移する$/ do
  assert_url '/withholding_slip$'
end

かつ /^「(.*?)」が表示される$/ do |message|
  assert page.has_text?(message)
end
