module AccountHelper

  def convert_account_to_json(account)
    label = link_to("#{account.code}： #{account.name}", account_path(account), :remote => true)
    
    ret = "{id: #{account.id}, label: '#{label}', children: ["
    account.children.each_with_index do |a, i|
      ret << "," if i > 0
      ret << convert_account_to_json(a)
    end
    ret << "]}"

    ret.html_safe
  end
  
end
