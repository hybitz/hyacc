module Banks
  def bank
    @_bank ||= Bank.first
  end

  def bank_params
    {
      code: '1111',
      name: 'テスト銀行'
    }
  end

  def invalid_bank_params
    {
      code: '2222',
      name: ''
    }
  end

end
