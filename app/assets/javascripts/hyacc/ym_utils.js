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
      var last_year = new Date(now.getFullYear() - 1, ym - 1, now.getDate());
      var current_year = new Date(now.getFullYear(), ym - 1, now.getDate());
      var next_year = new Date(now.getFullYear() + 1, ym - 1, now.getDate());

      var diff = Math.abs(last_year - now);
      var diff2 = Math.abs(current_year - now);
      var diff3 = Math.abs(next_year - now);

      var closest = diff;
      if (diff2 < closest) closest = diff2;
      if (diff3 < closest) closest = diff3;

      if (closest == diff) {
        ym = last_year.getFullYear() * 100 + (last_year.getMonth() + 1);
      } else if (closest == diff2) {
        ym = current_year.getFullYear() * 100 + (current_year.getMonth() + 1);
      } else {
        ym = next_year.getFullYear() * 100 + (next_year.getMonth() + 1);
      }
      return ym.toString();
    }
  }
  return null;
};