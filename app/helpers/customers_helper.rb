module CustomersHelper
  
  def render_checkmark(check)
    if check
      image_tag('/images/checkmark.gif', :size=>'16x16')
    end
  end
end
