var simple_slip_settings = {};

simple_slip_settings.add_simple_slip_setting = function(trigger) {
  var url = $(trigger).attr('href');
  var params = {
    index: $(trigger).closest('table').find('tr').length,
    format: 'html'
  };

  $.get(url, params, function(html) {
    $(trigger).closest('tr').before(html);
  });
};
