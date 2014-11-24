class Profile < User

  validates_numericality_of :account_count_of_frequencies, :allow_nil => false, :only_integer => true
  validates_numericality_of :slips_per_page, :allow_nil => false, :only_integer => true

end
