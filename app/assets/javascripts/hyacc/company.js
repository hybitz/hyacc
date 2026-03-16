hyacc.Company = function(options) {
  this.selector = options.selector;
  this._init();
};

hyacc.Company.prototype.edit = function(trigger) {
  $.get($(trigger).attr('href'), {format: 'html'}, function(html) {
    const tr = $(trigger).closest('tr');
    tr.find('td').first().html(html);
    tr.find('td').last().find('a').hide();
    tr.find('td').last().find('button').show();
  });
};

hyacc.Company.prototype.update = function(trigger) {
  const form = $(trigger).closest('tr').find('form')[0];
  Rails.fire(form, 'submit');
};

hyacc.Company.prototype.cancel = function(trigger) {
  document.location.reload();
};

hyacc.Company.prototype._init = function() {
  const that = this;
  $(document).ready(function() {
    $(that.selector).find('button').hide();
  });
};
