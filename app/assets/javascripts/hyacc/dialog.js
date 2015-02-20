if (typeof hyacc === "undefined") {
  var hyacc = {
    _dialogs: new Stack(),
    current_dialog: function(options) {
      return this._dialogs.top() || new hyacc.Dialog(options);
    }
  };
}

hyacc.Dialog = function(options) {
  this.options = options || {};
  hyacc._dialogs.push(this);
};

hyacc.Dialog.prototype.title = function() {
  return this.options.title;
};

hyacc.Dialog.prototype.open = function(url) {
  var that = this;
  $.get(url, function(html) {
    that.show(html);
  });
};

hyacc.Dialog.prototype.show = function(html) {
  if (this.jq_dialog) {
    this.jq_dialog.html(html);
  } else {
    var that = this;
    this.jq_dialog = $('<div>' + html + '</div>').dialog({
      modal: true,
      title: that.title(),
      width: that.options.width || 'auto',
      close: function() {
        that.close();
      }
    });
  }
};

hyacc.Dialog.prototype.close = function() {
  hyacc._dialogs.pop();
  this.jq_dialog.dialog('destroy');
};
