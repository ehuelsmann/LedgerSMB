//>>built
define("dijit/_WidgetsInTemplateMixin", ["dojo/_base/array", "dojo/aspect", "dojo/_base/declare", "dojo/_base/lang", "dojo/parser"], function(e, k, f, g, h) {
  return f("dijit._WidgetsInTemplateMixin", null, {_earlyTemplatedStartup:!1, widgetsInTemplate:!0, contextRequire:null, _beforeFillContent:function() {
    if(this.widgetsInTemplate) {
      var a = this.domNode;
      this.containerNode && !this.searchContainerNode && (this.containerNode.stopParser = !0);
      h.parse(a, {noStart:!this._earlyTemplatedStartup, template:!0, inherited:{dir:this.dir, lang:this.lang, textDir:this.textDir}, propsThis:this, contextRequire:this.contextRequire, scope:"dojo"}).then(g.hitch(this, function(a) {
        this._startupWidgets = a;
        for(var b = 0;b < a.length;b++) {
          this._processTemplateNode(a[b], function(a, c) {
            return a[c]
          }, function(a, c, b) {
            return c in a ? a.connect(a, c, b) : a.on(c, b, !0)
          })
        }
        this.containerNode && this.containerNode.stopParser && delete this.containerNode.stopParser
      }));
      if(!this._startupWidgets) {
        throw Error(this.declaredClass + ": parser returned unfilled promise (probably waiting for module auto-load), unsupported by _WidgetsInTemplateMixin.   Must pre-load all supporting widgets before instantiation.");
      }
    }
  }, _processTemplateNode:function(a, d, b) {
    return d(a, "dojoType") || d(a, "data-dojo-type") ? !0 : this.inherited(arguments)
  }, startup:function() {
    e.forEach(this._startupWidgets, function(a) {
      a && (!a._started && a.startup) && a.startup()
    });
    this._startupWidgets = null;
    this.inherited(arguments)
  }})
});

//# sourceMappingURL=_WidgetsInTemplateMixin.js.map