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
  $(document).on('change', 'select[name="employee[employee_bank_account_attributes][bank_id]"]', function() {
    const $office = $(this).closest('table').find('select[name="employee[employee_bank_account_attributes][bank_office_id]"]');
    bank_accounts.update_bank_offices(this, $office);
  });
});
