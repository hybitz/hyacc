hyacc.tax = hyacc.tax || {};

hyacc.tax.setRateField = function(context, options = {}) {
  const taxRatePercentField = context.find('input[name*="\\[tax_rate_percent\\]"]');
  const taxTypeField = context.find('select[name*="\\[tax_type\\]"], input[name*="\\[tax_type\\]"]');
  const taxType = taxTypeField.val();

  if (taxType == tax.INCLUSIVE || taxType == tax.EXCLUSIVE) {
    if (!options.visibility_only) {
      const ymField = context.closest('form').find('input[name*="\\[ym\\]"]');
      const ymVal = ymField.val().toString();
      const date = `${ymVal.substring(0, 4)}-${ymVal.substring(4, 6)}-01`;
      const taxRate = tax.getRateOn(date);
      taxRatePercentField.val(parseInt(taxRate * 100));
    }
    taxRatePercentField.prop('disabled', false);
  } else {
    taxRatePercentField.val('').prop('disabled', true);
  }
};