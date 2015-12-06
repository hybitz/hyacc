class String

  def to_amount_integer
    self.to_ai
  end

  def to_ai
    self.gsub(',', '').to_i
  end

end
