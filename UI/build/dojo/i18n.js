//>>built
define("dojo/i18n", "./_base/kernel require ./has ./_base/array ./_base/config ./_base/lang ./_base/xhr ./json module".split(" "), function(h, l, q, v, A, r, s, B, C) {
  q.add("dojo-preload-i18n-Api", 1);
  s = h.i18n = {};
  var D = /(^.*(^|\/)nls)(\/|$)([^\/]*)\/?([^\/]*)/, E = function(a, c, b, e) {
    var f = [b + e];
    c = c.split("-");
    for(var n = "", k = 0;k < c.length;k++) {
      if(n += (n ? "-" : "") + c[k], !a || a[n]) {
        f.push(b + n + "/" + e), f.specificity = n
      }
    }
    return f
  }, m = {}, y = function(a, c, b) {
    b = b ? b.toLowerCase() : h.locale;
    a = a.replace(/\./g, "/");
    c = c.replace(/\./g, "/");
    return/root/i.test(b) ? a + "/nls/" + c : a + "/nls/" + b + "/" + c
  }, F = h.getL10nName = function(a, c, b) {
    return C.id + "!" + y(a, c, b)
  }, H = function(a, c, b, e, f, n) {
    a([c], function(k) {
      var d = r.clone(k.root || k.ROOT), u = E(!k._v1x && k, f, b, e);
      a(u, function() {
        for(var a = 1;a < u.length;a++) {
          d = r.mixin(r.clone(d), arguments[a])
        }
        m[c + "/" + f] = d;
        d.$locale = u.specificity;
        n()
      })
    })
  }, I = function(a) {
    var c = A.extraLocale || [], c = r.isArray(c) ? c : [c];
    c.push(a);
    return c
  }, x = function(a, c, b) {
    if(q("dojo-preload-i18n-Api")) {
      var e = a.split("*"), f = "preload" == e[1];
      f && (m[a] || (m[a] = 1, J(e[2], B.parse(e[3]), 1, c)), b(1));
      if(!(e = f)) {
        t && w.push([a, c, b]), e = t
      }
      if(e) {
        return
      }
    }
    a = D.exec(a);
    var d = a[1] + "/", k = a[5] || a[4], l = d + k, e = (a = a[5] && a[4]) || h.locale || "", u = l + "/" + e;
    a = a ? [e] : I(e);
    var G = a.length, z = function() {
      --G || b(r.delegate(m[u]))
    };
    v.forEach(a, function(a) {
      var b = l + "/" + a;
      q("dojo-preload-i18n-Api") && g(b);
      m[b] ? z() : H(c, l, d, k, a, z)
    })
  };
  if(q("dojo-unit-tests")) {
    var K = s.unitTests = []
  }
  q("dojo-preload-i18n-Api");
  var L = s.normalizeLocale = function(a) {
    a = a ? a.toLowerCase() : h.locale;
    return"root" == a ? "ROOT" : a
  }, t = 0, w = [], J = s._preloadLocalizations = function(a, c, b, e) {
    function d(a, c) {
      e([a], c)
    }
    function n(a, c) {
      for(var b = a.split("-");b.length;) {
        if(c(b.join("-"))) {
          return
        }
        b.pop()
      }
      c("ROOT")
    }
    function k() {
      for(--t;!t && w.length;) {
        x.apply(null, w.shift())
      }
    }
    function g(b) {
      b = L(b);
      n(b, function(g) {
        if(0 <= v.indexOf(c, g)) {
          var h = a.replace(/\./g, "/") + "_" + g;
          t++;
          d(h, function(a) {
            for(var c in a) {
              var d = a[c], f = c.match(/(.+)\/([^\/]+)$/), h;
              if(f) {
                h = f[2];
                f = f[1] + "/";
                d._localized = d._localized || {};
                var p;
                if("ROOT" === g) {
                  var q = p = d._localized;
                  delete d._localized;
                  q.root = d;
                  m[l.toAbsMid(c)] = q
                }else {
                  p = d._localized, m[l.toAbsMid(f + h + "/" + g)] = d
                }
                g !== b && function(a, c, d, f) {
                  var g = [], h = [];
                  n(b, function(b) {
                    f[b] && (g.push(l.toAbsMid(a + b + "/" + c)), h.push(l.toAbsMid(a + c + "/" + b)))
                  });
                  g.length ? (t++, e(g, function() {
                    for(var e = 0;e < g.length;e++) {
                      d = r.mixin(r.clone(d), arguments[e]), m[h[e]] = d
                    }
                    m[l.toAbsMid(a + c + "/" + b)] = r.clone(d);
                    k()
                  })) : m[l.toAbsMid(a + c + "/" + b)] = d
                }(f, h, d, p)
              }
            }
            k()
          });
          return!0
        }
        return!1
      })
    }
    e = e || l;
    g();
    v.forEach(h.config.extraLocale, g)
  }, g = function() {
  }, d = {}, p = new Function("__bundle", "__checkForLegacyModules", "__mid", "__amdValue", "var define \x3d function(mid, factory){define.called \x3d 1; __amdValue.result \x3d factory || mid;},\t   require \x3d function(){define.called \x3d 1;};try{define.called \x3d 0;eval(__bundle);if(define.called\x3d\x3d1)return __amdValue;if((__checkForLegacyModules \x3d __checkForLegacyModules(__mid)))return __checkForLegacyModules;}catch(e){}try{return eval('('+__bundle+')');}catch(e){return e;}"), g = function(a) {
    for(var c, b = a.split("/"), d = h.global[b[0]], f = 1;d && f < b.length - 1;d = d[b[f++]]) {
    }
    d && ((c = d[b[f]]) || (c = d[b[f].replace(/-/g, "_")]), c && (m[a] = c));
    return c
  };
  s.getLocalization = function(a, c, b) {
    var d;
    a = y(a, c, b);
    x(a, l, function(a) {
      d = a
    });
    return d
  };
  q("dojo-unit-tests") && K.push(function(a) {
    a.register("tests.i18n.unit", function(a) {
      var b;
      b = p("{prop:1}", g, "nonsense", d);
      a.is({prop:1}, b);
      a.is(void 0, b[1]);
      b = p("({prop:1})", g, "nonsense", d);
      a.is({prop:1}, b);
      a.is(void 0, b[1]);
      b = p("{'prop-x':1}", g, "nonsense", d);
      a.is({"prop-x":1}, b);
      a.is(void 0, b[1]);
      b = p("({'prop-x':1})", g, "nonsense", d);
      a.is({"prop-x":1}, b);
      a.is(void 0, b[1]);
      b = p("define({'prop-x':1})", g, "nonsense", d);
      a.is(d, b);
      a.is({"prop-x":1}, d.result);
      b = p("define('some/module', {'prop-x':1})", g, "nonsense", d);
      a.is(d, b);
      a.is({"prop-x":1}, d.result);
      b = p("this is total nonsense and should throw an error", g, "nonsense", d);
      a.is(b instanceof Error, !0)
    })
  });
  return r.mixin(s, {dynamic:!0, normalize:function(a, c) {
    return/^\./.test(a) ? c(a) : a
  }, load:x, cache:m, getL10nName:F})
});

//# sourceMappingURL=i18n.js.map