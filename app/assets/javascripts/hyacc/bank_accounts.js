const bank_accounts = {};

bank_accounts.update_bank_offices = function(trigger, target_selector) {
  const url = $(trigger).attr('href');
  const params = {
    bank_id: $(trigger).val(),
    order: 'code',
    format: 'json'
  };

  $.get(url, params, (json) => {
    replace_options(target_selector, json, true);
  });
};