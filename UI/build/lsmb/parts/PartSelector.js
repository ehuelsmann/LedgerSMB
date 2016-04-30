//>>built
define("lsmb/parts/PartSelector", ["dijit/form/FilteringSelect", "dojo/_base/declare", "dojo/aspect", "dojo/topic", "lsmb/parts/PartStore"], function(c, e, f, g, d) {
  c = new e("lsmb/parts/PartSelector", [c], {store:d, queryExpr:"*${0}*", style:"width: 15ex", highlightMatch:"all", searchAttr:"text", labelAttr:"label", autoComplete:!1, initialValue:null, linenum:null, constructor:function() {
    this.inherited(arguments);
    this.initialValue = arguments[0].value
  }, postCreate:function() {
    var a = this;
    this.inherited(arguments);
    d.emitter.on("partstore_loadcomplete", function() {
      a.set("value", a.initialValue)
    })
  }, startup:function() {
    var a = this;
    this.inherited(arguments);
    this.on("change", function(b) {
      g.publish("/invoice/part-select/" + a.linenum, a.store.get(b))
    })
  }});
  f.around(c, "_announceOption", function(a) {
    return function(b) {
      this.searchAttr = "label";
      b = a.call(this, b);
      this.searchAttr = "text";
      return b
    }
  });
  return c
});

//# sourceMappingURL=PartSelector.js.map