hyacc.SimpleSlip = function(selector, options) {
  this.selector = selector;
  this.options = options;
  this._init();
};

hyacc.SimpleSlip.prototype._init = function() {
  if (this.options.readonly) {
  } else {
    if (this.options.my_sub_account_id) {
      this.set_my_sub_account_id(this.options.my_sub_account_id);
    }

    this.update_tax_amount($('#simple_slip_tax_amount_increase').val(), $('#simple_slip_tax_amount_decrease').val());
    $(this.selector).addClass('tax_type_ready');

    var that = this;
    $(this.selector).submit(function() {
      return that.validate_slip();
    });
    $(this.selector).find('input[name*="\\[day\\]"]').select().focus();
  }
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

hyacc.SimpleSlip.prototype.set_my_sub_account_id = function(my_sub_account_id) {
  $(this.selector).find('input[name*=\\[my_sub_account_id\\]]').val(my_sub_account_id);
};

hyacc.SimpleSlip.prototype.update_tax_amount = function(taxAmountIncrease, taxAmountDecrease) {
  var form = $(this.selector);
  var amountFieldIncrease = form.find('[name*=\\[amount_increase\\]]');
  var taxFieldIncrease = form.find('[name*=\\[tax_amount_increase\\]]');
  var sumAmountDivIncrease = form.find('.sum_amount_increase');
  var amountFieldDecrease = form.find('[name*=\\[amount_decrease\\]]');
  var taxFieldDecrease = form.find('[name*=\\[tax_amount_decrease\\]]');
  var sumAmountDivDecrease = form.find('.sum_amount_decrease');
  var taxTypeSelect = form.find('[name*=\\[tax_type\\]]');
  var taxRatePercentField = form.find('[name*=\\[tax_rate_percent\\]]');
  var ymField = form.find('[name*=\\[ym\\]]');

  var taxType = taxTypeSelect.val();
  var amount = this.validate_amount_on_one_side();

  if (!amount) {
    taxFieldIncrease.val('');
    sumAmountDivIncrease.text('');
    taxFieldDecrease.val('');
    sumAmountDivDecrease.text('');

    // 非課税の場合は消費税入力欄を非活性にする
    if (taxType == tax.NONTAXABLE) {
      taxRatePercentField.attr('disabled', true);
      taxFieldIncrease.attr('disabled', true);
      taxFieldDecrease.attr('disabled', true);
    }

    return;
  }

  var taxAmount;
  var taxField;
  var sumAmountDiv;
  if (amountFieldIncrease.val().isPresent()) {
    taxAmount = taxAmountIncrease;
    taxField = taxFieldIncrease;
    sumAmountDiv = sumAmountDivIncrease;
    taxFieldDecrease.val('');
    sumAmountDivDecrease.text('');
  } else if (amountFieldDecrease.val().isPresent()) {
    taxAmount = taxAmountDecrease;
    taxField = taxFieldDecrease;
    sumAmountDiv = sumAmountDivDecrease;
    taxFieldIncrease.val('');
    sumAmountDivIncrease.text('');
  } else {
    return;
  }

  var date = ymField.val().substring(0, 4) + '-' + ymField.val().substring(4, 6) + '-01';
  var taxRate = tax.getRateOn(date);

  // 非課税の場合は消費税入力欄を非活性にする
  if ( taxType == tax.NONTAXABLE ) {
    taxRatePercentField.val('');
    taxRatePercentField.attr('disabled', true);
    taxFieldIncrease.val('');
    taxFieldIncrease.attr('disabled', true);
    taxFieldDecrease.val('');
    taxFieldDecrease.attr('disabled', true);
    sumAmountDiv.text(amount ? toAmount(amount) : '');
  }
  // 内税の場合は消費税を自動計算する
  else if ( taxType == tax.INCLUSIVE ) {
    taxRatePercentField.val(taxRate * 100);
    taxField.val(taxAmount ? taxAmount : tax.calcTaxAmount(taxType, taxRate, amount));
    taxRatePercentField.attr('disabled', false);
    taxFieldIncrease.attr('disabled', false);
    taxFieldDecrease.attr('disabled', false);
    sumAmountDiv.text(amount ? toAmount(amount) : '');
  }
  // 外税の場合は消費税を自動計算する
  else if ( taxType == tax.EXCLUSIVE ) {
    taxRatePercentField.val(taxRate * 100);
    taxField.val(taxAmount ? taxAmount : tax.calcTaxAmount(taxType, taxRate, amount));
    taxRatePercentField.attr('disabled', false);
    taxFieldIncrease.attr('disabled', false);
    taxFieldDecrease.attr('disabled', false);
    sumAmountDiv.text(amount ? toAmount(amount + taxField.val().toInt()) : '');
  }
};

hyacc.SimpleSlip.prototype.validate_amount_on_one_side = function(showAlert) {
  var form = $(this.selector);
  var increase = form.find('[name*=\\[amount_increase\\]]').val().toInt();
  var decrease = form.find('[name*=\\[amount_decrease\\]]').val().toInt();

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
