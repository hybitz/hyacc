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

$(function() {
  $(document).on('change', '#employee_employee_bank_account_attributes_bank_id', function() {
    bank_accounts.update_bank_offices(this, '#employee_employee_bank_account_attributes_bank_office_id');
  });
});
