module Banks
  def bank
    @_bank ||= Bank.first
  end
  
  def valid_bank_params
    {
      :code => '1234',
      :name => 'テスト銀行'
    }
  end
end