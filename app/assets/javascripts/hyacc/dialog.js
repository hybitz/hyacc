hyacc._dialogs = new Stack();
hyacc.current_dialog = function(options) {
  return this._dialogs.top() || new hyacc.Dialog(options);
};

hyacc.Dialog = function(options) {
  this.options = options || {};
  this.title = options.title;
  hyacc._dialogs.push(this);
};

hyacc.Dialog.prototype._init_buttons = function() {
  var that = this;
  var ret = [];

  if (that.options.buttons) {
    for (var i = 0; i < that.options.buttons.length; i ++) {
      ret.push(that.options.buttons[i]);
    }
  }

  if (that.options.submit) {
    ret.push({
      text: that.options.submit,
      click: function() {
        var form = that.jq_dialog.dialog('widget').find('form').first();
        form.submit();
      }
    });
  }

  ret.push({
    text: '閉じる',
    click: function() {
      that.close();
    }
  });

  return ret;
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
    this.jq_dialog = $('<div class="dialog_wrapper">' + html + '</div>').dialog({
      modal: true,
      title: that.title,
      width: that.options.width || 'auto',
      open: that.options.open || function() {
        $(this).dialog('widget').find('.ui-dialog-titlebar button').last().focus();
      },
      close: function() {
        that.close();
      },
      buttons: that._init_buttons()
    });
  }
};

hyacc.Dialog.prototype.close = function() {
  hyacc._dialogs.pop();
  this.jq_dialog.dialog('destroy');
};
