hyacc.SimpleSlip = function(selector, options) {
  this.selector = selector;
  this.options = options;
  this._init();
};

hyacc.SimpleSlip.prototype._init = function() {
  if (this.options.readonly) {
  } else {
    $(this.selector).find('input[name*="\\[day\\]"]').select().focus();
  }
};

