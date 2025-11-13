hyacc.Journal = function(selector, options) {
  this.selector = selector;
  this.options = options;
  this._init();
};

hyacc.Journal.prototype.add_detail = function(trigger) {
  var tbody = $(trigger).closest('table').find('tbody');

  var params = {
    index: this._get_details().last().data('index') + 1,
    format: 'html'
  };

  $.get(this.options.add_detail_path, params, function(html) {
    tbody.append(html);
  });
};

hyacc.Journal.prototype.flip_details = function(show) {
  var that = this;
  this._get_details().each(function() {
    if (that._is_deleted(this)) {
      return true;
    }

    var detail = $(this);
    var link = detail.find('.flip_detail_button');

    if (show) {
      that._show_detail(detail);
      link.text(I18n.t('text.hide_detail'));
    } else {
      that._hide_detail(detail);
      link.text(I18n.t('text.show_detail'));
    }
  });
};

hyacc.Journal.prototype.flip_detail = function(trigger) {
  var detail = this._get_detail(trigger);
  var link = $(trigger);

  if (link.text() == I18n.t('text.hide_detail')) {
    this._hide_detail(detail);
    link.text(I18n.t('text.show_detail'));
  } else {
    this._show_detail(detail);
    link.text(I18n.t('text.hide_detail'));
  }
};

hyacc.Journal.prototype.remove_receipt = function(trigger) {
  var td = $(trigger).closest('td');
  td.hide();

  var tr = td.closest('tr');
  tr.find('input[name*="\[deleted\]"]').val(true);
  tr.find('input[name*="\[original_filename\]"]').remove();
  tr.find('input.receipt').show();
  tr.find('div.receipt').hide();
};

// 自動振替時の日付必須チェック
hyacc.Journal.prototype._check_auto_journal_dates = function() {
  var errors = [];

  var that = this;
  this._get_details().each(function(i) {
    if (that._is_deleted(this)) {
      return true;
    }

    if (that._get_auto_journal_type(this) == AUTO_JOURNAL_TYPE_DATE_INPUT_EXPENSE) {
      var year = toInt(that._get_auto_journal_year(this));
      var month = toInt(that._get_auto_journal_month(this));
      var day = toInt(that._get_auto_journal_day(this));

      if (! checkDate(year, month, day)) {
        errors.push('【明細' + (i+1) + '】振替日の指定が不正です。');
        that._show_detail(this);
      }
    }
  });

  if (errors.length > 0) {
    alert(errors.join('\n'));
    return false;
  }

  return true;
};

// 全明細の自動振替の単一選択チェック
hyacc.Journal.prototype._check_auto_journal_types = function() {
  var errors = [];

  var that = this;
  this._get_details().each(function(i) {
    if (that._is_deleted(this)) {
      return true;
    }

    var tr = $(this);
    var count = 0;

    for (var j = 0; j < 3; j ++) {
      tr = $(tr).next();
      if ($(tr).find('input[name*="\\[auto_journal_type\\]"]').prop('checked')) {
        count ++;
      }
    }

    if (count > 1) {
      errors.push('【明細' + (i+1) + '】自動振替は複数指定できません。');
      that._show_detail(this);
    }
  });

  if (errors.length > 0) {
    alert(errors.join('\n'));
    return false;
  }

  return true;
};

hyacc.Journal.prototype._get_account_id = function(detail) {
  return $(detail).find('select[name*="\\[account_id\\]"]').val();
};

hyacc.Journal.prototype._get_auto_journal_type = function(detail) {
  var tr = detail;
  for (var i = 0; i < 3; i ++) {
    var tr = $(tr).next();
    var checkbox = $(tr).find('input[name*="\\[auto_journal_type\\]"]');
    var checked = checkbox.prop('checked');
    if (checked) {
      return checkbox.val();
    }
  }

  return null;
};

hyacc.Journal.prototype._get_auto_journal_year = function(detail) {
  var tr = $(detail).next().next().next();
  return $(tr).find('input[name*="\\[auto_journal_year\\]"]').val();
};

