hyacc.Journal = function(options) {
  this.selector = options.selector;
  this._init();
};

hyacc.Journal.prototype.get_details = function() {
  var ret = [];

  $(this.selector).find('.journal_details').find('tr[data-detail_no]').each(function() {
    ret.push($(this).get(0));
  });
  
  return ret;
};

hyacc.Journal.prototype._init = function() {
  this._init_shortcut();
};

hyacc.Journal.prototype._init_shortcut = function() {
  $('input[id$=_input_amount]').each(function(){
    var detail_no = $(this).closest('[data-detail_no]').data('detail_no');

    shortcut.add("Down",
      function() {
        var next_detail_id = '#journal_details_' + (detail_no + 1) + '_input_amount';
        $(next_detail_id).focus().select();
      }, {target: $(this).get(0)}
    );
    shortcut.add("Up",
      function() {
        var prev_detail_id = '#journal_details_' + (detail_no - 1) + '_input_amount';
        $(prev_detail_id).focus().select();
      }, {target: $(this).get(0)}
    );
  });
};
