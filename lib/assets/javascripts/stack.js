class Stack {
  constructor() {
    this.data = [];
  }

  push(val) {
    this.data.push(val);
    return val;
  }

  pop() {
    const ret = this.data.pop();
    return ret;
  }

  top() {
    return this.data[this.data.length - 1];
  }

  bottom() {
    return this.data[0];
  }

  length() {
    return this.data.length;
  }

  size() {
    return this.length();
  }

  each(callback) {
    for (const item of this.data) {
      callback.call(this, item);
    }
  }
}
