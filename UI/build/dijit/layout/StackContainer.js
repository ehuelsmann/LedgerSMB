//>>built
define("dijit/layout/StackContainer", "dojo/_base/array dojo/cookie dojo/_base/declare dojo/dom-class dojo/dom-construct dojo/has dojo/_base/lang dojo/on dojo/ready dojo/topic dojo/when ../registry ../_WidgetBase ./_LayoutWidget".split(" "), function(d, k, e, g, h, n, l, p, q, f, r, m, s, t) {
  n("dijit-legacy-requires") && q(0, function() {
    require(["dijit/layout/StackController"])
  });
  e = e("dijit.layout.StackContainer", t, {doLayout:!0, persist:!1, baseClass:"dijitStackContainer", buildRendering:function() {
    this.inherited(arguments);
    g.add(this.domNode, "dijitLayoutContainer")
  }, postCreate:function() {
    this.inherited(arguments);
    this.own(p(this.domNode, "keydown", l.hitch(this, "_onKeyDown")))
  }, startup:function() {
    if(!this._started) {
      var a = this.getChildren();
      d.forEach(a, this._setupChild, this);
      this.persist ? this.selectedChildWidget = m.byId(k(this.id + "_selectedChild")) : d.some(a, function(a) {
        a.selected && (this.selectedChildWidget = a);
        return a.selected
      }, this);
      var b = this.selectedChildWidget;
      !b && a[0] && (b = this.selectedChildWidget = a[0], b.selected = !0);
      f.publish(this.id + "-startup", {children:a, selected:b, textDir:this.textDir});
      this.inherited(arguments)
    }
  }, resize:function() {
    if(!this._hasBeenShown) {
      this._hasBeenShown = !0;
      var a = this.selectedChildWidget;
      a && this._showChild(a)
    }
    this.inherited(arguments)
  }, _setupChild:function(a) {
    var b = a.domNode, c = h.place("\x3cdiv role\x3d'tabpanel' class\x3d'" + this.baseClass + "ChildWrapper dijitHidden'\x3e", a.domNode, "replace"), d = a["aria-label"] || a.title || a.label;
    d && c.setAttribute("aria-label", d);
    h.place(b, c);
    a._wrapper = c;
    this.inherited(arguments);
    "none" == b.style.display && (b.style.display = "block");
    a.domNode.removeAttribute("title")
  }, addChild:function(a, b) {
    this.inherited(arguments);
    this._started && (f.publish(this.id + "-addChild", a, b), this.layout(), this.selectedChildWidget || this.selectChild(a))
  }, removeChild:function(a) {
    var b = d.indexOf(this.getChildren(), a);
    this.inherited(arguments);
    h.destroy(a._wrapper);
    delete a._wrapper;
    this._started && f.publish(this.id + "-removeChild", a);
    if(!this._descendantsBeingDestroyed) {
      if(this.selectedChildWidget === a && (this.selectedChildWidget = void 0, this._started)) {
        var c = this.getChildren();
        c.length && this.selectChild(c[Math.max(b - 1, 0)])
      }
      this._started && this.layout()
    }
  }, selectChild:function(a, b) {
    var c;
    a = m.byId(a);
    this.selectedChildWidget != a && (c = this._transition(a, this.selectedChildWidget, b), this._set("selectedChildWidget", a), f.publish(this.id + "-selectChild", a), this.persist && k(this.id + "_selectedChild", this.selectedChildWidget.id));
    return r(c || !0)
  }, _transition:function(a, b) {
    b && this._hideChild(b);
    var c = this._showChild(a);
    a.resize && (this.doLayout ? a.resize(this._containerContentBox || this._contentBox) : a.resize());
    return c
  }, _adjacent:function(a) {
    var b = this.getChildren(), c = d.indexOf(b, this.selectedChildWidget), c = c + (a ? 1 : b.length - 1);
    return b[c % b.length]
  }, forward:function() {
    return this.selectChild(this._adjacent(!0), !0)
  }, back:function() {
    return this.selectChild(this._adjacent(!1), !0)
  }, _onKeyDown:function(a) {
    f.publish(this.id + "-containerKeyDown", {e:a, page:this})
  }, layout:function() {
    var a = this.selectedChildWidget;
    a && a.resize && (this.doLayout ? a.resize(this._containerContentBox || this._contentBox) : a.resize())
  }, _showChild:function(a) {
    var b = this.getChildren();
    a.isFirstChild = a == b[0];
    a.isLastChild = a == b[b.length - 1];
    a._set("selected", !0);
    a._wrapper && g.replace(a._wrapper, "dijitVisible", "dijitHidden");
    return a._onShow && a._onShow() || !0
  }, _hideChild:function(a) {
    a._set("selected", !1);
    a._wrapper && g.replace(a._wrapper, "dijitHidden", "dijitVisible");
    a.onHide && a.onHide()
  }, closeChild:function(a) {
    a.onClose && a.onClose(this, a) && (this.removeChild(a), a.destroyRecursive())
  }, destroyDescendants:function(a) {
    this._descendantsBeingDestroyed = !0;
    this.selectedChildWidget = void 0;
    d.forEach(this.getChildren(), function(b) {
      a || this.removeChild(b);
      b.destroyRecursive(a)
    }, this);
    this._descendantsBeingDestroyed = !1
  }});
  e.ChildWidgetProperties = {selected:!1, disabled:!1, closable:!1, iconClass:"dijitNoIcon", showTitle:!0};
  l.extend(s, e.ChildWidgetProperties);
  return e
});

//# sourceMappingURL=StackContainer.js.map