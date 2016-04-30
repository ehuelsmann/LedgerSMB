//>>built
define("lsmb/MainContentPane", "dijit/layout/ContentPane dojo/_base/declare dojo/_base/event dijit/registry dojo/dom-style dojo/_base/lang dojo/promise/Promise dojo/on dojo/promise/all dojo/request/xhr dojo/query dojo/dom-class".split(" "), function(h, k, l, m, d, f, e, n, p, q, r, g) {
  return k("lsmb/MainContentPane", [h], {last_page:null, set_main_div:function(a) {
    var b = this;
    a = a.match(/<body[^>]*>([\s\S]*)<\/body>/i)[1];
    this.destroyDescendants();
    return this.set("content", a).then(function() {
      b.show_main_div()
    })
  }, load_form:function(a, b) {
    var c = this;
    c.fade_main_div();
    return q(a, b).then(function(a) {
      c.hide_main_div();
      c.set_main_div(a)
    }, function(a) {
      c.show_main_div();
      var b = m.byId("errorDialog");
      0 == a.response.status ? b.set("content", "Could not connect to server") : b.set("content", a.response.data);
      b.show()
    })
  }, load_link:function(a) {
    if(this.last_page != a) {
      return this.last_page = a, this.load_form(a, {handlesAs:"text"})
    }
  }, fade_main_div:function() {
    d.set(this.domNode, "opacity", "30%");
    g.replace(this.domNode, "parsing", "done-parsing")
  }, hide_main_div:function() {
    d.set(this.domNode, "visibility", "hidden");
    g.replace(this.domNode, "done-parsing", "parsing")
  }, show_main_div:function() {
    d.set(this.domNode, "visibility", "visible")
  }, _patchAtags:function() {
    var a = this;
    r("a", a.domNode).forEach(function(b) {
      !b.target && b.href && a.own(n(b, "click", function(c) {
        l.stop(c);
        a.load_link(b.href)
      }))
    })
  }, set:function() {
    var a = null, b = 0, c = null, d = this;
    1 == arguments.length && f.isObject(arguments[0]) && null !== arguments[0].content ? (a = arguments[0].content, delete arguments[0].content) : 1 == arguments.length && f.isString(arguments[0]) ? (a = arguments[0], b = !0) : 2 == arguments.length && "content" == arguments[0] && (a = arguments[1], b = !0);
    null !== a && (c = this.inherited("set", arguments, ["content", a]).then(function() {
      d._patchAtags();
      d.show_main_div()
    }));
    if(b) {
      return c
    }
    a = this.inherited(arguments);
    return null !== c && c instanceof e && null !== a && a instanceof e ? p([c, a]) : null !== c && c instanceof e ? c : a
  }})
});

//# sourceMappingURL=MainContentPane.js.map