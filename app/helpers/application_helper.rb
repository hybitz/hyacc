module ApplicationHelper
  include HyaccConstants
  include HyaccViewHelper

  def purified_params
    {
      :account_code => nil
    }
  end

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
    clazz = flash[:is_error_message] ? 'error' : 'notice'
    message = flash[:notice]

    flash.discard :is_error_message
    flash.discard :notice

    if message.present?
      ret = <<-"NOTICE"
        <#{tag} class="#{clazz}" style="margin: #{margin}px;;">
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

  def justify(text)
    span_text = ([' '] + text.chars + [' ']).map{|x| "<span>#{x}</span>" }.join
    raw "<div class=\"justify\">#{span_text}</div>"
  end

  # メニュー項目のスタイルを取得する
  def style_for_menu(c)
    # 簡易入力の場合
    if controller_name == 'simple_slips'
      if @account.code == c
        'selected'
      end
    # 通常のコントローラの場合
    elsif controller_path == c
      'selected'
    # サブメニューがある場合
    elsif c.is_a? Array and c.include?(controller_path)
      'selected'
    end
  end

  # アクション項目のスタイルを取得する
  def style_for_action(a)
    if action_name.to_s == a
      'selected'
    else
      ''
    end
  end

  # <title>タグを表示する
  def render_title(options = {})
    @title = options.fetch(:title, @title)
    render 'common/title'
  end

  # <meta>タグを表示する
  def render_meta(options = {})
    only = options[:only]
    if only.nil? or only.include? controller.action_name
      render 'common/meta'
    end
  end

  # ヘッダーを表示する
  def render_header(options={})
    render 'common/header'
  end

  # メニューを表示する
  def render_menu(options={})
    render 'common/menu'
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
  def render_account_details(account_id, locals = {})
    renderer = AccountDetails::AccountDetailRenderer.get_instance(account_id)
    if renderer
      render renderer.get_template(controller.controller_name), locals
    else
      render plain: ''
    end
  end

end
