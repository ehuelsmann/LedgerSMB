//>>built
define("lsmb/Form", "dijit/form/Form dojo/_base/declare dojo/_base/event dojo/on dojo/dom-attr dojo/dom-form dojo/query dijit/registry".split(" "), function(f, g, h, k, l, m, n, d) {
  return g("lsmb/Form", [f], {clickedAction:null, startup:function() {
    var a = this;
    this.inherited(arguments);
    n('input[type\x3d"submit"]', this.domNode).forEach(function(b) {
      k(b, "click", function() {
        a.clickedAction = l.get(b, "value")
      })
    })
  }, onSubmit:function(a) {
    h.stop(a);
    this.submit()
  }, submit:function() {
    if(this.validate()) {
      var a = this.method, b = m.toQuery(this.domNode), b = "action\x3d" + this.clickedAction + "\x26" + b;
      void 0 == a && (a = "GET");
      var e = this.action, c = {handleAs:"text"};
      "get" == a.toLowerCase() ? d.byId("maindiv").load_link(e + "?" + b) : (c.method = a, c.data = b, d.byId("maindiv").load_form(e, c))
    }
  }})
});

//# sourceMappingURL=Form.js.map