hyacc.Journal.prototype._get_auto_journal_month = function(detail) {
  var tr = $(detail).next().next().next();
  return $(tr).find('input[name*="\\[auto_journal_month\\]"]').val();
};

hyacc.Journal.prototype._get_auto_journal_day = function(detail) {
  var tr = $(detail).next().next().next();
  return $(tr).find('input[name*="\\[auto_journal_day\\]"]').val();
};

hyacc.Journal.prototype._get_branch_id = function(detail) {
  return $(detail).find('select[name*="\\[branch_id\\]"]').val();
};

hyacc.Journal.prototype._get_dc_type = function(detail) {
  return $(detail).find('select[name*="\\[dc_type\\]"]').val();
};

hyacc.Journal.prototype._get_detail = function(trigger) {
  return $(trigger).closest('tr[data-detail_id]');
};

hyacc.Journal.prototype._get_details = function() {
  return $(this.selector).find('.journal_details').find('tr[data-detail_id]');
};

hyacc.Journal.prototype._get_input_amount = function(detail) {
  var ret = $(detail).find('input[name*="\\[input_amount\\]"]').val();

  ret = parseInt(ret);
  if (isNaN(ret)) {
    ret = 0;
  }

  return ret;
};

hyacc.Journal.prototype._get_next_detail = function(trigger) {
  var detail = this._get_detail(trigger);
  return detail.next().next().next().next();
};


hyacc.Journal.prototype._get_prev_detail = function(trigger) {
  var detail = this._get_detail(trigger);
  return detail.prev().prev().prev().prev();
};

hyacc.Journal.prototype._get_tax_amount = function(detail) {
  var ret = $(detail).find('input[name*="\\[tax_amount\\]"]').val();

  ret = parseInt(ret);
  if (isNaN(ret)) {
    ret = 0;
  }

  return ret;
};

hyacc.Journal.prototype._get_tax_type = function(detail) {
  return $(detail).find('select[name*="\\[tax_type\\]"]').val();
};

hyacc.Journal.prototype._set_tax_type = function(detail, tax_type) {
  $(detail).find('select[name*="\\[tax_type\\]"]').val(tax_type);
};

hyacc.Journal.prototype._hide_detail = function(detail) {
  $(detail).nextUntil('tr[data-detail_id]').hide();
  if (this._is_deleted(detail)) {
    detail.hide();
  }
};

hyacc.Journal.prototype._init = function() {
  if (this.options.readonly) {
    this._init_event_handlers();
    $(this.selector).find('input, select').attr('disabled', true);
  } else {
    this._init_shortcut();
    this._init_validation();
    this._init_event_handlers();
    this._init_day();
    this._init_ym();
    this._refresh_tax_rate_all({visibility_only: true});
    this._refresh_total_amount();
  }
};

