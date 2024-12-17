require 'application_system_test_case'

class UpdateDepreciationLimitTest < ApplicationSystemTestCase

  def setup
    sign_in User.second
    Employee.first.update!(user_id: 2)
  end

  def test_定率法から一括償却へ変更した場合に償却限度額が1円であれば0円に自動変換される
    visit bs_assets_path
    click_on "編集"
    within(".ui-dialog") do
      assert_equal DEPRECIATION_METHOD_FIXED_RATE, page.find("#asset_depreciation_method").value.to_i
      assert_equal 1, page.find("#asset_depreciation_limit").value.to_i
      select '一括償却', from: 'asset[depreciation_method]'
      assert_equal 0, page.find("#asset_depreciation_limit").value.to_i
      click_on '更新'
    end

    click_on '編集'
    within(".ui-dialog") do
      assert_equal DEPRECIATION_METHOD_LUMP, page.find("#asset_depreciation_method").value.to_i
      assert_equal 0, page.find("#asset_depreciation_limit").value.to_i
      click_on '閉じる'
    end
  end

  def test_定率法から一括償却へ変更した場合に償却限度額が1円以外であれば自動変換されない
    Asset.first.update!(depreciation_limit: 2)

    visit bs_assets_path
    click_on "編集"
    within(".ui-dialog") do
      assert_equal DEPRECIATION_METHOD_FIXED_RATE, page.find("#asset_depreciation_method").value.to_i
      assert_equal 2, page.find("#asset_depreciation_limit").value.to_i
      select '一括償却', from: 'asset[depreciation_method]'
      assert_equal 2, page.find("#asset_depreciation_limit").value.to_i
      click_on '更新'
    end

    click_on '編集'
    within(".ui-dialog") do
      assert_equal DEPRECIATION_METHOD_LUMP, page.find("#asset_depreciation_method").value.to_i
      assert_equal 2, page.find("#asset_depreciation_limit").value.to_i
      click_on '閉じる'
    end
  end

  def test_定率法のまま償却限度額を1円以外に変更した後に一括償却ヘ変更した場合は自動変換されない
    visit bs_assets_path
    click_on "編集"
    within(".ui-dialog") do
      assert_equal DEPRECIATION_METHOD_FIXED_RATE, page.find("#asset_depreciation_method").value.to_i
      assert_equal 1, page.find("#asset_depreciation_limit").value.to_i

      fill_in 'asset[depreciation_limit]', with: 100
      select '一括償却', from: 'asset[depreciation_method]'
      assert_equal 100, page.find("#asset_depreciation_limit").value.to_i
      click_on '更新'
    end

    click_on '編集'
    within(".ui-dialog") do
      assert_equal DEPRECIATION_METHOD_LUMP, page.find("#asset_depreciation_method").value.to_i
      assert_equal 100, page.find("#asset_depreciation_limit").value.to_i
      click_on '閉じる'
    end
  end

end