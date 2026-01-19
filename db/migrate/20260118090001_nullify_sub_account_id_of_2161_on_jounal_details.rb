class NullifySubAccountIdOf2161OnJounalDetails < ActiveRecord::Migration[7.2]
  def up
    a = Account.find_by(code: '2161')
    raise '想定している工具器具備品ではありません。' unless a.name == '工具器具備品'
    raise '現在は補助科目が登録されています' unless a.sub_accounts.empty?
    
    JournalDetail.where('account_id = ? and sub_account_id is not null', a.id).update_all(['sub_account_id = ?', nil])
  end

  def down
  end
end
