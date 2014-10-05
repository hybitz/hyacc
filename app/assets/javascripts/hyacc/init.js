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

$(document).ready(function() {
  hyacc.init_datepicker();
});
