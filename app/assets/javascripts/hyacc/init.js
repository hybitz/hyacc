$(document).ready(function() {
  $.ajaxSetup({
    beforeSend: function() {
      $('html').addClass('busy'); 
    },
    complete: function() {
     $('html').removeClass('busy');  
    }
  });
});

if (typeof hyacc === "undefined") {
  var hyacc = {};
}

hyacc.init_datepicker = function() {
  $('.datepicker').datepicker({
    dateFormat: 'yy-mm-dd',
    changeYear: true,
    changeMonth: true
  });
};
