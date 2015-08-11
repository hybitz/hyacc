module Mm::BranchesHelper

  def convert_branch_to_json(branch)
    label = link_to("#{branch.code}： #{branch.name}", mm_branch_path(branch), :remote => true)

    ret = "{id: #{branch.id}, label: '#{label}', children: ["
    ret << branch.children.where(:deleted => false).map{|child| convert_branch_to_json(child) }.join(",\n")
    ret << "]}"
    ret.html_safe
  end
  
end
