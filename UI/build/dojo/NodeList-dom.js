//>>built
define("dojo/NodeList-dom", "./_base/kernel ./query ./_base/array ./_base/lang ./dom-class ./dom-construct ./dom-geometry ./dom-attr ./dom-style".split(" "), function(k, g, v, l, n, m, p, q, w) {
  function r(a) {
    return function(b, c, d) {
      return 2 == arguments.length ? a["string" == typeof c ? "get" : "set"](b, c) : a.set(b, c, d)
    }
  }
  var s = function(a) {
    return 1 == a.length && "string" == typeof a[0]
  }, x = function(a) {
    var b = a.parentNode;
    b && b.removeChild(a)
  }, e = g.NodeList, t = e._adaptWithCondition, f = e._adaptAsForEach, u = e._adaptAsMap;
  l.extend(e, {_normalize:function(a, b) {
    var c = !0 === a.parse;
    if("string" == typeof a.template) {
      var d = a.templateFunc || k.string && k.string.substitute;
      a = d ? d(a.template, a) : a
    }
    d = typeof a;
    "string" == d || "number" == d ? (a = m.toDom(a, b && b.ownerDocument), a = 11 == a.nodeType ? l._toArray(a.childNodes) : [a]) : l.isArrayLike(a) ? l.isArray(a) || (a = l._toArray(a)) : a = [a];
    c && (a._runParse = !0);
    return a
  }, _cloneNode:function(a) {
    return a.cloneNode(!0)
  }, _place:function(a, b, c, d) {
    if(!(1 != b.nodeType && "only" == c)) {
      for(var h, g = a.length, e = g - 1;0 <= e;e--) {
        var f = d ? this._cloneNode(a[e]) : a[e];
        if(a._runParse && k.parser && k.parser.parse) {
          h || (h = b.ownerDocument.createElement("div"));
          h.appendChild(f);
          k.parser.parse(h);
          for(f = h.firstChild;h.firstChild;) {
            h.removeChild(h.firstChild)
          }
        }
        e == g - 1 ? m.place(f, b, c) : b.parentNode.insertBefore(f, b);
        b = f
      }
    }
  }, position:u(p.position), attr:t(r(q), s), style:t(r(w), s), addClass:f(n.add), removeClass:f(n.remove), toggleClass:f(n.toggle), replaceClass:f(n.replace), empty:f(m.empty), removeAttr:f(q.remove), marginBox:u(p.getMarginBox), place:function(a, b) {
    var c = g(a)[0];
    return this.forEach(function(a) {
      m.place(a, c, b)
    })
  }, orphan:function(a) {
    return(a ? g._filterResult(this, a) : this).forEach(x)
  }, adopt:function(a, b) {
    return g(a).place(this[0], b)._stash(this)
  }, query:function(a) {
    if(!a) {
      return this
    }
    var b = new e;
    this.map(function(c) {
      g(a, c).forEach(function(a) {
        void 0 !== a && b.push(a)
      })
    });
    return b._stash(this)
  }, filter:function(a) {
    var b = arguments, c = this, d = 0;
    if("string" == typeof a) {
      c = g._filterResult(this, b[0]);
      if(1 == b.length) {
        return c._stash(this)
      }
      d = 1
    }
    return this._wrap(v.filter(c, b[d], b[d + 1]), this)
  }, addContent:function(a, b) {
    a = this._normalize(a, this[0]);
    for(var c = 0, d;d = this[c];c++) {
      a.length ? this._place(a, d, b, 0 < c) : m.empty(d)
    }
    return this
  }});
  return e
});

//# sourceMappingURL=NodeList-dom.js.map