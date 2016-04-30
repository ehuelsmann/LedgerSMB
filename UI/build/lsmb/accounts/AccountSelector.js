//>>built
define("lsmb/accounts/AccountSelector", ["dijit/form/FilteringSelect", "dojo/_base/declare", "lsmb/accounts/AccountStore"], function(c, d, a) {
  return new d("lsmb/accounts/AccountSelector", [c], {store:a, queryExpr:"*${0}*", style:"width: 300px", query:{charttype:"A"}, highlightMatch:"all", searchAttr:"text", autoComplete:!1, initialValue:null, constructor:function() {
    this.inherited(arguments);
    this.initialValue = arguments[0].value
  }, postCreate:function() {
    var b = this;
    this.inherited(arguments);
    a.emitter.on("accountstore_loadcomplete", function() {
      b.set("value", b.initialValue)
    })
  }})
});

//# sourceMappingURL=AccountSelector.js.map