hyacc.Journal.prototype._init_event_handlers = function() {
  var that = this;

  this._get_details().each(function() {
    $(this).addClass('sub_account_ready');
  });

  $(this.selector).delegate('select[name*="\\[account_id\\]"]', 'change', function() {
    var detail = that._get_detail(this);
    var params = {
      index: detail.data('index'),
      account_id: $(this).val(),
      branch_id: that._get_branch_id(detail),
      dc_type: that._get_dc_type(detail),
      detail_id: detail.data('detail_id'),
      order: 'code',
    };

    detail.removeClass('sub_account_ready');
    $.getJSON(that.options.sub_accounts_path, params, function(json) {
        replace_options('tr[data-index="' + params.index + '"] [name*="\\[sub_account_id\\]"]', json);
        detail.addClass('sub_account_ready');
      });

    $.getJSON(that.options.get_tax_type_path, params, function(json) {
      that._set_tax_type(detail, json.tax_type);
      that._refresh_tax_rate(detail);
    });

    $.get(that.options.get_account_detail_path, params, function(html) {
        $('#journal_details_' + params.index + '_account_detail').html(html);
      });

    that._refresh_allocation(detail);
  })
  .delegate('[name*="\\[branch_id\\]"]', 'change', function() {
    var detail = that._get_detail(this);
    that._refresh_allocation(detail);
  })
  .delegate('[name*="\\[dc_type\\]"]', 'change', function() {
    var detail = that._get_detail(this);
    that._refresh_total_amount();
    that._refresh_allocation(detail);
  })
  .delegate('.delete_detail_button', 'click', function() {
    that._remove_detail(this);
    that._refresh_total_amount();
    return false;
  })
  .delegate('.flip_detail_button', 'click', function() {
    that.flip_detail(this);
    return false;
  })
  .delegate('[name*="\\[input_amount\\]"]', 'change', function() {
    that._refresh_tax_amount(this);
  })
  .delegate('[name*="\\[tax_rate_percent\\]"]', 'change', function() {
    that._refresh_tax_amount(this);
  })
  .delegate('[name*="\\[tax_type\\]"]', 'change', function() {
    that._refresh_tax_rate(this);
  })
  .delegate('[name*="\\[tax_amount\\]"]', 'change', function() {
    that._refresh_total_amount();
  })
  .delegate('[name*="\\[ym\\]"]', 'change', function() {
    var val = $(this).val();
    if (val.length === 6) {
      that._refresh_tax_rate_all();
    }
  });
};

hyacc.Journal.prototype._init_shortcut = function() {
  var input_selector = '[name*="\\[input_amount\\]"]';
  var that = this;

  Mousetrap.bindGlobal('down', function(e) {
    if ($(e.target).is(input_selector)) {
      e.preventDefault();
      var detail = that._get_detail(e.target);
      that._get_next_detail(detail).find(input_selector).focus().select();
    }
  });

  Mousetrap.bindGlobal('up', function(e) {
    if ($(e.target).is(input_selector)) {
      e.preventDefault();
      var detail = that._get_detail(e.target);
      that._get_prev_detail(detail).find(input_selector).focus().select();
    }
  });
};

hyacc.Journal.prototype._init_validation = function() {
  var that = this;
  $(this.selector).submit(function() {
    return that._validate_journal();
  });
};

hyacc.Journal.prototype._init_day = function() {
  var that = this;
  Mousetrap.bindGlobal('ctrl+d', function(e) {
    e.preventDefault();
    that.get_day().animate({scrollTop: 0}, 'fast').focus().select();
  });
};

hyacc.Journal.prototype._init_ym = function() {
  var that = this;
  Mousetrap.bindGlobal('ctrl+y', function(e) {
    e.preventDefault();
    that.get_ym().animate({scrollTop: 0}, 'fast').focus().select();
  });

  that.get_ym().blur(function() {
    var newYm = hyacc.ym.normalizeYm($(this).val());
    if (newYm) {
      $(this).val(newYm);
      $(this).trigger('change');
    }
  });
};

hyacc.Journal.prototype.get_day = function() {
  return $(this.selector).find('input[name*=\\[day\\]]');
};

hyacc.Journal.prototype.get_ym = function() {
  return $(this.selector).find('input[name*=\\[ym\\]]');
};

hyacc.Journal.prototype._is_deleted = function(detail) {
  return $(detail).find('input[name*="\\[_destroy\\]"]').val() === 'true';
};

hyacc.Journal.prototype._set_deleted = function(detail, deleted) {
  $(detail).find('input[name*="\\[_destroy\\]"]').val(deleted);
};

hyacc.Journal.prototype._refresh_allocation = function(detail) {
  var params = {
    account_id: this._get_account_id(detail),
    branch_id: this._get_branch_id(detail),
    dc_type: this._get_dc_type(detail),
    index: detail.closest('[data-index]').data('index')
  };

  $.get(this.options.get_allocation_path, params, function(html) {
    $('#jd_' + params.index + '_allocation').html(html);
  });
};

