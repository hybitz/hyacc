var hyacc = hyacc || {};
hyacc.tax = hyacc.tax || {};

hyacc.tax.setRateField = function(context, options) {
  options = options || {};
  var taxRatePercentField = context.find('input[name*="\\[tax_rate_percent\\]"]');
  var taxTypeField = context.find('select[name*="\\[tax_type\\]"], input[name*="\\[tax_type\\]"]');
  var taxType = taxTypeField.val();

  if (taxType == tax.INCLUSIVE || taxType == tax.EXCLUSIVE) {
    if (!options.visibility_only) {
      var ymField = context.closest('form').find('input[name*="\\[ym\\]"]');
      var ymVal = ymField.val().toString();
      var date = ymVal.substring(0, 4) + '-' + ymVal.substring(4, 6) + '-01';
      var taxRate = tax.getRateOn(date);
      taxRatePercentField.val(parseInt(taxRate * 100));
    }
    taxRatePercentField.prop('disabled', false);
  } else {
    taxRatePercentField.val('').prop('disabled', true);
  }
};