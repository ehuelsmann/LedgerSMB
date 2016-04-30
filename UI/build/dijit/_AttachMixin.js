//>>built
define("dijit/_AttachMixin", "require dojo/_base/array dojo/_base/connect dojo/_base/declare dojo/_base/lang dojo/mouse dojo/on dojo/touch ./_WidgetBase".split(" "), function(n, d, f, p, g, l, q, r, s) {
  var t = g.delegate(r, {mouseenter:l.enter, mouseleave:l.leave, keypress:f._keypress}), m;
  f = p("dijit._AttachMixin", null, {constructor:function() {
    this._attachPoints = [];
    this._attachEvents = []
  }, buildRendering:function() {
    this.inherited(arguments);
    this._attachTemplateNodes(this.domNode);
    this._beforeFillContent()
  }, _beforeFillContent:function() {
  }, _attachTemplateNodes:function(b) {
    for(var a = b;;) {
      if(1 == a.nodeType && (this._processTemplateNode(a, function(a, b) {
        return a.getAttribute(b)
      }, this._attach) || this.searchContainerNode) && a.firstChild) {
        a = a.firstChild
      }else {
        if(a == b) {
          break
        }
        for(;!a.nextSibling;) {
          if(a = a.parentNode, a == b) {
            return
          }
        }
        a = a.nextSibling
      }
    }
  }, _processTemplateNode:function(b, a, f) {
    var d = !0, k = this.attachScope || this, c = a(b, "dojoAttachPoint") || a(b, "data-dojo-attach-point");
    if(c) {
      for(var h = c.split(/\s*,\s*/);c = h.shift();) {
        g.isArray(k[c]) ? k[c].push(b) : k[c] = b, d = "containerNode" != c, this._attachPoints.push(c)
      }
    }
    if(a = a(b, "dojoAttachEvent") || a(b, "data-dojo-attach-event")) {
      c = a.split(/\s*,\s*/);
      for(h = g.trim;a = c.shift();) {
        if(a) {
          var e = null;
          -1 != a.indexOf(":") ? (e = a.split(":"), a = h(e[0]), e = h(e[1])) : a = h(a);
          e || (e = a);
          this._attachEvents.push(f(b, a, g.hitch(k, e)))
        }
      }
    }
    return d
  }, _attach:function(b, a, d) {
    a = a.replace(/^on/, "").toLowerCase();
    a = "dijitclick" == a ? m || (m = n("./a11yclick")) : t[a] || a;
    return q(b, a, d)
  }, _detachTemplateNodes:function() {
    var b = this.attachScope || this;
    d.forEach(this._attachPoints, function(a) {
      delete b[a]
    });
    this._attachPoints = [];
    d.forEach(this._attachEvents, function(a) {
      a.remove()
    });
    this._attachEvents = []
  }, destroyRendering:function() {
    this._detachTemplateNodes();
    this.inherited(arguments)
  }});
  g.extend(s, {dojoAttachEvent:"", dojoAttachPoint:""});
  return f
});

//# sourceMappingURL=_AttachMixin.js.map