//>>built
require({cache:{"url:dijit/form/templates/CheckBox.html":'\x3cdiv class\x3d"dijit dijitReset dijitInline" role\x3d"presentation"\n\t\x3e\x3cinput\n\t \t${!nameAttrSetting} type\x3d"${type}" role\x3d"${type}" aria-checked\x3d"false" ${checkedAttrSetting}\n\t\tclass\x3d"dijitReset dijitCheckBoxInput"\n\t\tdata-dojo-attach-point\x3d"focusNode"\n\t \tdata-dojo-attach-event\x3d"ondijitclick:_onClick"\n/\x3e\x3c/div\x3e\n'}});
define("dijit/form/CheckBox", "require dojo/_base/declare dojo/dom-attr dojo/has dojo/query dojo/ready ./ToggleButton ./_CheckBoxMixin dojo/text!./templates/CheckBox.html dojo/NodeList-dom ../a11yclick".split(" "), function(c, d, l, e, a, f, g, h, k) {
  e("dijit-legacy-requires") && f(0, function() {
    c(["dijit/form/RadioButton"])
  });
  return d("dijit.form.CheckBox", [g, h], {templateString:k, baseClass:"dijitCheckBox", _setValueAttr:function(b, a) {
    "string" == typeof b && (this.inherited(arguments), b = !0);
    this._created && this.set("checked", b, a)
  }, _getValueAttr:function() {
    return this.checked && this._get("value")
  }, _setIconClassAttr:null, _setNameAttr:"focusNode", postMixInProperties:function() {
    this.inherited(arguments);
    this.checkedAttrSetting = ""
  }, _fillContent:function() {
  }, _onFocus:function() {
    this.id && a("label[for\x3d'" + this.id + "']").addClass("dijitFocusedLabel");
    this.inherited(arguments)
  }, _onBlur:function() {
    this.id && a("label[for\x3d'" + this.id + "']").removeClass("dijitFocusedLabel");
    this.inherited(arguments)
  }})
});

//# sourceMappingURL=CheckBox.js.map