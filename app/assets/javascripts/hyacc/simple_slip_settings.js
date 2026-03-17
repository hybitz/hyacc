const simple_slip_settings = {};

simple_slip_settings.add_simple_slip_setting = function(trigger) {
  const url = $(trigger).attr('href');
  const params = {
    index: $(trigger).closest('table').find('tbody').find('tr').length,
    format: 'html'
  };

  $.get(url, params, (html) => {
    $(trigger).closest('table').find('tbody').append(html);
  });
};
