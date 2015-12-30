var simple_slips = {};

simple_slips.copy = function(trigger) {
  var url = $(trigger).attr('href');
  $.getJSON(url, function(data) {
    $('#slip_remarks').val(data.remarks);
    $('#slip_account_id').val(data.account_id);
    $('#slip_sub_account_id').val(data.sub_account_id);
    if ($('#slip_branch_id').length > 0) {
      $('#slip_branch_id').val(data.branch_id);
    }
    $('#slip_amount_increase').val(data.amount_increase);
    $('#slip_amount_decrease').val(data.amount_decrease);
    $('#slip_tax_type').val(data.tax_type);
    $('#slip_tax_amount_increase').val(data.tax_amount_increase);
    $('#slip_tax_amount_decrease').val(data.tax_amount_decrease);
    if ($('#slip_sub_account_id').length > 0) {
      replace_options('#slip_sub_account_id', data.sub_accounts);
      $('#slip_sub_account_id').val(data.sub_account_id);
    }
    $('#account_detail').html(data.account_detail);
    
    updateTaxAmountSimple($('#slip_new_form'));
    $('#slip_day').focus();
  });
};