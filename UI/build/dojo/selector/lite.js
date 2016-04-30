//>>built
define("dojo/selector/lite", ["../has", "../_base/kernel"], function(k, p) {
  var g = document.createElement("div"), l = g.matches || g.webkitMatchesSelector || g.mozMatchesSelector || g.msMatchesSelector || g.oMatchesSelector, q = g.querySelectorAll, s = /([^\s,](?:"(?:\\.|[^"])+"|'(?:\\.|[^'])+'|[^,])*)/g;
  k.add("dom-matches-selector", !!l);
  k.add("dom-qsa", !!q);
  var n = function(f, a) {
    if(t && -1 < f.indexOf(",")) {
      return t(f, a)
    }
    var c = a ? a.ownerDocument || a : p.doc || document, b = (q ? /^([\w]*)#([\w\-]+$)|^(\.)([\w\-\*]+$)|^(\w+$)/ : /^([\w]*)#([\w\-]+)(?:\s+(.*))?$|(?:^|(>|.+\s+))([\w\-\*]+)(\S*$)/).exec(f);
    a = a || c;
    if(b) {
      if(b[2]) {
        var d = p.byId ? p.byId(b[2], c) : c.getElementById(b[2]);
        if(!d || b[1] && b[1] != d.tagName.toLowerCase()) {
          return[]
        }
        if(a != c) {
          for(c = d;c != a;) {
            if(c = c.parentNode, !c) {
              return[]
            }
          }
        }
        return b[3] ? n(b[3], d) : [d]
      }
      if(b[3] && a.getElementsByClassName) {
        return a.getElementsByClassName(b[4])
      }
      if(b[5]) {
        if(d = a.getElementsByTagName(b[5]), b[4] || b[6]) {
          f = (b[4] || "") + b[6]
        }else {
          return d
        }
      }
    }
    if(q) {
      return 1 === a.nodeType && "object" !== a.nodeName.toLowerCase() ? u(a, f, a.querySelectorAll) : a.querySelectorAll(f)
    }
    d || (d = a.getElementsByTagName("*"));
    for(var b = [], c = 0, m = d.length;c < m;c++) {
      var h = d[c];
      1 == h.nodeType && v(h, f, a) && b.push(h)
    }
    return b
  }, u = function(f, a, c) {
    var b = f, d = f.getAttribute("id"), m = d || "__dojo__", h = f.parentNode, g = /^\s*[+~]/.test(a);
    if(g && !h) {
      return[]
    }
    d ? m = m.replace(/'/g, "\\$\x26") : f.setAttribute("id", m);
    g && h && (f = f.parentNode);
    a = a.match(s);
    for(h = 0;h < a.length;h++) {
      a[h] = "[id\x3d'" + m + "'] " + a[h]
    }
    a = a.join(",");
    try {
      return c.call(f, a)
    }finally {
      d || b.removeAttribute("id")
    }
  };
  if(!k("dom-matches-selector")) {
    var v = function() {
      function f(r, e, a) {
        var b = e.charAt(0);
        if('"' == b || "'" == b) {
          e = e.slice(1, -1)
        }
        e = e.replace(/\\/g, "");
        var c = h[a || ""];
        return function(a) {
          return(a = a.getAttribute(r)) && c(a, e)
        }
      }
      function a(a) {
        return function(e, b) {
          for(;(e = e.parentNode) != b;) {
            if(a(e, b)) {
              return!0
            }
          }
        }
      }
      function c(a) {
        return function(e, b) {
          e = e.parentNode;
          return a ? e != b && a(e, b) : e == b
        }
      }
      function b(a, e) {
        return a ? function(b, c) {
          return e(b) && a(b, c)
        } : e
      }
      var d = "div" == g.tagName ? "toLowerCase" : "toUpperCase", m = {"":function(a) {
        a = a[d]();
        return function(b) {
          return b.tagName == a
        }
      }, ".":function(a) {
        var b = " " + a + " ";
        return function(c) {
          return-1 < c.className.indexOf(a) && -1 < (" " + c.className + " ").indexOf(b)
        }
      }, "#":function(a) {
        return function(b) {
          return b.id == a
        }
      }}, h = {"^\x3d":function(a, b) {
        return 0 == a.indexOf(b)
      }, "*\x3d":function(a, b) {
        return-1 < a.indexOf(b)
      }, "$\x3d":function(a, b) {
        return a.substring(a.length - b.length, a.length) == b
      }, "~\x3d":function(a, b) {
        return-1 < (" " + a + " ").indexOf(" " + b + " ")
      }, "|\x3d":function(a, b) {
        return 0 == (a + "-").indexOf(b + "-")
      }, "\x3d":function(a, b) {
        return a == b
      }, "":function(a, b) {
        return!0
      }}, k = {};
      return function(d, e, h) {
        var g = k[e];
        if(!g) {
          if(e.replace(/(?:\s*([> ])\s*)|(#|\.)?((?:\\.|[\w-])+)|\[\s*([\w-]+)\s*(.?=)?\s*("(?:\\.|[^"])+"|'(?:\\.|[^'])+'|(?:\\.|[^\]])*)\s*\]/g, function(d, e, h, k, l, n, r) {
            k ? g = b(g, m[h || ""](k.replace(/\\/g, ""))) : e ? g = (" " == e ? a : c)(g) : l && (g = b(g, f(l, r, n)));
            return""
          })) {
            throw Error("Syntax error in query");
          }
          if(!g) {
            return!0
          }
          k[e] = g
        }
        return g(d, h)
      }
    }()
  }
  if(!k("dom-qsa")) {
    var t = function(f, a) {
      for(var c = f.match(s), b = [], d = 0;d < c.length;d++) {
        f = new String(c[d].replace(/\s*$/, ""));
        f.indexOf = escape;
        for(var g = n(f, a), h = 0, k = g.length;h < k;h++) {
          var l = g[h];
          b[l.sourceIndex] = l
        }
      }
      c = [];
      for(d in b) {
        c.push(b[d])
      }
      return c
    }
  }
  n.match = l ? function(f, a, c) {
    return c && 9 != c.nodeType ? u(c, a, function(a) {
      return l.call(f, a)
    }) : l.call(f, a)
  } : v;
  return n
});

//# sourceMappingURL=lite.js.map