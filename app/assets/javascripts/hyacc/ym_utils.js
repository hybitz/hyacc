hyacc.ym = hyacc.ym || {};

hyacc.ym.normalizeYm = function(value) {
  let ym = toInt(value);
  if (ym >= 1 && ym <= 12) {
    const now = new Date();
    const m = now.getMonth() + 1;
    const diff = Math.abs(m - ym);

    if (diff == 0) {
      return (now.getFullYear() * 100 + m).toString();
    } else {
      const lastYear = new Date(now.getFullYear() - 1, ym - 1, 1);
      const currentYear = new Date(now.getFullYear(), ym - 1, 1);
      const nextYear = new Date(now.getFullYear() + 1, ym - 1, 1);

      const lastDiff = Math.abs(lastYear - now);
      const currentDiff = Math.abs(currentYear - now);
      const nextDiff = Math.abs(nextYear - now);

      let closest = lastDiff;
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