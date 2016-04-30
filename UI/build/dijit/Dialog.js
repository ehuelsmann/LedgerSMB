//>>built
require({cache:{"url:dijit/templates/Dialog.html":'\x3cdiv class\x3d"dijitDialog" role\x3d"dialog" aria-labelledby\x3d"${id}_title"\x3e\n\t\x3cdiv data-dojo-attach-point\x3d"titleBar" class\x3d"dijitDialogTitleBar"\x3e\n\t\t\x3cspan data-dojo-attach-point\x3d"titleNode" class\x3d"dijitDialogTitle" id\x3d"${id}_title"\n\t\t\t\trole\x3d"heading" level\x3d"1"\x3e\x3c/span\x3e\n\t\t\x3cspan data-dojo-attach-point\x3d"closeButtonNode" class\x3d"dijitDialogCloseIcon" data-dojo-attach-event\x3d"ondijitclick: onCancel" title\x3d"${buttonCancel}" role\x3d"button" tabindex\x3d"-1"\x3e\n\t\t\t\x3cspan data-dojo-attach-point\x3d"closeText" class\x3d"closeText" title\x3d"${buttonCancel}"\x3ex\x3c/span\x3e\n\t\t\x3c/span\x3e\n\t\x3c/div\x3e\n\t\x3cdiv data-dojo-attach-point\x3d"containerNode" class\x3d"dijitDialogPaneContent"\x3e\x3c/div\x3e\n\t${!actionBarTemplate}\n\x3c/div\x3e\n\n'}});
define("dijit/Dialog", "require dojo/_base/array dojo/aspect dojo/_base/declare dojo/Deferred dojo/dom dojo/dom-class dojo/dom-geometry dojo/dom-style dojo/_base/fx dojo/i18n dojo/keys dojo/_base/lang dojo/on dojo/ready dojo/sniff dojo/window dojo/dnd/Moveable dojo/dnd/TimedMoveable ./focus ./_base/manager ./_Widget ./_TemplatedMixin ./_CssStateMixin ./form/_FormMixin ./_DialogMixin ./DialogUnderlay ./layout/ContentPane ./layout/utils dojo/text!./templates/Dialog.html ./a11yclick dojo/i18n!./nls/common".split(" "), 
function(B, k, r, s, t, C, u, p, l, y, D, z, e, A, E, m, q, F, G, f, g, N, H, I, J, K, v, L, w, M) {
  var x = new t;
  x.resolve(!0);
  g = s("dijit._DialogBase" + (m("dojo-bidi") ? "_NoBidi" : ""), [H, J, K, I], {templateString:M, baseClass:"dijitDialog", cssStateNodes:{closeButtonNode:"dijitDialogCloseIcon"}, _setTitleAttr:{node:"titleNode", type:"innerHTML"}, open:!1, duration:g.defaultDuration, refocus:!0, autofocus:!0, _firstFocusItem:null, _lastFocusItem:null, draggable:!0, _setDraggableAttr:function(a) {
    this._set("draggable", a)
  }, maxRatio:0.9, closable:!0, _setClosableAttr:function(a) {
    this.closeButtonNode.style.display = a ? "" : "none";
    this._set("closable", a)
  }, postMixInProperties:function() {
    var a = D.getLocalization("dijit", "common");
    e.mixin(this, a);
    this.inherited(arguments)
  }, postCreate:function() {
    l.set(this.domNode, {display:"none", position:"absolute"});
    this.ownerDocumentBody.appendChild(this.domNode);
    this.inherited(arguments);
    r.after(this, "onExecute", e.hitch(this, "hide"), !0);
    r.after(this, "onCancel", e.hitch(this, "hide"), !0);
    this._modalconnects = []
  }, onLoad:function() {
    this.resize();
    this._position();
    this.autofocus && h.isTop(this) && (this._getFocusItems(), f.focus(this._firstFocusItem));
    this.inherited(arguments)
  }, focus:function() {
    this._getFocusItems();
    f.focus(this._firstFocusItem)
  }, _endDrag:function() {
    var a = p.position(this.domNode), b = q.getBox(this.ownerDocument);
    a.y = Math.min(Math.max(a.y, 0), b.h - a.h);
    a.x = Math.min(Math.max(a.x, 0), b.w - a.w);
    this._relativePosition = a;
    this._position()
  }, _setup:function() {
    var a = this.domNode;
    this.titleBar && this.draggable ? (this._moveable = new (6 == m("ie") ? G : F)(a, {handle:this.titleBar}), r.after(this._moveable, "onMoveStop", e.hitch(this, "_endDrag"), !0)) : u.add(a, "dijitDialogFixed");
    this.underlayAttrs = {dialogId:this.id, "class":k.map(this["class"].split(/\s/), function(a) {
      return a + "_underlay"
    }).join(" "), _onKeyDown:e.hitch(this, "_onKey"), ownerDocument:this.ownerDocument}
  }, _size:function() {
    this.resize()
  }, _position:function() {
    if(!u.contains(this.ownerDocumentBody, "dojoMove")) {
      var a = this.domNode, b = q.getBox(this.ownerDocument), c = this._relativePosition, d = c ? null : p.position(a);
      l.set(a, {left:Math.floor(b.l + (c ? c.x : (b.w - d.w) / 2)) + "px", top:Math.floor(b.t + (c ? c.y : (b.h - d.h) / 2)) + "px"})
    }
  }, _onKey:function(a) {
    if(a.keyCode == z.TAB) {
      this._getFocusItems();
      var b = a.target;
      this._firstFocusItem == this._lastFocusItem ? (a.stopPropagation(), a.preventDefault()) : b == this._firstFocusItem && a.shiftKey ? (f.focus(this._lastFocusItem), a.stopPropagation(), a.preventDefault()) : b == this._lastFocusItem && !a.shiftKey && (f.focus(this._firstFocusItem), a.stopPropagation(), a.preventDefault())
    }else {
      this.closable && a.keyCode == z.ESCAPE && (this.onCancel(), a.stopPropagation(), a.preventDefault())
    }
  }, show:function() {
    if(this.open) {
      return x.promise
    }
    this._started || this.startup();
    this._alreadyInitialized || (this._setup(), this._alreadyInitialized = !0);
    this._fadeOutDeferred && (this._fadeOutDeferred.cancel(), h.hide(this));
    var a = q.get(this.ownerDocument);
    this._modalconnects.push(A(a, "scroll", e.hitch(this, "resize", null)));
    this._modalconnects.push(A(this.domNode, "keydown", e.hitch(this, "_onKey")));
    l.set(this.domNode, {opacity:0, display:""});
    this._set("open", !0);
    this._onShow();
    this.resize();
    this._position();
    var b;
    this._fadeInDeferred = new t(e.hitch(this, function() {
      b.stop();
      delete this._fadeInDeferred
    }));
    a = this._fadeInDeferred.promise;
    b = y.fadeIn({node:this.domNode, duration:this.duration, beforeBegin:e.hitch(this, function() {
      h.show(this, this.underlayAttrs)
    }), onEnd:e.hitch(this, function() {
      this.autofocus && h.isTop(this) && (this._getFocusItems(), f.focus(this._firstFocusItem));
      this._fadeInDeferred.resolve(!0);
      delete this._fadeInDeferred
    })}).play();
    return a
  }, hide:function() {
    if(!this._alreadyInitialized || !this.open) {
      return x.promise
    }
    this._fadeInDeferred && this._fadeInDeferred.cancel();
    var a;
    this._fadeOutDeferred = new t(e.hitch(this, function() {
      a.stop();
      delete this._fadeOutDeferred
    }));
    this._fadeOutDeferred.then(e.hitch(this, "onHide"));
    var b = this._fadeOutDeferred.promise;
    a = y.fadeOut({node:this.domNode, duration:this.duration, onEnd:e.hitch(this, function() {
      this.domNode.style.display = "none";
      h.hide(this);
      this._fadeOutDeferred.resolve(!0);
      delete this._fadeOutDeferred
    })}).play();
    this._scrollConnected && (this._scrollConnected = !1);
    for(var c;c = this._modalconnects.pop();) {
      c.remove()
    }
    this._relativePosition && delete this._relativePosition;
    this._set("open", !1);
    return b
  }, resize:function(a) {
    if("none" != this.domNode.style.display) {
      this._checkIfSingleChild();
      if(!a) {
        this._shrunk && (this._singleChild && "undefined" != typeof this._singleChildOriginalStyle && (this._singleChild.domNode.style.cssText = this._singleChildOriginalStyle, delete this._singleChildOriginalStyle), k.forEach([this.domNode, this.containerNode, this.titleBar, this.actionBarNode], function(a) {
          a && l.set(a, {position:"static", width:"auto", height:"auto"})
        }), this.domNode.style.position = "absolute");
        var b = q.getBox(this.ownerDocument);
        b.w *= this.maxRatio;
        b.h *= this.maxRatio;
        var c = p.position(this.domNode);
        c.w >= b.w || c.h >= b.h ? (a = {w:Math.min(c.w, b.w), h:Math.min(c.h, b.h)}, this._shrunk = !0) : this._shrunk = !1
      }
      if(a) {
        p.setMarginBox(this.domNode, a);
        b = [];
        this.titleBar && b.push({domNode:this.titleBar, region:"top"});
        this.actionBarNode && b.push({domNode:this.actionBarNode, region:"bottom"});
        c = {domNode:this.containerNode, region:"center"};
        b.push(c);
        var d = w.marginBox2contentBox(this.domNode, a);
        w.layoutChildren(this.domNode, d, b);
        this._singleChild ? (b = w.marginBox2contentBox(this.containerNode, c), this._singleChild.resize({w:b.w, h:b.h})) : (this.containerNode.style.overflow = "auto", this._layoutChildren())
      }else {
        this._layoutChildren()
      }
      !m("touch") && !a && this._position()
    }
  }, _layoutChildren:function() {
    k.forEach(this.getChildren(), function(a) {
      a.resize && a.resize()
    })
  }, destroy:function() {
    this._fadeInDeferred && this._fadeInDeferred.cancel();
    this._fadeOutDeferred && this._fadeOutDeferred.cancel();
    this._moveable && this._moveable.destroy();
    for(var a;a = this._modalconnects.pop();) {
      a.remove()
    }
    h.hide(this);
    this.inherited(arguments)
  }});
  m("dojo-bidi") && (g = s("dijit._DialogBase", g, {_setTitleAttr:function(a) {
    this._set("title", a);
    this.titleNode.innerHTML = a;
    this.applyTextDir(this.titleNode)
  }, _setTextDirAttr:function(a) {
    this._created && this.textDir != a && (this._set("textDir", a), this.set("title", this.title))
  }}));
  var n = s("dijit.Dialog", [L, g], {});
  n._DialogBase = g;
  var h = n._DialogLevelManager = {_beginZIndex:950, show:function(a, b) {
    d[d.length - 1].focus = f.curNode;
    var c = d[d.length - 1].dialog ? d[d.length - 1].zIndex + 2 : n._DialogLevelManager._beginZIndex;
    l.set(a.domNode, "zIndex", c);
    v.show(b, c - 1);
    d.push({dialog:a, underlayAttrs:b, zIndex:c})
  }, hide:function(a) {
    if(d[d.length - 1].dialog == a) {
      d.pop();
      var b = d[d.length - 1];
      1 == d.length ? v.hide() : v.show(b.underlayAttrs, b.zIndex - 1);
      if(a.refocus) {
        a = b.focus;
        if(b.dialog && (!a || !C.isDescendant(a, b.dialog.domNode))) {
          b.dialog._getFocusItems(), a = b.dialog._firstFocusItem
        }
        if(a) {
          try {
            a.focus()
          }catch(c) {
          }
        }
      }
    }else {
      b = k.indexOf(k.map(d, function(a) {
        return a.dialog
      }), a), -1 != b && d.splice(b, 1)
    }
  }, isTop:function(a) {
    return d[d.length - 1].dialog == a
  }}, d = n._dialogStack = [{dialog:null, focus:null, underlayAttrs:null}];
  f.watch("curNode", function(a, b, c) {
    a = d[d.length - 1].dialog;
    if(c && a && !a._fadeOutDeferred && c.ownerDocument == a.ownerDocument) {
      do {
        if(c == a.domNode || u.contains(c, "dijitPopup")) {
          return
        }
      }while(c = c.parentNode);
      a.focus()
    }
  });
  m("dijit-legacy-requires") && E(0, function() {
    B(["dijit/TooltipDialog"])
  });
  return n
});

//# sourceMappingURL=Dialog.js.map