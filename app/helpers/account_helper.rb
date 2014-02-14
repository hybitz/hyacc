# coding: UTF-8
#
# $Id: account_helper.rb 2989 2013-02-15 06:39:42Z ichy $
# Product: hyacc
# Copyright 2009-2013 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module AccountHelper

  def convert_to_json(account)
    link = link_to "#{account.code}： #{account.name}", account_path(account)
    label = '<div style="margin: 10px 0;">' + link + '</div>'
    
    ret = "{id: #{account.id}, label: '#{label}', children: ["
    account.children.each_with_index do |a, i|
      ret << "," if i > 0
      ret << convert_to_json(a)
    end
    ret << "]}"

    ret.html_safe
  end
  
end
