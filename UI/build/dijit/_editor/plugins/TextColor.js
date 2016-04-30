//>>built
define("dijit/_editor/plugins/TextColor", "require dojo/colors dojo/_base/declare dojo/_base/lang ../_Plugin ../../form/DropDownButton".split(" "), function(g, h, k, m, d, l) {
  var f = k("dijit._editor.plugins.TextColor", d, {buttonClass:l, colorPicker:"dijit/ColorPalette", useDefaultCommand:!1, _initButton:function() {
    this.command = this.name;
    this.inherited(arguments);
    var b = this;
    this.button.loadDropDown = function(e) {
      function c(a) {
        b.button.dropDown = new a({dir:b.editor.dir, ownerDocument:b.editor.ownerDocument, value:b.value, onChange:function(a) {
          b.editor.execCommand(b.command, a)
        }, onExecute:function() {
          b.editor.execCommand(b.command, this.get("value"))
        }});
        e()
      }
      "string" == typeof b.colorPicker ? g([b.colorPicker], c) : c(b.colorPicker)
    }
  }, updateState:function() {
    var b = this.editor, e = this.command;
    if(b && b.isLoaded && e.length) {
      if(this.button) {
        var c = this.get("disabled");
        this.button.set("disabled", c);
        if(c) {
          return
        }
        var a;
        try {
          a = b.queryCommandValue(e) || ""
        }catch(d) {
          a = ""
        }
      }
      "" == a && (a = "#000000");
      "transparent" == a && (a = "#ffffff");
      "string" == typeof a ? -1 < a.indexOf("rgb") && (a = h.fromRgb(a).toHex()) : (a = ((a & 255) << 16 | a & 65280 | (a & 16711680) >>> 16).toString(16), a = "#000000".slice(0, 7 - a.length) + a);
      this.value = a;
      (b = this.button.dropDown) && (b.get && a !== b.get("value")) && b.set("value", a, !1)
    }
  }});
  d.registry.foreColor = function(b) {
    return new f(b)
  };
  d.registry.hiliteColor = function(b) {
    return new f(b)
  };
  return f
});

//# sourceMappingURL=TextColor.js.map