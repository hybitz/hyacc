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
