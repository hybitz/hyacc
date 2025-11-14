var hyacc = hyacc || {};
hyacc.ym = hyacc.ym || {};

hyacc.ym.normalizeYm = function(value) {
  var ym = toInt(value);
  if (ym >= 1 && ym <= 12) {
    var now = new Date();
    var m = now.getMonth() + 1;
    var diff = Math.abs(m - ym);

    if (diff == 0) {
      return (now.getFullYear() * 100 + m).toString();
    } else {
      var lastYear = new Date(now.getFullYear() - 1, ym - 1, 1);
      var currentYear = new Date(now.getFullYear(), ym - 1, 1);
      var nextYear = new Date(now.getFullYear() + 1, ym - 1, 1);

      var lastDiff = Math.abs(lastYear - now);
      var currentDiff = Math.abs(currentYear - now);
      var nextDiff = Math.abs(nextYear - now);

      var closest = lastDiff;
      if (currentDiff < closest) closest = currentDiff;
      if (nextDiff < closest) closest = nextDiff;

      if (closest == lastDiff) {
        ym = lastYear.getFullYear() * 100 + (lastYear.getMonth() + 1);
      } else if (closest == currentDiff) {
        ym = currentYear.getFullYear() * 100 + (currentYear.getMonth() + 1);
      } else {
        ym = nextYear.getFullYear() * 100 + (nextYear.getMonth() + 1);
      }
      return ym.toString();
    }
  }
  return null;
};