var banks = {};

banks.add_bank_office = function(trigger) {
  var url = $(trigger).attr('href');
  var params = {
    index: $(trigger).closest('table').find('tr').length,
    format: 'html'
  };

  $.get(url, params, function(html) {
    $(trigger).closest('tr').before(html);
  });
};
