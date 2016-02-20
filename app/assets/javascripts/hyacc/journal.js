hyacc.Journal = function(options) {
  this.selector = options.selector;
  this._init();
};

hyacc.Journal.prototype.updateTaxAmount = function(trigger) {
  var detailTr = $(trigger).closest('tr[data-detail_no]');
  var taxAmountField = $('#' + detailTr.attr('id') + '_tax_amount' );
  var ymField = $('#journal_ym');
  var taxRatePercentField = $('#' + detailTr.attr('id') + '_tax_rate_percent');

  var amount = parseInt(this._get_input_amount(detailTr));
  var taxType = this._get_tax_type(detailTr);

  var date = ymField.val().substring(0, 4) + '-' + ymField.val().substring(4, 6) + '-01';
  var taxRate = taxRatePercentField.val() * 0.01;
  if (! $(trigger).is('input[name*="\\[tax_rate_percent\\]"]')) {
    taxRate = tax.getRateOn(date);
  }

  // 内税／外税の場合は消費税を計算
  if (taxType == tax.INCLUSIVE || taxType == tax.EXCLUSIVE) {
    taxRatePercentField.val(parseInt(taxRate * 100));
    taxAmountField.val(tax.calcTaxAmount(taxType, taxRate, amount));
    taxAmountField.prop('disabled', false);
  } else {
    taxRatePercentField.val('');
    taxAmountField.val('');
    taxAmountField.prop('disabled', true);
  }

  journal.refresh_total_amount();
};

hyacc.Journal.prototype.refresh_total_amount = function() {
  var debitAmount = 0;
  var creditAmount = 0;

  var that = this;
  this._get_details().each(function() {
    var amount = parseInt(that._get_input_amount(this));
    if (isNaN(amount)) {
      amount = 0;
    }
    
    var taxAmount = parseInt(that._get_tax_amount(this));
    if (isNaN(taxAmount)) {
      taxAmount = 0;
    }

    var taxType = that._get_tax_type(this);
    if (taxType == tax.EXCLUSIVE) {
      amount += taxAmount;
    }
    
    $(this).find('span.amount_sum').text(toAmount(amount));

    var dcType = that._get_dc_type(this);
    if (dcType == DC_TYPE_DEBIT) {
      debitAmount += amount;
    } else if (dcType == DC_TYPE_CREDIT) {
      creditAmount += amount;
    } else {
      alert('貸借が不正です。');
    }
  });

  $(this.selector).find('.journal_debit_amount_sum').text(toAmount(debitAmount));
  $(this.selector).find('.journal_credit_amount_sum').text(toAmount(creditAmount));
};

hyacc.Journal.prototype.get_details = function() {
  var ret = [];

  this._get_details().each(function() {
    ret.push($(this).get(0));
  });
  
  return ret;
};

hyacc.Journal.prototype.show_detail = function(tr) {
  for (var i = 0; i < 3; i ++) {
    var tr = $(tr).next();
    tr.show();
  }
};

// 自動振替時の日付必須チェック
hyacc.Journal.prototype._check_auto_journal_dates = function() {
  var errors = [];

  var that = this;
  this._get_details().each(function(i) {
    if (that._get_auto_journal_type(this) == AUTO_JOURNAL_TYPE_DATE_INPUT_EXPENSE) {
      var year = toInt(that._get_auto_journal_year(this));
      var month = toInt(that._get_auto_journal_month(this));
      var day = toInt(that._get_auto_journal_day(this));

      if (! checkDate(year, month, day)) {
        errors.push('【明細' + (i+1) + '】振替日の指定が不正です。');
        that.show_detail(this);
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
    var tr = $(this);
    var count = 0;

    for (var j = 0; j < 3; j ++) {
      var tr = $(tr).next();
      var checked = $(tr).find('input[name*="\\[auto_journal_type\\]"]').prop('checked');
      if (checked) {
        count ++;
      }
    }

    if (count > 1) {
      errors.push('【明細' + (i+1) + '】自動振替は複数指定できません。');
      that.show_detail(this);
    }
  });

  if (errors.length > 0) {
    alert(errors.join('\n'));
    return false;
  }

  return true;
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

hyacc.Journal.prototype._get_dc_type = function(detail) {
  return $(detail).find('select[name*="\\[dc_type\\]"]').val();
};

hyacc.Journal.prototype._get_details = function() {
  return $(this.selector).find('.journal_details').find('tr[data-detail_no]');
};

hyacc.Journal.prototype._get_input_amount = function(detail) {
  return $(detail).find('input[name*="\\[input_amount\\]"]').val();
};

hyacc.Journal.prototype._get_tax_amount = function(detail) {
  return $(detail).find('input[name*="\\[tax_amount\\]"]').val();
};

hyacc.Journal.prototype._get_tax_type = function(detail) {
  return $(detail).find('select[name*="\\[tax_type\\]"]').val();
};

hyacc.Journal.prototype._init = function() {
  this._init_shortcut();
  this._init_validation();
  this._init_event_handlers();
  this.refresh_total_amount();
};

hyacc.Journal.prototype._init_shortcut = function() {
  $('input[id$=_input_amount]').each(function(){
    var detail_no = $(this).closest('[data-detail_no]').data('detail_no');

    shortcut.add("Down",
      function() {
        var next_detail_id = '#journal_details_' + (detail_no + 1) + '_input_amount';
        $(next_detail_id).focus().select();
      }, {target: $(this).get(0)}
    );
    shortcut.add("Up",
      function() {
        var prev_detail_id = '#journal_details_' + (detail_no - 1) + '_input_amount';
        $(prev_detail_id).focus().select();
      }, {target: $(this).get(0)}
    );
  });
};

hyacc.Journal.prototype._init_event_handlers = function() {
  var that = this;
  $(this.selector).delegate('input[name*="\\[ym\\]"]', 'change', function() {
    that._refresh_tax_amount_all();
  })
  .delegate('select[name*="\\[dc_type\\]"]', 'change', function() {
    that.refresh_total_amount();
  })
  .delegate('.delete_detail_button', 'click', function() {
    that._remove_detail(this);
    that.refresh_total_amount();
    return false;
  })
  .delegate('input[name*="\\[tax_amount\\]"]', 'change', function() {
    that.refresh_total_amount();
  });
};

hyacc.Journal.prototype._init_validation = function() {
  var that = this;
  $(this.selector).submit(function() {
    return that._validate_journal();
  });
};

hyacc.Journal.prototype._refresh_tax_amount_all = function() {
  var that = this;
  this._get_details().each(function() {
    that.updateTaxAmount(this);
  });
};

hyacc.Journal.prototype._remove_detail = function(trigger) {
  var tr = $(trigger).closest('tr[data-detail_no]');
  var tr2 = tr.next();
  var tr3 = tr2.next();
  var tr4 = tr3.next();

  tr4.remove();
  tr3.remove();
  tr2.remove();
  tr.remove();
};

hyacc.Journal.prototype._validate_amount = function() {
  var errors = [];

  this._get_details().each(function(i) {
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
  var debit = $(this.selector).find('.journal_debit_amount_sum').text();
  var credit = $(this.selector).find('.journal_credit_amount_sum').text();
  
  if (debit != credit) {
    alert('貸借の金額が一致しません。');
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
