hyacc.SimpleSlip = function(selector, options) {
  this.selector = selector;
  this.options = options || {};
  this._init();
};

hyacc.SimpleSlip.prototype._init = function() {
  if (this.options.readonly) {
    $(this.selector).find(':input').attr('disabled', true);
  } else {
    if (this.options.my_sub_account_id) {
      this.set_my_sub_account_id(this.options.my_sub_account_id);
    }

    this.update_tax_amount($(this.selector).find('#simple_slip_tax_amount_increase').val(), $(this.selector).find('#simple_slip_tax_amount_decrease').val());

    var that = this;

    $(this.selector).find('.accountSelect').change(function() {
      $.getJSON($(this).attr('accounts_path') + '/'+ $(this).val(), {order: 'code'}, function(account) {
          replace_options($(that.selector).find('.subAccountSelect'), account.sub_accounts);
          $(that.selector).find('.taxTypeSelect').val(account.tax_type).change();
      });

      $.get($(this).attr('account_details_path'), {account_id: $(this).val()},
        function(html) {
          $(that.selector).find('.account_detail').html(html);
        }
      );
    });

    $(this.selector).find('.taxTypeSelect').change(function() {
      that.update_tax_amount();
    });

    $(this.selector).submit(function() {
      return that.validate_slip();
    });

    this._init_ym();
    this._init_day();
    this.get_day().focus().select();
  }
};

hyacc.SimpleSlip.prototype._init_day = function() {
  var that = this;
  Mousetrap.bindGlobal('ctrl+d', function(e) {
    e.preventDefault();
    that.get_day().animate({scrollTop: 0}, 'fast').focus().select();
  });
};

hyacc.SimpleSlip.prototype._init_ym = function() {
  var that = this;
  Mousetrap.bindGlobal('ctrl+y', function(e) {
    e.preventDefault();
    that.get_ym().animate({scrollTop: 0}, 'fast').focus().select();
  });
  
  that.get_ym().blur(function() {
    var ym = toInt($(this).val());
    if (ym >= 1 && ym <= 12) {
      var now = new Date();
      var m = now.getMonth() + 1;
      var diff = Math.abs(m - ym);

      if (diff == 0) {
        $(this).val(now.getFullYear() * 100 + now.getMonth() + 1);
      } else {
        var last_year = new Date(now.getFullYear() - 1, ym - 1, now.getDate());
        var current_year = new Date(now.getFullYear(), ym - 1, now.getDate());
        var next_year = new Date(now.getFullYear() + 1, ym - 1, now.getDate());

        var diff = Math.abs(last_year - now);
        var diff2 = Math.abs(current_year - now);
        var diff3 = Math.abs(next_year - now);

        var closest = diff;
        if (diff2 < closest) {
          closest = diff2;
        }
        if (diff3 < closest) {
          closest = diff3;
        }
        
        if (closest == diff) {
          ym = last_year.getFullYear() * 100 + last_year.getMonth() + 1;
        } else if (closest == diff2) {
          ym = current_year.getFullYear() * 100 + current_year.getMonth() + 1;
        } else if (closest == diff3) {
          ym = next_year.getFullYear() * 100 + next_year.getMonth() + 1;
        }

        $(this).val(ym.toString());
      }
    }
  });
};

// 全明細の自動振替の単一選択チェック
hyacc.SimpleSlip.prototype.check_auto_journal_types = function() {
  var count = $(this.selector).find('input:checked[name*="\\[auto_journal_type\\]"]').length;

  if (count > 1) {
    alert('自動振替は複数指定できません。');
    return false;
  }

  return true;
};

// 自動振替時の日付必須チェック
hyacc.SimpleSlip.prototype.check_auto_transfer_date = function() {
  var form = $(this.selector);

  var auto_journal_type = form.find('input:checked[name*="\\[auto_journal_type\\]"]').val();
  if (auto_journal_type == AUTO_JOURNAL_TYPE_DATE_INPUT_EXPENSE) {
    var year = form.find('input[name*="\\[auto_journal_year\\]"]').val().toInt();
    var month = form.find('input[name*="\\[auto_journal_month\\]"]').val().toInt();
    var day = form.find('input[name*="\\[auto_journal_day\\]"]').val().toInt();

    if (! checkDate(year, month, day)) {
      alert('振替日の指定が不正です。');
      return false;
    }
  }

  return true;
};

hyacc.SimpleSlip.prototype.get_day = function() {
  return $(this.selector).find('input[name*=\\[day\\]]');
};

