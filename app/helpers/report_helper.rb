module ReportHelper
  
  def split_with_br(text)
    text.to_s.chars.join('<br>').html_safe
  end

end
