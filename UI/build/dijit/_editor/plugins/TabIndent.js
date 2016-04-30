//>>built
define("dijit/_editor/plugins/TabIndent", ["dojo/_base/declare", "dojo/_base/kernel", "../_Plugin", "../../form/ToggleButton"], function(c, d, a, e) {
  d.experimental("dijit._editor.plugins.TabIndent");
  var b = c("dijit._editor.plugins.TabIndent", a, {useDefaultCommand:!1, buttonClass:e, command:"tabIndent", _initButton:function() {
    this.inherited(arguments);
    var f = this.editor;
    this.own(this.button.on("change", function(a) {
      f.set("isTabIndent", a)
    }));
    this.updateState()
  }, updateState:function() {
    var a = this.get("disabled");
    this.button.set("disabled", a);
    a || this.button.set("checked", this.editor.isTabIndent, !1)
  }});
  a.registry.tabIndent = function() {
    return new b({command:"tabIndent"})
  };
  return b
});

//# sourceMappingURL=TabIndent.js.map