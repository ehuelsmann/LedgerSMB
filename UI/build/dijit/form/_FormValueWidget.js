//>>built
define("dijit/form/_FormValueWidget", ["dojo/_base/declare", "dojo/sniff", "./_FormWidget", "./_FormValueMixin"], function(c, f, g, h) {
  return c("dijit.form._FormValueWidget", [g, h], {_layoutHackIE7:function() {
    if(7 == f("ie")) {
      for(var a = this.domNode, b = a.parentNode, d = a.firstChild || a, c = d.style.filter, e = this;b && 0 == b.clientHeight;) {
        (function() {
          var a = e.connect(b, "onscroll", function() {
            e.disconnect(a);
            d.style.filter = (new Date).getMilliseconds();
            e.defer(function() {
              d.style.filter = c
            })
          })
        })(), b = b.parentNode
      }
    }
  }})
});

//# sourceMappingURL=_FormValueWidget.js.map