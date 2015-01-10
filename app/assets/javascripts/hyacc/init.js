if (typeof hyacc === "undefined") {
  var hyacc = {};
}

hyacc.init_datepicker = function() {
  $('.datepicker').datepicker({
    dateFormat: 'yy-mm-dd',
    changeYear: true,
    changeMonth: true
  });

  $('.ympicker').ympicker({
    dateFormat: 'yy-mm',
    changeYear: true
  });
};

hyacc.trace_ajax = function() {
  var count = 0;
  $.ajaxSetup({
    beforeSend: function() {
      $('html').addClass('busy');
      count ++;
    },
    complete: function() {
      count --;
      if (count == 0) {
        $('html').removeClass('busy');
      }
    }
  });
};

$(document).ready(function() {
  hyacc.init_datepicker();
//  hyacc.trace_ajax();
});
