module BooleanUtils

  def self.to_b(value)
    return true if value == true
    return true if value.to_s.strip =~ /^(true|yes|y|1)$/i
    false
  end

end
