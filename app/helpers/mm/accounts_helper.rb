module Mm::AccountsHelper

  def convert_account_to_json(account)
    label = link_to("#{account.code}： #{account.name}", mm_account_path(account), remote: true)
    
    parts = []
    parts << "{id: #{account.id}, label: '#{label}', children: ["
    account.children.where(deleted: false).each_with_index do |a, i|
      parts << "," if i > 0
      parts << convert_account_to_json(a)
    end
    parts << "]}"

    parts.join.html_safe
  end
  
end
