//>>built
require({cache:{"url:dijit/form/templates/Button.html":'\x3cspan class\x3d"dijit dijitReset dijitInline" role\x3d"presentation"\n\t\x3e\x3cspan class\x3d"dijitReset dijitInline dijitButtonNode"\n\t\tdata-dojo-attach-event\x3d"ondijitclick:__onClick" role\x3d"presentation"\n\t\t\x3e\x3cspan class\x3d"dijitReset dijitStretch dijitButtonContents"\n\t\t\tdata-dojo-attach-point\x3d"titleNode,focusNode"\n\t\t\trole\x3d"button" aria-labelledby\x3d"${id}_label"\n\t\t\t\x3e\x3cspan class\x3d"dijitReset dijitInline dijitIcon" data-dojo-attach-point\x3d"iconNode"\x3e\x3c/span\n\t\t\t\x3e\x3cspan class\x3d"dijitReset dijitToggleButtonIconChar"\x3e\x26#x25CF;\x3c/span\n\t\t\t\x3e\x3cspan class\x3d"dijitReset dijitInline dijitButtonText"\n\t\t\t\tid\x3d"${id}_label"\n\t\t\t\tdata-dojo-attach-point\x3d"containerNode"\n\t\t\t\x3e\x3c/span\n\t\t\x3e\x3c/span\n\t\x3e\x3c/span\n\t\x3e\x3cinput ${!nameAttrSetting} type\x3d"${type}" value\x3d"${value}" class\x3d"dijitOffScreen"\n\t\tdata-dojo-attach-event\x3d"onclick:_onClick"\n\t\ttabIndex\x3d"-1" role\x3d"presentation" aria-hidden\x3d"true" data-dojo-attach-point\x3d"valueNode"\n/\x3e\x3c/span\x3e\n'}});
define("dijit/form/Button", "require dojo/_base/declare dojo/dom-class dojo/has dojo/_base/kernel dojo/_base/lang dojo/ready ./_FormWidget ./_ButtonMixin dojo/text!./templates/Button.html ../a11yclick".split(" "), function(f, d, g, c, h, e, b, k, l, m) {
  c("dijit-legacy-requires") && b(0, function() {
    f(["dijit/form/DropDownButton", "dijit/form/ComboButton", "dijit/form/ToggleButton"])
  });
  b = d("dijit.form.Button" + (c("dojo-bidi") ? "_NoBidi" : ""), [k, l], {showLabel:!0, iconClass:"dijitNoIcon", _setIconClassAttr:{node:"iconNode", type:"class"}, baseClass:"dijitButton", templateString:m, _setValueAttr:"valueNode", _setNameAttr:function(a) {
    this.valueNode && this.valueNode.setAttribute("name", a)
  }, _fillContent:function(a) {
    if(a && (!this.params || !("label" in this.params))) {
      if(a = e.trim(a.innerHTML)) {
        this.label = a
      }
    }
  }, _setShowLabelAttr:function(a) {
    this.containerNode && g.toggle(this.containerNode, "dijitDisplayNone", !a);
    this._set("showLabel", a)
  }, setLabel:function(a) {
    h.deprecated("dijit.form.Button.setLabel() is deprecated.  Use set('label', ...) instead.", "", "2.0");
    this.set("label", a)
  }, _setLabelAttr:function(a) {
    this.inherited(arguments);
    !this.showLabel && !("title" in this.params) && (this.titleNode.title = e.trim(this.containerNode.innerText || this.containerNode.textContent || ""))
  }});
  c("dojo-bidi") && (b = d("dijit.form.Button", b, {_setLabelAttr:function(a) {
    this.inherited(arguments);
    this.titleNode.title && this.applyTextDir(this.titleNode, this.titleNode.title)
  }, _setTextDirAttr:function(a) {
    this._created && this.textDir != a && (this._set("textDir", a), this._setLabelAttr(this.label))
  }}));
  return b
});

//# sourceMappingURL=Button.js.map