class Journal {
  constructor(selector, options) {
    this.selector = selector;
    this.options = options;
    this._init();
  }

  add_detail(trigger) {
    const tbody = $(trigger).closest('table').find('tbody');

    const params = {
      index: this._get_details().last().data('index') + 1,
      format: 'html'
    };

    $.get(this.options.add_detail_path, params, (html) => {
      tbody.append(html);
    });
  }

  flip_details(show) {
    this._get_details().each((_, el) => {
      if (this._is_deleted(el)) {
        return true;
      }

      const detail = $(el);
      const link = detail.find('.flip_detail_button');

      if (show) {
        this._show_detail(detail);
        this._set_flip_button_state(link, true);
      } else {
        this._hide_detail(detail);
        this._set_flip_button_state(link, false);
      }
    });
  }

  flip_detail(trigger) {
    const detail = this._get_detail(trigger);
    const link = $(trigger);

    if (this._is_detail_shown(detail)) {
      this._hide_detail(detail);
      this._set_flip_button_state(link, false);
    } else {
      this._show_detail(detail);
      this._set_flip_button_state(link, true);
    }
  }

  remove_receipt(trigger) {
    const td = $(trigger).closest('td');
    td.hide();

    const tr = td.closest('tr');
    tr.find('input[name*="\[deleted\]"]').val(true);
    tr.find('input[name*="\[original_filename\]"]').remove();
    tr.find('input.receipt').show();
    tr.find('div.receipt').hide();
  }

  // 自動振替時の日付必須チェック
  _check_auto_journal_dates() {
    const errors = [];

    this._get_details().each((i, el) => {
      if (this._is_deleted(el)) {
        return true;
      }

      if (this._get_auto_journal_type(el) == AUTO_JOURNAL_TYPE_DATE_INPUT_EXPENSE) {
        const year = toInt(this._get_auto_journal_year(el));
        const month = toInt(this._get_auto_journal_month(el));
        const day = toInt(this._get_auto_journal_day(el));

        if (! checkDate(year, month, day)) {
          errors.push(`【明細${i+1}】振替日の指定が不正です。`);
          this._show_detail(el);
        }
      }
    });

    if (errors.length > 0) {
      alert(errors.join('\n'));
      return false;
    }

    return true;
  }

  // 全明細の自動振替の単一選択チェック
  _check_auto_journal_types() {
    const errors = [];

    this._get_details().each((i, el) => {
      if (this._is_deleted(el)) {
        return true;
      }

      let tr = $(el);
      let count = 0;

      for (let j = 0; j < 3; j ++) {
        tr = $(tr).next();
        if ($(tr).find('input[name*="\\[auto_journal_type\\]"]').prop('checked')) {
          count ++;
        }
      }

      if (count > 1) {
        errors.push(`【明細${i+1}】自動振替は複数指定できません。`);
        this._show_detail(el);
      }
    });

    if (errors.length > 0) {
      alert(errors.join('\n'));
      return false;
    }

    return true;
  }

  _get_account_id(detail) {
    return $(detail).find('select[name*="\\[account_id\\]"]').val();
  }

  _get_auto_journal_type(detail) {
    let tr = detail;
    for (let i = 0; i < 3; i ++) {
      tr = $(tr).next();
      const checkbox = $(tr).find('input[name*="\\[auto_journal_type\\]"]');
      const checked = checkbox.prop('checked');
      if (checked) {
        return checkbox.val();
      }
    }

    return null;
  }

  _get_auto_journal_year(detail) {
    const tr = $(detail).next().next().next();
    return $(tr).find('input[name*="\\[auto_journal_year\\]"]').val();
  }

  _get_auto_journal_month(detail) {
    const tr = $(detail).next().next().next();
    return $(tr).find('input[name*="\\[auto_journal_month\\]"]').val();
  }

  _get_auto_journal_day(detail) {
    const tr = $(detail).next().next().next();
    return $(tr).find('input[name*="\\[auto_journal_day\\]"]').val();
  }

  _get_branch_id(detail) {
    return $(detail).find('select[name*="\\[branch_id\\]"]').val();
  }

  _get_dc_type(detail) {
    return $(detail).find('select[name*="\\[dc_type\\]"]').val();
  }

  _get_detail(trigger) {
    return $(trigger).closest('tr[data-detail_id]');
  }

  _get_details() {
    return $(this.selector).find('.journal_details').find('tr[data-detail_id]');
  }

  _get_input_amount(detail) {
    let ret = $(detail).find('input[name*="\\[input_amount\\]"]').val();

    ret = parseInt(ret);
    if (isNaN(ret)) {
      ret = 0;
    }

    return ret;
  }

  _get_next_detail(trigger) {
    const detail = this._get_detail(trigger);
    return detail.next().next().next().next();
  }

  _get_prev_detail(trigger) {
    const detail = this._get_detail(trigger);
    return detail.prev().prev().prev().prev();
  }

  _get_tax_amount(detail) {
    let ret = $(detail).find('input[name*="\\[tax_amount\\]"]').val();

    ret = parseInt(ret);
    if (isNaN(ret)) {
      ret = 0;
    }

    return ret;
  }

