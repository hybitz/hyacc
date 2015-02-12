Stack = function() {
  this.data = [];
};

Stack.prototype.push = function(val) {
  this.data.push(val);
  return val;
};

Stack.prototype.pop = function () {
  var ret = this.data.pop();
  return ret;
};

Stack.prototype.top = function () {
  return this.data[this.data.length - 1];
};

Stack.prototype.bottom = function() {
  return this.data[0];
};

Stack.prototype.length = function() {
  return this.data.length;
};

Stack.prototype.size = function() {
  return this.length();
};

Stack.prototype.each = function(callback) {
  for (var i = 0; i < this.size(); i ++) {
    callback.call(this, this.data[i]);
  }
};
