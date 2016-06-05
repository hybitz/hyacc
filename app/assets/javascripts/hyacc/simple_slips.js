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

    updateTaxAmountSimple($('#new_simple_slip'));
    $('#simple_slip_day').focus();
  });
};