  _get_tax_type(detail) {
    return $(detail).find('select[name*="\\[tax_type\\]"]').val();
  }

  _set_tax_type(detail, tax_type) {
    $(detail).find('select[name*="\\[tax_type\\]"]').val(tax_type);
  }

  _hide_detail(detail) {
    $(detail).nextUntil('tr[data-detail_id]').hide();
    if (this._is_deleted(detail)) {
      detail.hide();
    }
  }

  _is_detail_shown(detail) {
    return $(detail).nextUntil('tr[data-detail_id]').filter(':visible').length > 0;
  }

  _set_flip_button_state(link, shown) {
    const hideText = '詳細を隠す';
    const showText = '詳細を表示';
    const text = shown ? hideText : showText;
    $(link).attr('aria-expanded', shown ? 'true' : 'false');
    $(link).attr('title', text);

    const label = $(link).find('.flip_detail_label');
    if (label.length > 0) {
      label.text(text);
    } else {
      // フォールバック（旧マークアップ向け）
      $(link).text(text);
    }
  }

  _init() {
    if (this.options.readonly) {
      this._init_event_handlers();
      $(this.selector).find('input, select').attr('disabled', true);
    } else {
      this._init_shortcut();
      this._init_validation();
      this._init_event_handlers();
      this._init_ym();
      this._refresh_tax_rate_all({visibility_only: true});
      this._refresh_total_amount();
      this.get_day().focus().select();
    }
  }

  _init_event_handlers() {
    this._get_details().each((_, el) => {
      $(el).addClass('sub_account_ready');
    });

    $(this.selector).delegate('select[name*="\\[account_id\\]"]', 'change', (e) => {
      const detail = this._get_detail(e.currentTarget);
      const params = {
        index: detail.data('index'),
        account_id: $(e.currentTarget).val(),
        branch_id: this._get_branch_id(detail),
        dc_type: this._get_dc_type(detail),
        detail_id: detail.data('detail_id'),
        order: 'code',
      };

      detail.removeClass('sub_account_ready');
      $.getJSON(this.options.sub_accounts_path, params, (json) => {
          replace_options(`tr[data-index="${params.index}"] [name*="\\[sub_account_id\\]"]`, json);
          detail.addClass('sub_account_ready');
      });

      $.getJSON(this.options.get_tax_type_path, params, (json) => {
        this._set_tax_type(detail, json.tax_type);
        this._refresh_tax_rate(detail);
      });

      $.get(this.options.get_account_detail_path, params, (html) => {
          $(`#journal_details_${params.index}_account_detail`).html(html);
      });

      this._refresh_allocation(detail);
    })
    .delegate('select[name*="\\[sub_account_id\\]"]', 'change', (e) => {
      const detail = this._get_detail(e.currentTarget);
      const params = {
        index: detail.data('index'),
        account_id: this._get_account_id(detail),
        detail_id: detail.data('detail_id'),
        sub_account_id: $(e.currentTarget).val()
      };
      $.get(this.options.get_sub_account_detail_path, params, (html, _text_status, jq_xhr) => {
        if (jq_xhr.status === 204) {
          return;
        }
        $(`#journal_details_${params.index}_account_detail`).html(html);
      });
    })
    .delegate('[name*="\\[branch_id\\]"]', 'change', (e) => {
      const detail = this._get_detail(e.currentTarget);
      this._refresh_allocation(detail);
    })
    .delegate('[name*="\\[dc_type\\]"]', 'change', (e) => {
      const detail = this._get_detail(e.currentTarget);
      this._refresh_total_amount();
      this._refresh_allocation(detail);
    })
    .delegate('.delete_detail_button', 'click', (e) => {
      this._remove_detail(e.currentTarget);
      this._refresh_total_amount();
      return false;
    })
    .delegate('.flip_detail_button', 'click', (e) => {
      this.flip_detail(e.currentTarget);
      return false;
    })
    .delegate('[name*="\\[input_amount\\]"]', 'change', (e) => {
      this._refresh_tax_amount(e.currentTarget);
    })
    .delegate('[name*="\\[tax_rate_percent\\]"]', 'change', (e) => {
      this._refresh_tax_amount(e.currentTarget);
    })
    .delegate('[name*="\\[tax_type\\]"]', 'change', (e) => {
      this._refresh_tax_rate(e.currentTarget);
    })
    .delegate('[name*="\\[tax_amount\\]"]', 'change', () => {
      this._refresh_total_amount();
    })
    .delegate('[name*="\\[ym\\]"]', 'change', (e) => {
      const val = $(e.currentTarget).val();
      if (val.length === 6) {
        this._refresh_tax_rate_all();
      }
    });
  }

  _init_shortcut() {
    const input_selector = '[name*="\\[input_amount\\]"]';

    Mousetrap.bindGlobal('down', (e) => {
      if ($(e.target).is(input_selector)) {
        e.preventDefault();
        const detail = this._get_detail(e.target);
        this._get_next_detail(detail).find(input_selector).focus().select();
      }
    });

    Mousetrap.bindGlobal('up', (e) => {
      if ($(e.target).is(input_selector)) {
        e.preventDefault();
        const detail = this._get_detail(e.target);
        this._get_prev_detail(detail).find(input_selector).focus().select();
      }
    });
  }

