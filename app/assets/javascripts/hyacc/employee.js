hyacc.Employee = function(options) {
  this.selector = options.selector;
  this._init();
};

hyacc.Employee.prototype.add_num_of_dependant = function(trigger) {
  var table = $(trigger).closest('table');
  var params = {
    index: table.find('tbody tr').length,
    format: 'html'
  };
  
  $.get($(trigger).attr('href'), params, function(html) {
    table.find('tbody').append(html);
    hyacc.init_datepicker();
  });
};

hyacc.Employee.prototype._init = function() {
  hyacc.init_datepicker();
};

hyacc.Employee.prototype.remove_num_of_dependant = function(trigger) {
  var tr = $(trigger).closest('tr');
  tr.find('input[name*="\[_destroy\]"]').val(true);
  tr.hide();
};
