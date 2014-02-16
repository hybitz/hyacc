/**
 * Product: hyacc
 * Copyright 2014 by Hybitz.co.ltd
 * ALL Rights Reserved.
 */
if (typeof hyacc === "undefined") {
  var hyacc = {};
}

hyacc.Dialog = function(options) {
  this.id = 'hyacc-dialog';
  this.selector = '#' + this.id;
  this.options = options || {};
};

hyacc.Dialog.prototype.open = function(url) {
  var that = this;
  $.get(url, function(html) {
    that.show(html);
  });
};

hyacc.Dialog.prototype.show = function(html) {
  $(this.selector).remove();
  $('<div></div>').attr('id', this.id).appendTo('body');
  $(this.selector).html(html);
  
  var that = this;
  $(this.selector).dialog({
    modal: true,
    title: that.options.title,
    width: that.options.width || 'auto'
  });
};
