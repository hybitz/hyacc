var bank_accounts = {};

bank_accounts.update_bank_offices = function(trigger, target_selector) {
  var url = $(trigger).attr('href');
  var params = {
    bank_id: $(trigger).val(),
    order: 'code',
    format: 'json'
  };

  $.get(url, params, function(json) {
    replace_options(target_selector, json, true);
  });
};