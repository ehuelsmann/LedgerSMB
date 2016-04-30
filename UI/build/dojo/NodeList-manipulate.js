//>>built
define("dojo/NodeList-manipulate", "./query ./_base/lang ./_base/array ./dom-construct ./dom-attr ./NodeList-dom".split(" "), function(l, m, s, p, q) {
  function r(a) {
    for(;a.childNodes[0] && 1 == a.childNodes[0].nodeType;) {
      a = a.childNodes[0]
    }
    return a
  }
  function n(a, b) {
    "string" == typeof a ? (a = p.toDom(a, b && b.ownerDocument), 11 == a.nodeType && (a = a.childNodes[0])) : 1 == a.nodeType && a.parentNode && (a = a.cloneNode(!1));
    return a
  }
  var f = l.NodeList;
  m.extend(f, {_placeMultiple:function(a, b) {
    for(var c = "string" == typeof a || a.nodeType ? l(a) : a, d = [], g = 0;g < c.length;g++) {
      for(var e = c[g], f = this.length, h = f - 1, k;k = this[h];h--) {
        0 < g && (k = this._cloneNode(k), d.unshift(k)), h == f - 1 ? p.place(k, e, b) : e.parentNode.insertBefore(k, e), e = k
      }
    }
    d.length && (d.unshift(0), d.unshift(this.length - 1), Array.prototype.splice.apply(this, d));
    return this
  }, innerHTML:function(a) {
    return arguments.length ? this.addContent(a, "only") : this[0].innerHTML
  }, text:function(a) {
    if(arguments.length) {
      for(var b = 0, c;c = this[b];b++) {
        1 == c.nodeType && q.set(c, "textContent", a)
      }
      return this
    }
    for(var d = "", b = 0;c = this[b];b++) {
      d += q.get(c, "textContent")
    }
    return d
  }, val:function(a) {
    if(arguments.length) {
      for(var b = m.isArray(a), c = 0, d;d = this[c];c++) {
        var g = d.nodeName.toUpperCase(), e = d.type, f = b ? a[c] : a;
        if("SELECT" == g) {
          g = d.options;
          for(e = 0;e < g.length;e++) {
            var h = g[e];
            h.selected = d.multiple ? -1 != s.indexOf(a, h.value) : h.value == f
          }
        }else {
          "checkbox" == e || "radio" == e ? d.checked = d.value == f : d.value = f
        }
      }
      return this
    }
    if((d = this[0]) && 1 == d.nodeType) {
      a = d.value || "";
      if("SELECT" == d.nodeName.toUpperCase() && d.multiple) {
        a = [];
        g = d.options;
        for(e = 0;e < g.length;e++) {
          h = g[e], h.selected && a.push(h.value)
        }
        a.length || (a = null)
      }
      return a
    }
  }, append:function(a) {
    return this.addContent(a, "last")
  }, appendTo:function(a) {
    return this._placeMultiple(a, "last")
  }, prepend:function(a) {
    return this.addContent(a, "first")
  }, prependTo:function(a) {
    return this._placeMultiple(a, "first")
  }, after:function(a) {
    return this.addContent(a, "after")
  }, insertAfter:function(a) {
    return this._placeMultiple(a, "after")
  }, before:function(a) {
    return this.addContent(a, "before")
  }, insertBefore:function(a) {
    return this._placeMultiple(a, "before")
  }, remove:f.prototype.orphan, wrap:function(a) {
    if(this[0]) {
      a = n(a, this[0]);
      for(var b = 0, c;c = this[b];b++) {
        var d = this._cloneNode(a);
        c.parentNode && c.parentNode.replaceChild(d, c);
        r(d).appendChild(c)
      }
    }
    return this
  }, wrapAll:function(a) {
    if(this[0]) {
      a = n(a, this[0]);
      this[0].parentNode.replaceChild(a, this[0]);
      a = r(a);
      for(var b = 0, c;c = this[b];b++) {
        a.appendChild(c)
      }
    }
    return this
  }, wrapInner:function(a) {
    if(this[0]) {
      a = n(a, this[0]);
      for(var b = 0;b < this.length;b++) {
        var c = this._cloneNode(a);
        this._wrap(m._toArray(this[b].childNodes), null, this._NodeListCtor).wrapAll(c)
      }
    }
    return this
  }, replaceWith:function(a) {
    a = this._normalize(a, this[0]);
    for(var b = 0, c;c = this[b];b++) {
      this._place(a, c, "before", 0 < b), c.parentNode.removeChild(c)
    }
    return this
  }, replaceAll:function(a) {
    a = l(a);
    for(var b = this._normalize(this, this[0]), c = 0, d;d = a[c];c++) {
      this._place(b, d, "before", 0 < c), d.parentNode.removeChild(d)
    }
    return this
  }, clone:function() {
    for(var a = [], b = 0;b < this.length;b++) {
      a.push(this._cloneNode(this[b]))
    }
    return this._wrap(a, this, this._NodeListCtor)
  }});
  f.prototype.html || (f.prototype.html = f.prototype.innerHTML);
  return f
});

//# sourceMappingURL=NodeList-manipulate.js.map