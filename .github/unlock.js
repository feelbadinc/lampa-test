var _def = Object.defineProperty;
Object.defineProperty = function(obj, prop, descriptor) {
  if (prop === 'hasPremium') {
    descriptor = Object.assign(
      {}, descriptor, { value: function() { return 1; } }
    );
  }
  return _def.call(this, obj, prop, descriptor);
};

const _open = XMLHttpRequest.prototype.open;
XMLHttpRequest.prototype.open = function(_, url) {
  if (
    typeof url === 'string'
    && url.indexOf('/api/metric') !== -1
  ) return;
  return _open.apply(this, arguments);
};
