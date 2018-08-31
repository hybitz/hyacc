module SlipTypes
  include HyaccConstants

  def slip_types
    case slip_type_selection.to_i
    when 1
      [SLIP_TYPE_TRANSFER]
    when 2
      [SLIP_TYPE_TRANSFER, SLIP_TYPE_SIMPLIFIED]
    when 3
      [SLIP_TYPE_TRANSFER, SLIP_TYPE_SIMPLIFIED, SLIP_TYPE_AUTO_TRANSFER_PAYROLL]
    else
      []
    end
  end

end
