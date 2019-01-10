var simple_slips = {};

simple_slips.copy = function(trigger) {
  var url = $(trigger).attr('href');
  $.getJSON(url, function(data) {
    $('#simple_slip_remarks').val(data.remarks);
    $('#simple_slip_account_id').val(data.account_id);
    $('#simple_slip_sub_account_id').val(data.sub_account_id);
    if ($('#simple_slip_branch_id').length > 0) {
      $('#simple_slip_branch_id').val(data.branch_id);
    }
    $('#simple_slip_amount_increase').val(data.amount_increase);
    $('#simple_slip_amount_decrease').val(data.amount_decrease);
    $('#simple_slip_tax_type').val(data.tax_type);
    $('#simple_slip_tax_amount_increase').val(data.tax_amount_increase);
    $('#simple_slip_tax_amount_decrease').val(data.tax_amount_decrease);
    if ($('#simple_slip_sub_account_id').length > 0) {
      replace_options('#simple_slip_sub_account_id', data.sub_accounts);
      $('#simple_slip_sub_account_id').val(data.sub_account_id);
    }
    $('#account_detail').html(data.account_detail);

    simple_slip.update_tax_amount();
    $('#simple_slip_day').focus();
  });
};

simple_slips.calc_sum = function(options) {
  var table = $('#slipTable');
  var rows = table.find('tr[slip_id]');

  var before = table.find('thead tr').last().find('.amountSum');
  var sum = toInt(before.text());
  if (sum < 0) {
    $(before).css('color', 'red');
  }

  if (!options.only_color) {
    table.find('tr[slip_id]').each(function() {
      sum += toInt($(this).find('.amountIncrease').text());
      sum -= toInt($(this).find('.amountDecrease').text());
      $(this).find('.amountSum').text(toAmount(sum));

      if (sum < 0) {
        $(this).find('.amountSum').css('color', 'red');
      }
    });
  }

  var after = table.find('tfoot tr').first().find('.amountSum');
  var sum = toInt(after.text()); // 過去伝票をページングして参照しているかもしれないので画面の計算値に依存しない
  if (sum < 0) {
    $(after).css('color', 'red');
  }
};
