//>>built
define("dijit/Toolbar", "require dojo/_base/declare dojo/has dojo/keys dojo/ready ./_Widget ./_KeyNavContainer ./_TemplatedMixin".split(" "), function(a, b, c, h, d, e, f, g) {
  c("dijit-legacy-requires") && d(0, function() {
    a(["dijit/ToolbarSeparator"])
  });
  return b("dijit.Toolbar", [e, g, f], {templateString:'\x3cdiv class\x3d"dijit" role\x3d"toolbar" tabIndex\x3d"${tabIndex}" data-dojo-attach-point\x3d"containerNode"\x3e\x3c/div\x3e', baseClass:"dijitToolbar", _onLeftArrow:function() {
    this.focusPrev()
  }, _onRightArrow:function() {
    this.focusNext()
  }})
});

//# sourceMappingURL=Toolbar.js.map