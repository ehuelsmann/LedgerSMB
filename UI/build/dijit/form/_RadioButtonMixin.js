//>>built
define("dijit/form/_RadioButtonMixin", "dojo/_base/array dojo/_base/declare dojo/dom-attr dojo/_base/lang dojo/query!css2 ../registry".split(" "), function(d, e, f, c, g, h) {
  return e("dijit.form._RadioButtonMixin", null, {type:"radio", _getRelatedWidgets:function() {
    var a = [];
    g("input[type\x3dradio]", this.focusNode.form || this.ownerDocument).forEach(c.hitch(this, function(b) {
      b.name == this.name && b.form == this.focusNode.form && (b = h.getEnclosingWidget(b)) && a.push(b)
    }));
    return a
  }, _setCheckedAttr:function(a) {
    this.inherited(arguments);
    this._created && a && d.forEach(this._getRelatedWidgets(), c.hitch(this, function(a) {
      a != this && a.checked && a.set("checked", !1)
    }))
  }, _getSubmitValue:function(a) {
    return null == a ? "on" : a
  }, _onClick:function(a) {
    return this.checked || this.disabled ? (a.stopPropagation(), a.preventDefault(), !1) : this.readOnly ? (a.stopPropagation(), a.preventDefault(), d.forEach(this._getRelatedWidgets(), c.hitch(this, function(a) {
      f.set(this.focusNode || this.domNode, "checked", a.checked)
    })), !1) : this.inherited(arguments)
  }})
});

//# sourceMappingURL=_RadioButtonMixin.js.map