hyacc.SimpleSlip.prototype.get_ym = function() {
  return $(this.selector).find('input[name*=\\[ym\\]]');
};

hyacc.SimpleSlip.prototype.set_my_sub_account_id = function(my_sub_account_id) {
  $(this.selector).find('input[name*=\\[my_sub_account_id\\]]').val(my_sub_account_id);
};

hyacc.SimpleSlip.prototype.update_tax_amount = function(taxAmountIncrease, taxAmountDecrease) {
  var form = $(this.selector);
  var amountIncreaseField = form.find('[name*=\\[amount_increase\\]]');
  var taxAmountIncreaseField = form.find('[name*=\\[tax_amount_increase\\]]');
  var sumAmountIncreaseDiv = form.find('.sum_amount_increase');
  var amountDecreaseField = form.find('[name*=\\[amount_decrease\\]]');
  var taxAmountDecreaseField = form.find('[name*=\\[tax_amount_decrease\\]]');
  var sumAmountDecreaseDiv = form.find('.sum_amount_decrease');
  var taxTypeSelect = form.find('[name*=\\[tax_type\\]]');
  var taxRatePercentField = form.find('[name*=\\[tax_rate_percent\\]]');
  var ymField = form.find('[name*=\\[ym\\]]');

  var taxType = taxTypeSelect.val();
  var amount = this.validate_amount_on_one_side();

  var taxAmount = 0;
  var taxAmountField = null;
  var sumAmountDiv = null;
  if (amountIncreaseField.val().isPresent()) {
    taxAmount = taxAmountIncrease;
    taxAmountField = taxAmountIncreaseField;
    sumAmountDiv = sumAmountIncreaseDiv;
    taxAmountDecreaseField.val('');
    sumAmountDecreaseDiv.text('');
  } else if (amountDecreaseField.val().isPresent()) {
    taxAmount = taxAmountDecrease;
    taxAmountField = taxAmountDecreaseField;
    sumAmountDiv = sumAmountDecreaseDiv;
    taxAmountIncreaseField.val('');
    sumAmountIncreaseDiv.text('');
  } else {
    taxAmountIncreaseField.val('');
    taxAmountDecreaseField.val('');
  }

  var date = ymField.val().substring(0, 4) + '-' + ymField.val().substring(4, 6) + '-01';
  var taxRate = tax.getRateOn(date);

  // 非課税の場合は消費税入力欄を非活性にする
  if (taxType == tax.NONTAXABLE) {
    taxRatePercentField.val('').attr('disabled', true);
    taxAmountIncreaseField.val('').attr('disabled', true);
    taxAmountDecreaseField.val('').attr('disabled', true);
  }
  else if (taxType == tax.INCLUSIVE || taxType == tax.EXCLUSIVE) {
    taxRatePercentField.val(taxRate * 100).attr('disabled', false);
    if (taxAmountField) {
      taxAmount = taxAmount || tax.calcTaxAmount(taxType, taxRate, amount);
      taxAmountField.val(taxAmount);
    }
    taxAmountIncreaseField.attr('disabled', false);
    taxAmountDecreaseField.attr('disabled', false);
  }

  if (sumAmountDiv) {
    if (taxType == tax.EXCLUSIVE) {
      sumAmountDiv.text(amount ? toAmount(amount + taxAmount) : '');
    } else {
      sumAmountDiv.text(amount ? toAmount(amount) : '');
    }
  }
};

hyacc.SimpleSlip.prototype.validate_amount_on_one_side = function(showAlert) {
  var form = $(this.selector);
  var increase = (form.find('[name*=\\[amount_increase\\]]').val() || '').toInt();
  var decrease = (form.find('[name*=\\[amount_decrease\\]]').val() || '').toInt();

  if (increase == 0 && decrease == 0) {
    if ( showAlert ) {
      alert('金額を入力してください。');
    }
    return null;
  } else if (increase != 0 && decrease != 0) {
    if ( showAlert ) {
      alert('金額は増加・減少のどちらか一方に入力してください。');
    }
    return null;
  } else if (increase < 0 || decrease < 0) {
    if ( showAlert ) {
      alert('金額がマイナスです。');
    }
    return null;
  }

  return increase > 0 ? increase : decrease;
};

hyacc.SimpleSlip.prototype.validate_slip = function() {
  if (!this.validate_amount_on_one_side(true)) {
    return false;
  }

  if (!this.check_auto_journal_types()) {
    return false;
  }

  if (!this.check_auto_transfer_date()) {
    return false;
  }

  return true;
};
