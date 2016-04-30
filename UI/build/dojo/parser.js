//>>built
define("dojo/parser", "require ./_base/kernel ./_base/lang ./_base/array ./_base/config ./dom ./_base/window ./_base/url ./aspect ./promise/all ./date/stamp ./Deferred ./has ./query ./on ./ready".split(" "), function(D, z, u, x, M, N, O, P, J, Q, R, E, K, L, S, T) {
  function F(b) {
    return eval("(" + b + ")")
  }
  function U(b) {
    var a = b._nameCaseMap, d = b.prototype;
    if(!a || a._extendCnt < A) {
      var a = b._nameCaseMap = {}, f;
      for(f in d) {
        "_" !== f.charAt(0) && (a[f.toLowerCase()] = f)
      }
      a._extendCnt = A
    }
    return a
  }
  function G(b, a) {
    var d = b.join();
    if(!y[d]) {
      for(var f = [], c = 0, k = b.length;c < k;c++) {
        var r = b[c];
        f[f.length] = y[r] = y[r] || u.getObject(r) || ~r.indexOf("/") && (a ? a(r) : D(r))
      }
      c = f.shift();
      y[d] = f.length ? c.createSubclass ? c.createSubclass(f) : c.extend.apply(c, f) : c
    }
    return y[d]
  }
  new Date("X");
  var A = 0;
  J.after(u, "extend", function() {
    A++
  }, !0);
  var y = {}, I = {_clearCache:function() {
    A++;
    y = {}
  }, _functionFromScript:function(b, a) {
    var d = "", f = "", c = b.getAttribute(a + "args") || b.getAttribute("args"), k = b.getAttribute("with"), c = (c || "").split(/\s*,\s*/);
    k && k.length && x.forEach(k.split(/\s*,\s*/), function(a) {
      d += "with(" + a + "){";
      f += "}"
    });
    return new Function(c, d + b.innerHTML + f)
  }, instantiate:function(b, a, d) {
    a = a || {};
    d = d || {};
    var f = (d.scope || z._scopeName) + "Type", c = "data-" + (d.scope || z._scopeName) + "-", k = c + "type", r = c + "mixins", q = [];
    x.forEach(b, function(b) {
      var d = f in a ? a[f] : b.getAttribute(k) || b.getAttribute(f);
      if(d) {
        var c = b.getAttribute(r), d = c ? [d].concat(c.split(/\s*,\s*/)) : [d];
        q.push({node:b, types:d})
      }
    });
    return this._instantiate(q, a, d)
  }, _instantiate:function(b, a, d, f) {
    function c(b) {
      !a._started && !d.noStart && x.forEach(b, function(a) {
        "function" === typeof a.startup && !a._started && a.startup()
      });
      return b
    }
    b = x.map(b, function(b) {
      var c = b.ctor || G(b.types, d.contextRequire);
      if(!c) {
        throw Error("Unable to resolve constructor for: '" + b.types.join() + "'");
      }
      return this.construct(c, b.node, a, d, b.scripts, b.inherited)
    }, this);
    return f ? Q(b).then(c) : c(b)
  }, construct:function(b, a, d, f, c, k) {
    function r(a) {
      v && u.setObject(v, a);
      for(l = 0;l < w.length;l++) {
        J[w[l].advice || "after"](a, w[l].method, u.hitch(a, w[l].func), !0)
      }
      for(l = 0;l < H.length;l++) {
        H[l].call(a)
      }
      for(l = 0;l < B.length;l++) {
        a.watch(B[l].prop, B[l].func)
      }
      for(l = 0;l < C.length;l++) {
        S(a, C[l].event, C[l].func)
      }
      return a
    }
    var q = b && b.prototype;
    f = f || {};
    var n = {};
    f.defaults && u.mixin(n, f.defaults);
    k && u.mixin(n, k);
    var s;
    K("dom-attributes-explicit") ? s = a.attributes : K("dom-attributes-specified-flag") ? s = x.filter(a.attributes, function(a) {
      return a.specified
    }) : (k = (/^input$|^img$/i.test(a.nodeName) ? a : a.cloneNode(!1)).outerHTML.replace(/=[^\s"']+|="[^"]*"|='[^']*'/g, "").replace(/^\s*<[a-zA-Z0-9]*\s*/, "").replace(/\s*>.*$/, ""), s = x.map(k.split(/\s+/), function(b) {
      var d = b.toLowerCase();
      return{name:b, value:"LI" == a.nodeName && "value" == b || "enctype" == d ? a.getAttribute(d) : a.getAttributeNode(d).value}
    }));
    var h = f.scope || z._scopeName;
    k = "data-" + h + "-";
    var e = {};
    "dojo" !== h && (e[k + "props"] = "data-dojo-props", e[k + "type"] = "data-dojo-type", e[k + "mixins"] = "data-dojo-mixins", e[h + "type"] = "dojoType", e[k + "id"] = "data-dojo-id");
    for(var l = 0, g, h = [], v, p;g = s[l++];) {
      var m = g.name, t = m.toLowerCase();
      g = g.value;
      switch(e[t] || t) {
        case "data-dojo-type":
        ;
        case "dojotype":
        ;
        case "data-dojo-mixins":
          break;
        case "data-dojo-props":
          p = g;
          break;
        case "data-dojo-id":
        ;
        case "jsid":
          v = g;
          break;
        case "data-dojo-attach-point":
        ;
        case "dojoattachpoint":
          n.dojoAttachPoint = g;
          break;
        case "data-dojo-attach-event":
        ;
        case "dojoattachevent":
          n.dojoAttachEvent = g;
          break;
        case "class":
          n["class"] = a.className;
          break;
        case "style":
          n.style = a.style && a.style.cssText;
          break;
        default:
          if(m in q || (m = U(b)[t] || m), m in q) {
            switch(typeof q[m]) {
              case "string":
                n[m] = g;
                break;
              case "number":
                n[m] = g.length ? Number(g) : NaN;
                break;
              case "boolean":
                n[m] = "false" != g.toLowerCase();
                break;
              case "function":
                "" === g || -1 != g.search(/[^\w\.]+/i) ? n[m] = new Function(g) : n[m] = u.getObject(g, !1) || new Function(g);
                h.push(m);
                break;
              default:
                t = q[m], n[m] = t && "length" in t ? g ? g.split(/\s*,\s*/) : [] : t instanceof Date ? "" == g ? new Date("") : "now" == g ? new Date : R.fromISOString(g) : t instanceof P ? z.baseUrl + g : F(g)
            }
          }else {
            n[m] = g
          }
      }
    }
    for(s = 0;s < h.length;s++) {
      e = h[s].toLowerCase(), a.removeAttribute(e), a[e] = null
    }
    if(p) {
      try {
        p = F.call(f.propsThis, "{" + p + "}"), u.mixin(n, p)
      }catch(y) {
        throw Error(y.toString() + " in data-dojo-props\x3d'" + p + "'");
      }
    }
    u.mixin(n, d);
    c || (c = b && (b._noScript || q._noScript) ? [] : L("\x3e script[type^\x3d'dojo/']", a));
    var w = [], H = [], B = [], C = [];
    if(c) {
      for(l = 0;l < c.length;l++) {
        e = c[l], a.removeChild(e), d = e.getAttribute(k + "event") || e.getAttribute("event"), f = e.getAttribute(k + "prop"), p = e.getAttribute(k + "method"), h = e.getAttribute(k + "advice"), s = e.getAttribute("type"), e = this._functionFromScript(e, k), d ? "dojo/connect" == s ? w.push({method:d, func:e}) : "dojo/on" == s ? C.push({event:d, func:e}) : n[d] = e : "dojo/aspect" == s ? w.push({method:p, advice:h, func:e}) : "dojo/watch" == s ? B.push({prop:f, func:e}) : H.push(e)
      }
    }
    b = (c = b.markupFactory || q.markupFactory) ? c(n, a, b) : new b(n, a);
    return b.then ? b.then(r) : r(b)
  }, scan:function(b, a) {
    function d(a) {
      if(!a.inherited) {
        a.inherited = {};
        var b = a.node, c = d(a.parent), b = {dir:b.getAttribute("dir") || c.dir, lang:b.getAttribute("lang") || c.lang, textDir:b.getAttribute(s) || c.textDir}, e;
        for(e in b) {
          b[e] && (a.inherited[e] = b[e])
        }
      }
      return a.inherited
    }
    var f = [], c = [], k = {}, r = (a.scope || z._scopeName) + "Type", q = "data-" + (a.scope || z._scopeName) + "-", n = q + "type", s = q + "textdir", q = q + "mixins", h = b.firstChild, e = a.inherited;
    if(!e) {
      var l = function(a, b) {
        return a.getAttribute && a.getAttribute(b) || a.parentNode && l(a.parentNode, b)
      }, e = {dir:l(b, "dir"), lang:l(b, "lang"), textDir:l(b, s)}, g;
      for(g in e) {
        e[g] || delete e[g]
      }
    }
    for(var e = {inherited:e}, v, p;;) {
      if(h) {
        if(1 != h.nodeType) {
          h = h.nextSibling
        }else {
          if(v && "script" == h.nodeName.toLowerCase()) {
            (m = h.getAttribute("type")) && /^dojo\/\w/i.test(m) && v.push(h), h = h.nextSibling
          }else {
            if(p) {
              h = h.nextSibling
            }else {
              var m = h.getAttribute(n) || h.getAttribute(r);
              g = h.firstChild;
              if(!m && (!g || 3 == g.nodeType && !g.nextSibling)) {
                h = h.nextSibling
              }else {
                p = null;
                if(m) {
                  var t = h.getAttribute(q);
                  v = t ? [m].concat(t.split(/\s*,\s*/)) : [m];
                  try {
                    p = G(v, a.contextRequire)
                  }catch(u) {
                  }
                  p || x.forEach(v, function(a) {
                    ~a.indexOf("/") && !k[a] && (k[a] = !0, c[c.length] = a)
                  });
                  t = p && !p.prototype._noScript ? [] : null;
                  e = {types:v, ctor:p, parent:e, node:h, scripts:t};
                  e.inherited = d(e);
                  f.push(e)
                }else {
                  e = {node:h, scripts:v, parent:e}
                }
                v = t;
                p = h.stopParser || p && p.prototype.stopParser && !a.template;
                h = g
              }
            }
          }
        }
      }else {
        if(!e || !e.node) {
          break
        }
        h = e.node.nextSibling;
        p = !1;
        e = e.parent;
        v = e.scripts
      }
    }
    var w = new E;
    c.length ? (a.contextRequire || D)(c, function() {
      w.resolve(x.filter(f, function(b) {
        if(!b.ctor) {
          try {
            b.ctor = G(b.types, a.contextRequire)
          }catch(d) {
          }
        }
        for(var c = b.parent;c && !c.types;) {
          c = c.parent
        }
        var e = b.ctor && b.ctor.prototype;
        b.instantiateChildren = !(e && e.stopParser && !a.template);
        b.instantiate = !c || c.instantiate && c.instantiateChildren;
        return b.instantiate
      }))
    }) : w.resolve(f);
    return w.promise
  }, _require:function(b, a) {
    var d = F("{" + b.innerHTML + "}"), f = [], c = [], k = new E, r = a && a.contextRequire || D, q;
    for(q in d) {
      f.push(q), c.push(d[q])
    }
    r(c, function() {
      for(var a = 0;a < f.length;a++) {
        u.setObject(f[a], arguments[a])
      }
      k.resolve(arguments)
    });
    return k.promise
  }, _scanAmd:function(b, a) {
    var d = new E, f = d.promise;
    d.resolve(!0);
    var c = this;
    L("script[type\x3d'dojo/require']", b).forEach(function(b) {
      f = f.then(function() {
        return c._require(b, a)
      });
      b.parentNode.removeChild(b)
    });
    return f
  }, parse:function(b, a) {
    var d;
    !a && b && b.rootNode ? (a = b, d = a.rootNode) : b && u.isObject(b) && !("nodeType" in b) ? a = b : d = b;
    d = d ? N.byId(d) : O.body();
    a = a || {};
    var f = a.template ? {template:!0} : {}, c = [], k = this, r = this._scanAmd(d, a).then(function() {
      return k.scan(d, a)
    }).then(function(b) {
      return k._instantiate(b, f, a, !0)
    }).then(function(a) {
      return c = c.concat(a)
    }).otherwise(function(a) {
      console.error("dojo/parser::parse() error", a);
      throw a;
    });
    u.mixin(c, r);
    return c
  }};
  z.parser = I;
  M.parseOnLoad && T(100, I, "parse");
  return I
});

//# sourceMappingURL=parser.js.map