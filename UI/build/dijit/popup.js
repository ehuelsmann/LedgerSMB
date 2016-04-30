//>>built
define("dijit/popup", "dojo/_base/array dojo/aspect dojo/_base/declare dojo/dom dojo/dom-attr dojo/dom-construct dojo/dom-geometry dojo/dom-style dojo/has dojo/keys dojo/_base/lang dojo/on ./place ./BackgroundIframe ./Viewport ./main".split(" "), function(v, w, e, x, y, r, k, p, z, s, m, t, u, A, B, C) {
  function D() {
    this._popupWrapper && (r.destroy(this._popupWrapper), delete this._popupWrapper)
  }
  e = e(null, {_stack:[], _beginZIndex:1E3, _idGen:1, _repositionAll:function() {
    if(this._firstAroundNode) {
      var a = this._firstAroundPosition, c = k.position(this._firstAroundNode, !0), b = c.x - a.x, a = c.y - a.y;
      if(b || a) {
        this._firstAroundPosition = c;
        for(c = 0;c < this._stack.length;c++) {
          var d = this._stack[c].wrapper.style;
          d.top = parseFloat(d.top) + a + "px";
          "auto" == d.right ? d.left = parseFloat(d.left) + b + "px" : d.right = parseFloat(d.right) - b + "px"
        }
      }
      this._aroundMoveListener = setTimeout(m.hitch(this, "_repositionAll"), b || a ? 10 : 50)
    }
  }, _createWrapper:function(a) {
    var c = a._popupWrapper, b = a.domNode;
    c || (c = r.create("div", {"class":"dijitPopup", style:{display:"none"}, role:"region", "aria-label":a["aria-label"] || a.label || a.name || a.id}, a.ownerDocumentBody), c.appendChild(b), b = b.style, b.display = "", b.visibility = "", b.position = "", b.top = "0px", a._popupWrapper = c, w.after(a, "destroy", D, !0), "ontouchend" in document && t(c, "touchend", function(a) {
      /^(input|button|textarea)$/i.test(a.target.tagName) || a.preventDefault()
    }));
    return c
  }, moveOffScreen:function(a) {
    var c = this._createWrapper(a);
    a = k.isBodyLtr(a.ownerDocument);
    var b = {visibility:"hidden", top:"-9999px", display:""};
    b[a ? "left" : "right"] = "-9999px";
    b[a ? "right" : "left"] = "auto";
    p.set(c, b);
    return c
  }, hide:function(a) {
    var c = this._createWrapper(a);
    p.set(c, {display:"none", height:"auto", overflow:"visible", border:""});
    a = a.domNode;
    "_originalStyle" in a && (a.style.cssText = a._originalStyle)
  }, getTopPopup:function() {
    for(var a = this._stack, c = a.length - 1;0 < c && a[c].parent === a[c - 1].widget;c--) {
    }
    return a[c]
  }, open:function(a) {
    for(var c = this._stack, b = a.popup, d = b.domNode, f = a.orient || ["below", "below-alt", "above", "above-alt"], E = a.parent ? a.parent.isLeftToRight() : k.isBodyLtr(b.ownerDocument), h = a.around, q = a.around && a.around.id ? a.around.id + "_dropdown" : "popup_" + this._idGen++;c.length && (!a.parent || !x.isDescendant(a.parent.domNode, c[c.length - 1].widget.domNode));) {
      this.close(c[c.length - 1].widget)
    }
    var g = this.moveOffScreen(b);
    b.startup && !b._started && b.startup();
    var l, n = k.position(d);
    if("maxHeight" in a && -1 != a.maxHeight) {
      l = a.maxHeight || Infinity
    }else {
      l = B.getEffectiveBox(this.ownerDocument);
      var e = h ? k.position(h, !1) : {y:a.y - (a.padding || 0), h:2 * (a.padding || 0)};
      l = Math.floor(Math.max(e.y, l.h - (e.y + e.h)))
    }
    n.h > l && (n = p.getComputedStyle(d), p.set(g, {overflowY:"scroll", height:l + "px", border:n.borderLeftWidth + " " + n.borderLeftStyle + " " + n.borderLeftColor}), d._originalStyle = d.style.cssText, d.style.border = "none");
    y.set(g, {id:q, style:{zIndex:this._beginZIndex + c.length}, "class":"dijitPopup " + (b.baseClass || b["class"] || "").split(" ")[0] + "Popup", dijitPopupParent:a.parent ? a.parent.id : ""});
    0 == c.length && h && (this._firstAroundNode = h, this._firstAroundPosition = k.position(h, !0), this._aroundMoveListener = setTimeout(m.hitch(this, "_repositionAll"), 50));
    z("config-bgIframe") && !b.bgIframe && (b.bgIframe = new A(g));
    q = b.orient ? m.hitch(b, "orient") : null;
    f = h ? u.around(g, h, f, E, q) : u.at(g, a, "R" == f ? ["TR", "BR", "TL", "BL"] : ["TL", "BL", "TR", "BR"], a.padding, q);
    g.style.visibility = "visible";
    d.style.visibility = "visible";
    d = [];
    d.push(t(g, "keydown", m.hitch(this, function(b) {
      if(b.keyCode == s.ESCAPE && a.onCancel) {
        b.stopPropagation(), b.preventDefault(), a.onCancel()
      }else {
        if(b.keyCode == s.TAB && (b.stopPropagation(), b.preventDefault(), (b = this.getTopPopup()) && b.onCancel)) {
          b.onCancel()
        }
      }
    })));
    b.onCancel && a.onCancel && d.push(b.on("cancel", a.onCancel));
    d.push(b.on(b.onExecute ? "execute" : "change", m.hitch(this, function() {
      var a = this.getTopPopup();
      if(a && a.onExecute) {
        a.onExecute()
      }
    })));
    c.push({widget:b, wrapper:g, parent:a.parent, onExecute:a.onExecute, onCancel:a.onCancel, onClose:a.onClose, handlers:d});
    if(b.onOpen) {
      b.onOpen(f)
    }
    return f
  }, close:function(a) {
    for(var c = this._stack;a && v.some(c, function(b) {
      return b.widget == a
    }) || !a && c.length;) {
      var b = c.pop(), d = b.widget, f = b.onClose;
      d.bgIframe && (d.bgIframe.destroy(), delete d.bgIframe);
      if(d.onClose) {
        d.onClose()
      }
      for(var e;e = b.handlers.pop();) {
        e.remove()
      }
      d && d.domNode && this.hide(d);
      f && f()
    }
    0 == c.length && this._aroundMoveListener && (clearTimeout(this._aroundMoveListener), this._firstAroundNode = this._firstAroundPosition = this._aroundMoveListener = null)
  }});
  return C.popup = new e
});

//# sourceMappingURL=popup.js.map