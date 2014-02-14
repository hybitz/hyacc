/**
 * $Id: dialog.js 3333 2014-01-30 14:18:42Z ichy $
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
  jQuery.get(url, function(html) {
    that.show(html);
  });
};

hyacc.Dialog.prototype.show = function(html) {
  jQuery(this.selector).remove();
  jQuery('<div></div>').attr('id', this.id).appendTo('body');
  jQuery(this.selector).html(html);
  
  var that = this;
  jQuery(this.selector).dialog({
    modal: true,
    title: that.options.title,
    width: that.options.width || 'auto'
  });
};
