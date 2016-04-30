//>>built
define("dojo/_base/declare", ["./kernel", "../has", "./lang"], function(w, E, z) {
  function s(e, d) {
    throw Error("declare" + (d ? " " + d : "") + ": " + e);
  }
  function F(e, d, a) {
    var b, c, f, h, k, g, l, p = this._inherited = this._inherited || {};
    "string" == typeof e && (b = e, e = d, d = a);
    a = 0;
    h = e.callee;
    (b = b || h.nom) || s("can't deduce a name to call inherited()", this.declaredClass);
    k = this.constructor._meta;
    f = k.bases;
    l = p.p;
    if(b != t) {
      if(p.c !== h && (l = 0, g = f[0], k = g._meta, k.hidden[b] !== h)) {
        (c = k.chains) && "string" == typeof c[b] && s("calling chained method with inherited: " + b, this.declaredClass);
        do {
          if(k = g._meta, c = g.prototype, k && (c[b] === h && c.hasOwnProperty(b) || k.hidden[b] === h)) {
            break
          }
        }while(g = f[++l]);
        l = g ? l : -1
      }
      if(g = f[++l]) {
        if(c = g.prototype, g._meta && c.hasOwnProperty(b)) {
          a = c[b]
        }else {
          h = u[b];
          do {
            if(c = g.prototype, (a = c[b]) && (g._meta ? c.hasOwnProperty(b) : a !== h)) {
              break
            }
          }while(g = f[++l])
        }
      }
      a = g && a || u[b]
    }else {
      if(p.c !== h && (l = 0, (k = f[0]._meta) && k.ctor !== h)) {
        c = k.chains;
        for((!c || "manual" !== c.constructor) && s("calling chained constructor with inherited", this.declaredClass);(g = f[++l]) && !((k = g._meta) && k.ctor === h);) {
        }
        l = g ? l : -1
      }
      for(;(g = f[++l]) && !(a = (k = g._meta) ? k.ctor : g);) {
      }
      a = g && a
    }
    p.c = a;
    p.p = l;
    if(a) {
      return!0 === d ? a : a.apply(this, d || e)
    }
  }
  function H(e, d) {
    return"string" == typeof e ? this.__inherited(e, d, !0) : this.__inherited(e, !0)
  }
  function I(e, d, a) {
    var b = this.getInherited(e, d);
    if(b) {
      return b.apply(this, a || d || e)
    }
  }
  function J(e) {
    for(var d = this.constructor._meta.bases, a = 0, b = d.length;a < b;++a) {
      if(d[a] === e) {
        return!0
      }
    }
    return this instanceof e
  }
  function K(e, d) {
    for(var a in d) {
      a != t && d.hasOwnProperty(a) && (e[a] = d[a])
    }
    if(E("bug-for-in-skips-shadowed")) {
      for(var b = z._extraNames, c = b.length;c;) {
        a = b[--c], a != t && d.hasOwnProperty(a) && (e[a] = d[a])
      }
    }
  }
  function L(e) {
    x.safeMixin(this.prototype, e);
    return this
  }
  function M(e, d) {
    e instanceof Array || "function" == typeof e || (d = e, e = void 0);
    d = d || {};
    e = e || [];
    return x([this].concat(e), d)
  }
  function N(e, d) {
    return function() {
      var a = arguments, b = a, c = a[0], f, h;
      h = e.length;
      var k;
      if(!(this instanceof a.callee)) {
        return v(a)
      }
      if(d && (c && c.preamble || this.preamble)) {
        k = Array(e.length);
        k[0] = a;
        for(f = 0;;) {
          if(c = a[0]) {
            (c = c.preamble) && (a = c.apply(this, a) || a)
          }
          c = e[f].prototype;
          (c = c.hasOwnProperty("preamble") && c.preamble) && (a = c.apply(this, a) || a);
          if(++f == h) {
            break
          }
          k[f] = a
        }
      }
      for(f = h - 1;0 <= f;--f) {
        c = e[f], (c = (h = c._meta) ? h.ctor : c) && c.apply(this, k ? k[f] : a)
      }
      (c = this.postscript) && c.apply(this, b)
    }
  }
  function O(e, d) {
    return function() {
      var a = arguments, b = a, c = a[0];
      if(!(this instanceof a.callee)) {
        return v(a)
      }
      d && (c && (c = c.preamble) && (b = c.apply(this, b) || b), (c = this.preamble) && c.apply(this, b));
      e && e.apply(this, a);
      (c = this.postscript) && c.apply(this, a)
    }
  }
  function P(e) {
    return function() {
      var d = arguments, a = 0, b, c;
      if(!(this instanceof d.callee)) {
        return v(d)
      }
      for(;b = e[a];++a) {
        if(b = (c = b._meta) ? c.ctor : b) {
          b.apply(this, d);
          break
        }
      }
      (b = this.postscript) && b.apply(this, d)
    }
  }
  function Q(e, d, a) {
    return function() {
      var b, c, f = 0, h = 1;
      a && (f = d.length - 1, h = -1);
      for(;b = d[f];f += h) {
        c = b._meta, (b = (c ? c.hidden : b.prototype)[e]) && b.apply(this, arguments)
      }
    }
  }
  function G(e) {
    C.prototype = e.prototype;
    e = new C;
    C.prototype = null;
    return e
  }
  function v(e) {
    var d = e.callee, a = G(d);
    d.apply(a, e);
    return a
  }
  function x(e, d, a) {
    "string" != typeof e && (a = d, d = e, e = "");
    a = a || {};
    var b, c, f, h, k, g, l, p = 1, w = d;
    if("[object Array]" == y.call(d)) {
      p = e;
      f = [];
      h = [{cls:0, refs:[]}];
      g = {};
      for(var A = 1, v = d.length, r = 0, n, B, m, q;r < v;++r) {
        (n = d[r]) ? "[object Function]" != y.call(n) && s("mixin #" + r + " is not a callable constructor.", p) : s("mixin #" + r + " is unknown. Did you use dojo.require to pull it in?", p);
        B = n._meta ? n._meta.bases : [n];
        m = 0;
        for(n = B.length - 1;0 <= n;--n) {
          q = B[n].prototype, q.hasOwnProperty("declaredClass") || (q.declaredClass = "uniqName_" + R++), q = q.declaredClass, g.hasOwnProperty(q) || (g[q] = {count:0, refs:[], cls:B[n]}, ++A), q = g[q], m && m !== q && (q.refs.push(m), ++m.count), m = q
        }
        ++m.count;
        h[0].refs.push(m)
      }
      for(;h.length;) {
        m = h.pop();
        f.push(m.cls);
        for(--A;c = m.refs, 1 == c.length;) {
          m = c[0];
          if(!m || --m.count) {
            m = 0;
            break
          }
          f.push(m.cls);
          --A
        }
        if(m) {
          r = 0;
          for(v = c.length;r < v;++r) {
            m = c[r], --m.count || h.push(m)
          }
        }
      }
      A && s("can't build consistent linearization", p);
      n = d[0];
      f[0] = n ? n._meta && n === f[f.length - n._meta.bases.length] ? n._meta.bases.length : 1 : 0;
      g = f;
      f = g[0];
      p = g.length - f;
      d = g[p]
    }else {
      g = [0], d ? "[object Function]" == y.call(d) ? (f = d._meta, g = g.concat(f ? f.bases : d)) : s("base class is not a callable constructor.", e) : null !== d && s("unknown base class. Did you use dojo.require to pull it in?", e)
    }
    if(d) {
      for(c = p - 1;;--c) {
        b = G(d);
        if(!c) {
          break
        }
        f = g[c];
        (f._meta ? K : D)(b, f.prototype);
        h = new Function;
        h.superclass = d;
        h.prototype = b;
        d = b.constructor = h
      }
    }else {
      b = {}
    }
    x.safeMixin(b, a);
    f = a.constructor;
    f !== u.constructor && (f.nom = t, b.constructor = f);
    for(c = p - 1;c;--c) {
      (f = g[c]._meta) && f.chains && (l = D(l || {}, f.chains))
    }
    b["-chains-"] && (l = D(l || {}, b["-chains-"]));
    f = !l || !l.hasOwnProperty(t);
    g[0] = h = l && "manual" === l.constructor ? P(g) : 1 == g.length ? O(a.constructor, f) : N(g, f);
    h._meta = {bases:g, hidden:a, chains:l, parents:w, ctor:a.constructor};
    h.superclass = d && d.prototype;
    h.extend = L;
    h.createSubclass = M;
    h.prototype = b;
    b.constructor = h;
    b.getInherited = H;
    b.isInstanceOf = J;
    b.inherited = S;
    b.__inherited = F;
    e && (b.declaredClass = e, z.setObject(e, h));
    if(l) {
      for(k in l) {
        b[k] && ("string" == typeof l[k] && k != t) && (f = b[k] = Q(k, g, "after" === l[k]), f.nom = k)
      }
    }
    return h
  }
  var D = z.mixin, u = Object.prototype, y = u.toString, C = new Function, R = 0, t = "constructor", S = w.config.isDebug ? I : F;
  w.safeMixin = x.safeMixin = function(e, d) {
    var a, b;
    for(a in d) {
      if(b = d[a], (b !== u[a] || !(a in u)) && a != t) {
        "[object Function]" == y.call(b) && (b.nom = a), e[a] = b
      }
    }
    if(E("bug-for-in-skips-shadowed")) {
      for(var c = z._extraNames, f = c.length;f;) {
        if(a = c[--f], b = d[a], (b !== u[a] || !(a in u)) && a != t) {
          "[object Function]" == y.call(b) && (b.nom = a), e[a] = b
        }
      }
    }
    return e
  };
  return w.declare = x
});

//# sourceMappingURL=declare.js.map