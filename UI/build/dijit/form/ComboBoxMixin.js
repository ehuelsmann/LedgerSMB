//>>built
require({cache:{"url:dijit/form/templates/DropDownBox.html":'\x3cdiv class\x3d"dijit dijitReset dijitInline dijitLeft"\n\tid\x3d"widget_${id}"\n\trole\x3d"combobox"\n\taria-haspopup\x3d"true"\n\tdata-dojo-attach-point\x3d"_popupStateNode"\n\t\x3e\x3cdiv class\x3d\'dijitReset dijitRight dijitButtonNode dijitArrowButton dijitDownArrowButton dijitArrowButtonContainer\'\n\t\tdata-dojo-attach-point\x3d"_buttonNode" role\x3d"presentation"\n\t\t\x3e\x3cinput class\x3d"dijitReset dijitInputField dijitArrowButtonInner" value\x3d"\x26#9660; " type\x3d"text" tabIndex\x3d"-1" readonly\x3d"readonly" role\x3d"button presentation" aria-hidden\x3d"true"\n\t\t\t${_buttonInputDisabled}\n\t/\x3e\x3c/div\n\t\x3e\x3cdiv class\x3d\'dijitReset dijitValidationContainer\'\n\t\t\x3e\x3cinput class\x3d"dijitReset dijitInputField dijitValidationIcon dijitValidationInner" value\x3d"\x26#935; " type\x3d"text" tabIndex\x3d"-1" readonly\x3d"readonly" role\x3d"presentation"\n\t/\x3e\x3c/div\n\t\x3e\x3cdiv class\x3d"dijitReset dijitInputField dijitInputContainer"\n\t\t\x3e\x3cinput class\x3d\'dijitReset dijitInputInner\' ${!nameAttrSetting} type\x3d"text" autocomplete\x3d"off"\n\t\t\tdata-dojo-attach-point\x3d"textbox,focusNode" role\x3d"textbox"\n\t/\x3e\x3c/div\n\x3e\x3c/div\x3e\n'}});
define("dijit/form/ComboBoxMixin", "dojo/_base/declare dojo/Deferred dojo/_base/kernel dojo/_base/lang dojo/store/util/QueryResults ./_AutoCompleterMixin ./_ComboBoxMenu ../_HasDropDown dojo/text!./templates/DropDownBox.html".split(" "), function(g, c, d, f, h, k, l, m, n) {
  return g("dijit.form.ComboBoxMixin", [m, k], {dropDownClass:l, hasDownArrow:!0, templateString:n, baseClass:"dijitTextBox dijitComboBox", cssStateNodes:{_buttonNode:"dijitDownArrowButton"}, _setHasDownArrowAttr:function(a) {
    this._set("hasDownArrow", a);
    this._buttonNode.style.display = a ? "" : "none"
  }, _showResultList:function() {
    this.displayMessage("");
    this.inherited(arguments)
  }, _setStoreAttr:function(a) {
    a.get || f.mixin(a, {_oldAPI:!0, get:function(a) {
      var e = new c;
      this.fetchItemByIdentity({identity:a, onItem:function(b) {
        e.resolve(b)
      }, onError:function(b) {
        e.reject(b)
      }});
      return e.promise
    }, query:function(a, e) {
      var b = new c(function() {
        d.abort && d.abort()
      });
      b.total = new c;
      var d = this.fetch(f.mixin({query:a, onBegin:function(a) {
        b.total.resolve(a)
      }, onComplete:function(a) {
        b.resolve(a)
      }, onError:function(a) {
        b.reject(a)
      }}, e));
      return h(b)
    }});
    this._set("store", a)
  }, postMixInProperties:function() {
    var a = this.params.store || this.store;
    a && this._setStoreAttr(a);
    this.inherited(arguments);
    if(!this.params.store && this.store && !this.store._oldAPI) {
      var c = this.declaredClass;
      f.mixin(this.store, {getValue:function(a, b) {
        d.deprecated(c + ".store.getValue(item, attr) is deprecated for builtin store.  Use item.attr directly", "", "2.0");
        return a[b]
      }, getLabel:function(a) {
        d.deprecated(c + ".store.getLabel(item) is deprecated for builtin store.  Use item.label directly", "", "2.0");
        return a.name
      }, fetch:function(a) {
        d.deprecated(c + ".store.fetch() is deprecated for builtin store.", "Use store.query()", "2.0");
        require(["dojo/data/ObjectStore"], f.hitch(this, function(b) {
          (new b({objectStore:this})).fetch(a)
        }))
      }})
    }
  }, buildRendering:function() {
    this.inherited(arguments);
    this.focusNode.setAttribute("aria-autocomplete", this.autoComplete ? "both" : "list")
  }})
});

//# sourceMappingURL=ComboBoxMixin.js.map