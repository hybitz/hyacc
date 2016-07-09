hyacc.SimpleSlip = function(selector, options) {
  this.selector = selector;
  this.options = options;
  this._init();
};

hyacc.SimpleSlip.prototype._init = function() {
  if (this.options.readonly) {
  } else {
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

hyacc.SimpleSlip.prototype.validate_amount_on_one_side = function(form, showAlert) {
  form = $(form);

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
