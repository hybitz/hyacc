hyacc.Company = function(options) {
  this.selector = options.selector;
  this._init();
};

hyacc.Company.prototype.edit = function(trigger) {
  $.get($(trigger).attr('href'), {format: 'html'}, function(html) {
    var tr = $(trigger).closest('tr');
    tr.find('td').first().html(html);
    tr.find('td').last().find('a').hide();
    tr.find('td').last().find('button').show();
  });
};

hyacc.Company.prototype.update = function(trigger) {
  var tr = $(trigger).closest('tr');
  tr.find('form').submit();
};

hyacc.Company.prototype.cancel = function(trigger) {
  document.location.reload();
};

hyacc.Company.prototype._init = function() {
  var that = this;
  $(document).ready(function() {
    $(that.selector).find('button').hide();
  });
};
