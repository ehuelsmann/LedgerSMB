//>>built
define("dojo/request/script", "module ./watch ./util ../_base/kernel ../_base/array ../_base/lang ../on ../dom ../dom-construct ../has ../_base/window".split(" "), function(n, p, h, q, r, s, t, u, v, l, w) {
  function x(a, b) {
    a.canDelete && f._remove(a.id, b.options.frameDoc, !0)
  }
  function y(a) {
    g && g.length && (r.forEach(g, function(a) {
      f._remove(a.id, a.frameDoc);
      a.frameDoc = null
    }), g = []);
    return a.options.jsonp ? !a.data : !0
  }
  function z(a) {
    return!!this.scriptLoaded
  }
  function A(a) {
    return(a = a.options.checkString) && eval("typeof(" + a + ') !\x3d\x3d "undefined"')
  }
  function B(a, b) {
    if(this.canDelete) {
      var c = this.response.options;
      g.push({id:this.id, frameDoc:c.ioArgs ? c.ioArgs.frameDoc : c.frameDoc});
      c.ioArgs && (c.ioArgs.frameDoc = null);
      c.frameDoc = null
    }
    b ? this.reject(b) : this.resolve(a)
  }
  function f(a, b, c) {
    var d = h.parseArgs(a, h.deepCopy({}, b));
    a = d.url;
    b = d.options;
    var e = h.deferred(d, x, y, b.jsonp ? null : b.checkString ? A : z, B);
    s.mixin(e, {id:m + C++, canDelete:!1});
    b.jsonp && (RegExp("[?\x26]" + b.jsonp + "\x3d").test(a) || (a += (~a.indexOf("?") ? "\x26" : "?") + b.jsonp + "\x3d" + (b.frameDoc ? "parent." : "") + m + "_callbacks." + e.id), e.canDelete = !0, k[e.id] = function(a) {
      d.data = a;
      e.handleResponse(d)
    });
    h.notify && h.notify.emit("send", d, e.promise.cancel);
    if(!b.canAttach || b.canAttach(e)) {
      var g = f._attach(e.id, a, b.frameDoc);
      if(!b.jsonp && !b.checkString) {
        var l = t(g, D, function(a) {
          if("load" === a.type || E.test(g.readyState)) {
            l.remove(), e.scriptLoaded = a
          }
        })
      }
    }
    p(e);
    return c ? e : e.promise
  }
  l.add("script-readystatechange", function(a, b) {
    return"undefined" !== typeof b.createElement("script").onreadystatechange && ("undefined" === typeof a.opera || "[object Opera]" !== a.opera.toString())
  });
  var m = n.id.replace(/[\/\.\-]/g, "_"), C = 0, D = l("script-readystatechange") ? "readystatechange" : "load", E = /complete|loaded/, k = q.global[m + "_callbacks"] = {}, g = [];
  f.get = f;
  f._attach = function(a, b, c) {
    c = c || w.doc;
    var d = c.createElement("script");
    d.type = "text/javascript";
    d.src = b;
    d.id = a;
    d.async = !0;
    d.charset = "utf-8";
    return c.getElementsByTagName("head")[0].appendChild(d)
  };
  f._remove = function(a, b, c) {
    v.destroy(u.byId(a, b));
    k[a] && (c ? k[a] = function() {
      delete k[a]
    } : delete k[a])
  };
  f._callbacksProperty = m + "_callbacks";
  return f
});

//# sourceMappingURL=script.js.map