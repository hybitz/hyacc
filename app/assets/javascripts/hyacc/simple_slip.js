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

    var that = this;

    this._init_ym();

    $(this.selector).find('.accountSelect').change(function() {
      $.getJSON($(this).attr('accounts_path') + '/'+ $(this).val(), {order: 'code'}, function(account) {
          replace_options($(that.selector).find('.subAccountSelect'), account.sub_accounts);
          $(that.selector).find('.taxTypeSelect').val(account.tax_type);
          that.update_tax_rate();
      });

      $.get($(this).attr('account_details_path'), {account_id: $(this).val()},
        function(html) {
          $(that.selector).find('.account_detail').html(html);
        }
      );
    });

    $(this.selector).find('.taxTypeSelect').change(function() {
      that.update_tax_rate();
    });

    $(this.selector).find('.taxRatePercentText').change(function() {
      that.update_tax_amount();
    });

    $(this.selector).submit(function() {
      return that.validate_slip();
    });

    var form = $(this.selector);
    var taxType = form.find('[name*="\\[tax_type\\]"]').val();
    if (taxType == tax.NONTAXABLE) {
      form.find('[name*="\\[tax_amount_increase\\]"]').val('').prop('disabled', true);
      form.find('[name*="\\[tax_amount_decrease\\]"]').val('').prop('disabled', true);
      hyacc.tax.setRateField(form);
    }

    this.get_day().focus().select();
  }
};

hyacc.SimpleSlip.prototype._init_ym = function() {
  var that = this;
  
  that.get_ym().blur(function() {
    var newYm = hyacc.ym.normalizeYm($(this).val());
    if (newYm) {
      $(this).val(newYm);
      $(this).change();
    }
  }).change(function() {
    if ($(this).val().length == 6) {
      that.update_tax_rate();
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

hyacc.SimpleSlip.prototype.update_tax_rate = function(taxAmountIncrease, taxAmountDecrease) {
  var form = $(this.selector);
  hyacc.tax.setRateField(form);
  this.update_tax_amount(taxAmountIncrease, taxAmountDecrease);
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

  var taxType = taxTypeSelect.val();
  var taxRate = taxRatePercentField.val() / 100;

  // 非課税の場合は消費税入力欄を非活性にする
  if (taxType == tax.NONTAXABLE) {
    taxAmountIncreaseField.val('').attr('disabled', true);
    taxAmountDecreaseField.val('').attr('disabled', true);
  }
  else if (taxType == tax.INCLUSIVE || taxType == tax.EXCLUSIVE) {
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
