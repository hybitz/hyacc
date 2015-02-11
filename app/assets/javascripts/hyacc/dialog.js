if (typeof hyacc === "undefined") {
  var hyacc = {};
}

hyacc.Dialog = function(options) {
  this.options = options || {};
};

hyacc.Dialog.prototype.open = function(url) {
  var that = this;
  $.get(url, function(html) {
    that.show(html);
  });
};

hyacc.Dialog.prototype.show = function(html) {
  var that = this;
  $('<div>' + html + '</div>').dialog({
    modal: true,
    title: that.options.title,
    width: that.options.width || 'auto',
    close: function() {
      $(this).dialog('destroy');
    }
  });
};
