if (typeof customers === "undefined") {
  var customers = {};
}

customers.add_customer_name = function(trigger) {
  var url = $(trigger).attr('href');
  var params = {
    index: $(trigger).closest('table').find('tr').length,
  };
  $.get(url, params, function(html) {
    $(trigger).closest('tr').before(html);
  });
};

customers.remove_customer_name = function(trigger) {
  var tr = $(trigger).closest('tr');
  tr.find('input[type="hidden"][name*=\\[_destroy\\]]').val(true);
  tr.hide();
};
