require 'test_helper'

class AssetTest < ActiveSupport::TestCase
  include HyaccConst
  
  def test_code_required

    # テスト前は正常に保存できることを前提とする
    asset = Asset.find(1)
    assert_nothing_raised{ asset.save! }

    # 未設定は認めない
    asset.code = nil
    assert_raise( ActiveRecord::RecordInvalid ){ asset.save! }
  end
  
  def test_name_required

    # テスト前は正常に保存できることを前提とする
    asset = Asset.find(1)
    assert_nothing_raised{ asset.save! }

    # 未設定は認めない
    asset.name = nil
    assert_raise( ActiveRecord::RecordInvalid ){ asset.save! }
  end
  
  def test_account_id_required

    # テスト前は正常に保存できることを前提とする
    asset = Asset.find(1)
    assert_nothing_raised{ asset.save! }

    # 未設定は認めない
    asset.account_id = nil
    assert_raise( ActiveRecord::RecordInvalid ){ asset.save! }
  end
  
  def test_branch_id_required

    # テスト前は正常に保存できることを前提とする
    asset = Asset.find(1)
    assert_nothing_raised{ asset.save! }

    # 未設定は認めない
    asset.branch_id = nil
    assert_raise( ActiveRecord::RecordInvalid ){ asset.save! }
  end
  
  def test_ym_required

    # テスト前は正常に保存できることを前提とする
    asset = Asset.find(1)
    assert_nothing_raised{ asset.save! }

    # 未設定は認めない
    asset.ym = nil
    assert_raise( ActiveRecord::RecordInvalid ){ asset.save! }
  end
  
  def test_day_required

    # テスト前は正常に保存できることを前提とする
    asset = Asset.find(1)
    assert_nothing_raised{ asset.save! }

    # 未設定は認めない
    asset.day = nil
    assert_raise( ActiveRecord::RecordInvalid ){ asset.save! }
  end
  
  def test_amount

    # テスト前は正常に保存できることを前提とする
    asset = Asset.find(1)
    assert_nothing_raised{ asset.save! }

    # 未設定は認めない
    asset.amount = nil
    assert_raise( ActiveRecord::RecordInvalid ){ asset.save! }
    
    # 0円は認めない
    asset.amount = 0
    assert_raise( ActiveRecord::RecordInvalid ){ asset.save! }
    
    # マイナスは認めない
    asset.amount = -1
    assert_raise( ActiveRecord::RecordInvalid ){ asset.save! }
  end
  
  def test_status_required

    # テスト前は正常に保存できることを前提とする
    asset = Asset.find(1)
    assert_nothing_raised{ asset.save! }

    # 未設定は認めない
    asset.status = nil
    assert_raise( ActiveRecord::RecordInvalid ){ asset.save! }
  end
  
end
