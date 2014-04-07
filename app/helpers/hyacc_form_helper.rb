module HyaccFormHelper
  include HyaccViewHelper
  
  def link_to_journal(name, jh)
    link_to(name, {:controller => :journal, :action => :show, :id => jh}, :remote => true)
  end

  def h_account_select(object_name, field_name, options={})
    clazz = options.has_key?(:class) ? options[:class] : 'accountSelect'
    
    html_options = {}
    html_options[:class] = clazz if clazz
    
    collection_select_code_and_name(object_name, field_name, @accounts, "id", "name",
      {:include_blank=>include_blank(options)},
      html_options)
  end
  
  def h_branch_select(object_name, options={})
    collection_select(object_name, "branch_id", @branches, "id", "name",
      {:include_blank=>include_blank(options) },
      {:class=>'branchSelect', :style => options[:style]} )
  end

  def h_dc_type_select(object_name, options={})
    select(object_name, "dc_type", dc_types,
      {:include_blank => include_blank(options) },
      {:class=>'dcTypeSelect'} ) 
  end

  def h_sub_account_select(object_name, options={})
    collection_select(object_name, "sub_account_id", @sub_accounts, "id", "name",
      {:include_blank=>include_blank(options)},
      {:class=>'subAccountSelect', :style => options[:style]})
  end

  def h_tax_type_select(object_name, options={})
    select(object_name, "tax_type", tax_types,
      {:include_blank => include_blank(options) },
      {:class=>'taxTypeSelect'} ) 
  end
  
  def h_amount_field(object_name, options={})
    text_field(object_name, property_name(options, 'amount'), {:class=>'amountText'})
  end

  def collection_select_code_and_name( *args )
    args[4] = :code_and_name
    
    frequencies = args[5][:frequencies] if args.size >= 6
    if frequencies and frequencies.size > 0
      groups = []
      
      # 利用頻度の高い選択肢を抽出
      groups << ['-', []]
      frequencies.each do |f|
        ar = args[2].find{|item| item.id == f.input_value.to_i}
        if ar
          groups[0][1] << [ar.send(args[4]), ar.send(args[3])]
        end
      end
      groups << ['-', []]
      args[2].each do |ar|
        groups[1][1] << [ar.send(args[4]), ar.send(args[3])]
      end
      
      html_options = args[6] if args.length >= 7
      html_options = {} if html_options.nil?
      select(args[0], args[1], grouped_options_for_select(groups, args[5][:selected]), args[5], html_options) 
    else
      collection_select(*args)
    end
  end
  
  private

  def include_blank(options)
    return options[:include_blank] if options.has_key? :include_blank
    false
  end
  
  def hide(options)
    return options[:hide] if options.has_key? :hide
    false
  end

  def property_name(options, default_name)
    return options[:property_name] if options.has_key? :property_name
    default_name
  end
end
