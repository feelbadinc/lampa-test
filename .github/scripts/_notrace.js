const _fetch = window.fetch;

window.fetch = function(url) {
  if (typeof url === 'string' && /\/api\/(metric|ad)/.test(url)) {
    return Promise.resolve(new Response());
  }
  return _fetch.apply(this, arguments);                                                                                                                                                                                            
};

const _open = XMLHttpRequest.prototype.open;
XMLHttpRequest.prototype.open = function(_, url) {
  if (typeof url === 'string' && /\/api\/(metric|ad)/.test(url)) {
    this._notrace = true;
    return;
  }
  return _open.apply(this, arguments);
};

const _send = XMLHttpRequest.prototype.send;
XMLHttpRequest.prototype.send = function() {
  if (this._notrace) {
    return;
  }
  return _send.apply(this, arguments);
};
