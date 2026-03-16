const banks = {};

banks.add_bank_office = function(trigger) {
  const table = $(trigger).closest('table');
  const url = $(trigger).attr('href');
  const params = {
    index: table.find('tbody tr').length,
    format: 'html'
  };

  $.get(url, params, function(html) {
    table.find('tbody').append(html);
  });
};
