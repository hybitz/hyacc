hyacc.Employee = function(options) {
  this.selector = options.selector;
  this._init();
};

hyacc.Employee.prototype.add_num_of_dependent = function(trigger) {
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

hyacc.Employee.prototype.edit_num_of_dependents = function(trigger) {
  this.num_of_dependents.dialog('open');
};

hyacc.Employee.prototype._init = function() {
  hyacc.init_datepicker();
  this._init_num_of_dependents();
};

hyacc.Employee.prototype._init_num_of_dependents = function() {
  this.num_of_dependents = $(this.selector  + ' .num_of_dependents').dialog({
    autoOpen: false,
    modal: true,
  });
};


hyacc.Employee.prototype.remove_num_of_dependent = function(trigger) {
  var tr = $(trigger).closest('tr');
  tr.find('input[name*="\[_destroy\]"]').val(true);
  tr.hide();
};
