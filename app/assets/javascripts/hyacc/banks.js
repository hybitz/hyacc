var banks = {};

banks.add_bank_office = function(trigger) {
  var table = $(trigger).closest('table');
  var url = $(trigger).attr('href');
  var params = {
    index: table.find('tbody tr').length,
    format: 'html'
  };

  $.get(url, params, function(html) {
    table.find('tbody').append(html);
  });
};