hyacc.Journal.prototype._refresh_tax_rate = function(trigger, options) {
  options = options || {};

  var detail = $(trigger).closest('tr[data-detail_id]');
  var taxAmountField = detail.find('input[name*="\\[tax_amount\\]"]');
  var taxRatePercentField = detail.find('input[name*="\\[tax_rate_percent\\]"]');
  var taxType = this._get_tax_type(detail);

  // 内税／外税の場合は消費税を計算
  if (taxType == tax.INCLUSIVE || taxType == tax.EXCLUSIVE) {
    if (!options.visibility_only) {
      var ymField = $('input[name="journal\\[ym\\]"]');
      var date = ymField.val().substring(0, 4) + '-' + ymField.val().substring(4, 6) + '-01';
      var taxRate = tax.getRateOn(date);

      taxRatePercentField.val(parseInt(taxRate * 100));
    }

    taxRatePercentField.prop('disabled', false);
  } else {
    taxRatePercentField.val('').prop('disabled', true);
  }
  this._refresh_tax_amount(trigger, options);
};

hyacc.Journal.prototype._refresh_tax_amount = function(trigger, options) {
  options = options || {};

  var detail = $(trigger).closest('tr[data-detail_id]');
  var taxAmountField = detail.find('input[name*="\\[tax_amount\\]"]');
  var taxRatePercentField = detail.find('input[name*="\\[tax_rate_percent\\]"]');
  var taxType = this._get_tax_type(detail);

  // 内税／外税の場合は消費税を計算
  if (taxType == tax.INCLUSIVE || taxType == tax.EXCLUSIVE) {
    if (!options.visibility_only) {
      var amount = this._get_input_amount(detail);
      var taxRate = taxRatePercentField.val() * 0.01;

      taxAmountField.val(tax.calcTaxAmount(taxType, taxRate, amount));
    }

    taxAmountField.prop('disabled', false);
  } else {
    taxAmountField.val('').prop('disabled', true);
  }
  this._refresh_total_amount();
};

hyacc.Journal.prototype._refresh_tax_rate_all = function(options) {
  var that = this;
  this._get_details().each(function() {
    that._refresh_tax_rate(this, options);
  });
};

hyacc.Journal.prototype._refresh_total_amount = function() {
  var debitAmount = 0;
  var creditAmount = 0;

  var that = this;
  this._get_details().each(function() {
    if (that._is_deleted(this)) {
      return true;
    }

    var amount = that._get_input_amount(this);
    var taxAmount = that._get_tax_amount(this);

    var taxType = that._get_tax_type(this);
    if (taxType == tax.EXCLUSIVE) {
      amount += taxAmount;
    }

    $(this).find('.amount_sum').text(toAmount(amount));

    var dcType = that._get_dc_type(this);
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
};

hyacc.Journal.prototype._remove_detail = function(trigger) {
  var detail = $(trigger).closest('tr[data-detail_id]');
  this._set_deleted(detail, true);
  this._hide_detail(detail);
};

hyacc.Journal.prototype._show_detail = function(detail) {
  $(detail).nextUntil('tr[data-detail_id]').show();
};

hyacc.Journal.prototype._validate_amount = function() {
  var errors = [];

  var that = this;
  this._get_details().each(function(i) {
    if (that._is_deleted(this)) {
      return true;
    }

    var amount = parseInt($(this).find('input[name*="\\[input_amount\\]"]').val());
    if (isNaN(amount) || amount == 0) {
      errors.push((i + 1) + '行目の金額が未入力です。');
    }
  });

  if (errors.length > 0) {
    alert(errors.join('\n'));
    return false;
  }

  return true;
};

hyacc.Journal.prototype._validate_amount_balance = function() {
  var debit = $(this.selector).find('.debit_amount_sum').text();
  var credit = $(this.selector).find('.credit_amount_sum').text();

  if (debit != credit) {
    alert('貸借の金額が一致しません。\n借方: ' + debit + ' != 貸方: ' + credit);
    return false;
  }

  if (debit == 0 || credit == 0) {
    alert('金額が０円です。');
    return false;
  }

  return true;
};

hyacc.Journal.prototype._validate_journal = function() {
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
};
