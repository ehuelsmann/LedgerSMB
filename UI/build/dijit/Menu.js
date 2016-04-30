//>>built
define("dijit/Menu", "require dojo/_base/array dojo/_base/declare dojo/dom dojo/dom-attr dojo/dom-geometry dojo/dom-style dojo/keys dojo/_base/lang dojo/on dojo/sniff dojo/_base/window dojo/window ./popup ./DropDownMenu dojo/ready".split(" "), function(v, k, w, p, g, q, s, t, u, l, f, h, x, r, y, z) {
  f("dijit-legacy-requires") && z(0, function() {
    v(["dijit/MenuItem", "dijit/PopupMenuItem", "dijit/CheckedMenuItem", "dijit/MenuSeparator"])
  });
  return w("dijit.Menu", y, {constructor:function() {
    this._bindings = []
  }, targetNodeIds:[], selector:"", contextMenuForWindow:!1, leftClickToOpen:!1, refocus:!0, postCreate:function() {
    this.contextMenuForWindow ? this.bindDomNode(this.ownerDocumentBody) : k.forEach(this.targetNodeIds, this.bindDomNode, this);
    this.inherited(arguments)
  }, _iframeContentWindow:function(a) {
    return x.get(this._iframeContentDocument(a)) || this._iframeContentDocument(a).__parent__ || a.name && document.frames[a.name] || null
  }, _iframeContentDocument:function(a) {
    return a.contentDocument || a.contentWindow && a.contentWindow.document || a.name && document.frames[a.name] && document.frames[a.name].document || null
  }, bindDomNode:function(a) {
    a = p.byId(a, this.ownerDocument);
    var d;
    if("iframe" == a.tagName.toLowerCase()) {
      var e = a;
      d = this._iframeContentWindow(e);
      d = h.body(d.document)
    }else {
      d = a == h.body(this.ownerDocument) ? this.ownerDocument.documentElement : a
    }
    var b = {node:a, iframe:e};
    g.set(a, "_dijitMenu" + this.id, this._bindings.push(b));
    var c = u.hitch(this, function(a) {
      var b = this.selector, c = b ? function(a) {
        return l.selector(b, a)
      } : function(a) {
        return a
      }, d = this;
      return[l(a, c(this.leftClickToOpen ? "click" : "contextmenu"), function(a) {
        a.stopPropagation();
        a.preventDefault();
        (new Date).getTime() < this._lastKeyDown + 500 || d._scheduleOpen(this, e, {x:a.pageX, y:a.pageY}, a.target)
      }), l(a, c("keydown"), function(a) {
        if(93 == a.keyCode || a.shiftKey && a.keyCode == t.F10 || this.leftClickToOpen && a.keyCode == t.SPACE) {
          a.stopPropagation(), a.preventDefault(), d._scheduleOpen(this, e, null, a.target), this._lastKeyDown = (new Date).getTime()
        }
      })]
    });
    b.connects = d ? c(d) : [];
    e && (b.onloadHandler = u.hitch(this, function() {
      var a = this._iframeContentWindow(e), a = h.body(a.document);
      b.connects = c(a)
    }), e.addEventListener ? e.addEventListener("load", b.onloadHandler, !1) : e.attachEvent("onload", b.onloadHandler))
  }, unBindDomNode:function(a) {
    var d;
    try {
      d = p.byId(a, this.ownerDocument)
    }catch(e) {
      return
    }
    a = "_dijitMenu" + this.id;
    if(d && g.has(d, a)) {
      for(var b = g.get(d, a) - 1, c = this._bindings[b], f;f = c.connects.pop();) {
        f.remove()
      }
      (f = c.iframe) && (f.removeEventListener ? f.removeEventListener("load", c.onloadHandler, !1) : f.detachEvent("onload", c.onloadHandler));
      g.remove(d, a);
      delete this._bindings[b]
    }
  }, _scheduleOpen:function(a, d, e, b) {
    this._openTimer || (this._openTimer = this.defer(function() {
      delete this._openTimer;
      this._openMyself({target:b, delegatedTarget:a, iframe:d, coords:e})
    }, 1))
  }, _openMyself:function(a) {
    function d() {
      h.refocus && k && k.focus();
      r.close(h)
    }
    var e = a.target, b = a.iframe, c = a.coords, g = !c;
    this.currentTarget = a.delegatedTarget;
    if(c) {
      if(b) {
        a = q.position(b, !0);
        var e = this._iframeContentWindow(b), e = q.docScroll(e.document), m = s.getComputedStyle(b), n = s.toPixelValue, l = (f("ie") && f("quirks") ? 0 : n(b, m.paddingLeft)) + (f("ie") && f("quirks") ? n(b, m.borderLeftWidth) : 0), b = (f("ie") && f("quirks") ? 0 : n(b, m.paddingTop)) + (f("ie") && f("quirks") ? n(b, m.borderTopWidth) : 0);
        c.x += a.x + l - e.x;
        c.y += a.y + b - e.y
      }
    }else {
      c = q.position(e, !0), c.x += 10, c.y += 10
    }
    var h = this, b = this._focusManager.get("prevNode");
    a = this._focusManager.get("curNode");
    var k = !a || p.isDescendant(a, this.domNode) ? b : a;
    r.open({popup:this, x:c.x, y:c.y, onExecute:d, onCancel:d, orient:this.isLeftToRight() ? "L" : "R"});
    this.focus();
    g || this.defer(function() {
      this._cleanUp(!0)
    });
    this._onBlur = function() {
      this.inherited("_onBlur", arguments);
      r.close(this)
    }
  }, destroy:function() {
    k.forEach(this._bindings, function(a) {
      a && this.unBindDomNode(a.node)
    }, this);
    this.inherited(arguments)
  }})
});

//# sourceMappingURL=Menu.js.map