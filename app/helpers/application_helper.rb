module ApplicationHelper
  include HyaccConstants
  include HyaccViewHelper

  # セレクトボックスに選択肢がない場合、セレクトボックスを非表示にします。
  # ブランクオプションのみの場合も非表示にします。
  def hide_if_no_options(selector)
    ret = <<-"SCRIPT"
      <script>
        $(document).ready(function() {
          var select = $('#{selector}');
          var hide = false;
          if (select.find('option').length == 0) {
            hide = true;
          } else if (select.find('option').length == 1) {
            if (select.find('option').first().attr('value') == '') {
              hide = true; 
            }
          }
          
          if (hide) {
            select.hide();
          } else {
            select.show();
          }
        });
      </script>
    SCRIPT
    ret.html_safe
  end

  def flash_notice(div = true, margin = 10)
    tag = div ? "div" : "span"
    color = flash[:is_error_message] ? "red" : "green"
    message = flash[:notice]

    flash.discard :is_error_message
    flash.discard :notice

    if message.present?
      ret = <<-"NOTICE"
        <#{tag} style="margin: #{margin}px; color: #{color};">
        #{message}
        </#{tag}>
      NOTICE
      ret.html_safe
    else
      ""
    end
  end
  
  def flash_notice_in_span
    flash_notice(false, 0)
  end
  
  # メニュー項目のスタイルを取得する
  def style_for_menu( controller_name )
    # 簡易入力の場合
    if controller.controller_name == 'simple_slip'
      if @account.code == controller_name
        'font-weight: bold; color: slateblue;'
      end
    # 通常のコントローラの場合
    elsif controller.controller_name == controller_name
      'font-weight: bold; color: slateblue;'
    # サブメニューがある場合
    elsif controller_name.is_a? Array and controller_name.any?{|c| c[:name] == controller.controller_name}
      'font-weight: bold; color: slateblue;'
    end
  end  
  
  # アクション項目のスタイルを取得する
  def style_for_action( action_name )
    if action_name.to_s == controller.action_name
      'font-weight: bold; color: slateblue;'
    else
      ''
    end
  end

  # <title>タグを表示する
  def render_title(options = {})
    only = options[:only]
    if only.nil? or only.include? action_name
      render 'common/title', :action_name => (options[:action_name] || action_name)
    end
  end

  # <meta>タグを表示する
  def render_meta(options={})
    only = options[:only]
    if only.nil? or only.include? controller.action_name
      render 'common/meta'
    end
  end

  # ヘッダーを表示する
  def render_header(options={})
    only = options[:only]
    if only.nil? or only.include? controller.action_name
      render 'common/header'
    end
  end
  
  # メニューを表示する
  def render_menu(options={})
    only = options[:only]
    if only.nil? or only.include? controller.action_name
      render 'common/menu'
    end
  end
  
  # アクションメニューを表示する
  def render_action_menu(options={})
    only = options[:only]
    if only.nil? or only.include? controller.action_name
      actions = options[:actions]
      if actions
        render 'common/action_menu', :actions=>options[:actions], :titles=>options[:titles]
      end
    end
  end

  # 勘定科目別の詳細を表示する
  def render_account_details(account_id, options={})
    renderer = AccountDetails::AccountDetailRenderer.get_instance( account_id )
    if renderer
      render renderer.get_template(controller.controller_name), options[:locals]
    else
      render :text=>''
    end
  end

end