  _init_validation() {
    $(this.selector).submit(() => this._validate_journal());
  }

  _init_ym() {
    this.get_ym().blur((e) => {
      const newYm = hyacc.ym.normalizeYm($(e.target).val());
      if (newYm) {
        $(e.target).val(newYm);
        $(e.target).trigger('change');
      }
    });
  }

  get_day() {
    return $(this.selector).find('input[name*=\\[day\\]]');
  }

  get_ym() {
    return $(this.selector).find('input[name*=\\[ym\\]]');
  }

  _is_deleted(detail) {
    return $(detail).find('input[name*="\\[_destroy\\]"]').val() === 'true';
  }

  _set_deleted(detail, deleted) {
    $(detail).find('input[name*="\\[_destroy\\]"]').val(deleted);
  }

  _refresh_allocation(detail) {
    const params = {
      account_id: this._get_account_id(detail),
      branch_id: this._get_branch_id(detail),
      dc_type: this._get_dc_type(detail),
      index: detail.closest('[data-index]').data('index')
    };

    $.get(this.options.get_allocation_path, params, (html) => {
      $(`#jd_${params.index}_allocation`).html(html);
    });
  }

  _refresh_tax_rate(trigger, options = {}) {
    const detail = $(trigger).closest('tr[data-detail_id]');
    hyacc.tax.setRateField(detail, options);
    this._refresh_tax_amount(trigger, options);
  }

  _refresh_tax_amount(trigger, options = {}) {
    const detail = $(trigger).closest('tr[data-detail_id]');
    const taxAmountField = detail.find('input[name*="\\[tax_amount\\]"]');
    const taxRatePercentField = detail.find('input[name*="\\[tax_rate_percent\\]"]');
    const taxType = this._get_tax_type(detail);

    // 内税／外税の場合は消費税を計算
    if (taxType == tax.INCLUSIVE || taxType == tax.EXCLUSIVE) {
      if (!options.visibility_only) {
        const amount = this._get_input_amount(detail);
        const taxRate = taxRatePercentField.val() * 0.01;

        taxAmountField.val(tax.calcTaxAmount(taxType, taxRate, amount));
      }

      taxAmountField.prop('disabled', false);
    } else {
      taxAmountField.val('').prop('disabled', true);
    }
    this._refresh_total_amount();
  }

  _refresh_tax_rate_all(options) {
    this._get_details().each((_, el) => {
      this._refresh_tax_rate(el, options);
    });
  }

  _refresh_total_amount() {
    let debitAmount = 0;
    let creditAmount = 0;

    this._get_details().each((_, el) => {
      if (this._is_deleted(el)) {
        return true;
      }

      let amount = this._get_input_amount(el);
      const taxAmount = this._get_tax_amount(el);

      const taxType = this._get_tax_type(el);
      if (taxType == tax.EXCLUSIVE) {
        amount += taxAmount;
      }

      $(el).find('.amount_sum').text(toAmount(amount));

      const dcType = this._get_dc_type(el);
      if (dcType == DC_TYPE_DEBIT) {
        debitAmount += amount;
      } else if (dcType == DC_TYPE_CREDIT) {
        creditAmount += amount;
      } else {
        alert('貸借が不正です。');
      }
    });

    $(this.selector).find('.debit_amount_sum').text(toAmount(debitAmount));
    $(this.selector).find('.credit_amount_sum').text(toAmount(creditAmount));
  }

  _remove_detail(trigger) {
    const detail = $(trigger).closest('tr[data-detail_id]');
    this._set_deleted(detail, true);
    this._hide_detail(detail);
  }

  _show_detail(detail) {
    $(detail).nextUntil('tr[data-detail_id]').show();
  }

  _validate_amount() {
    const errors = [];

    this._get_details().each((i, el) => {
      if (this._is_deleted(el)) {
        return true;
      }

      const amount = parseInt($(el).find('input[name*="\\[input_amount\\]"]').val());
      if (isNaN(amount) || amount == 0) {
        errors.push(`${i + 1}行目の金額が未入力です。`);
      }
    });

    if (errors.length > 0) {
      alert(errors.join('\n'));
      return false;
    }

    return true;
  }

  _validate_amount_balance() {
    const debit = $(this.selector).find('.debit_amount_sum').text();
    const credit = $(this.selector).find('.credit_amount_sum').text();

    if (debit != credit) {
      alert(`貸借の金額が一致しません。\n借方: ${debit} != 貸方: ${credit}`);
      return false;
    }

    if (debit == 0 || credit == 0) {
      alert('金額が０円です。');
      return false;
    }

    return true;
  }

  _validate_journal() {
    if (! this._check_auto_journal_types()) {
      return false;
    }

    if (! this._check_auto_journal_dates()) {
      return false;
    }

    if (! this._validate_amount()) {
      return false;
    }

    if (! this._validate_amount_balance()) {
      return false;
    }

    return true;
  }
}

hyacc.Journal = Journal;
