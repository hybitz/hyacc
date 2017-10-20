class String

  def to_amount_integer
    self.to_ai
  end

  def to_ai
    self.gsub(',', '').to_i
  end

end

class Integer

  def to_amount_string
    self.to_as
  end

  def to_as
    ret = []
    self.to_s.reverse.chars.each_with_index do |char, i|
      ret << ',' if i > 0 && i % 3 == 0
      ret << char
    end
    ret.reverse.join
  end

end