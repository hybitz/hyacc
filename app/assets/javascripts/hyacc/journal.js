hyacc.Journal = function(options) {
  this.selector = options.selector;
  this._init();
};

// 全明細の自動振替の単一選択チェック
hyacc.Journal.prototype.check_auto_journal_types = function() {
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

hyacc.Journal.prototype.validate_amount = function() {
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
  
hyacc.Journal.prototype.validate_amount_balance = function() {
  var debit = $('#journal_debit_amount_sum').text();
  var credit = $('#journal_credit_amount_sum').text();
  
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

hyacc.Journal.prototype._get_details = function() {
  return $(this.selector).find('.journal_details').find('tr[data-detail_no]');
};

hyacc.Journal.prototype._init = function() {
  this._init_shortcut();
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
