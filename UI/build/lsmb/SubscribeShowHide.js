//>>built
define("lsmb/SubscribeShowHide", "dojo/_base/declare dojo/dom dojo/dom-style dojo/on dojo/topic dijit/_WidgetBase".split(" "), function(c, f, b, g, d, e) {
  return c("lsmb/SubscribeShowHide", [e], {topic:"", showValues:null, hideValues:null, show:function() {
    b.set(this.domNode, "display", "block")
  }, hide:function() {
    b.set(this.domNode, "display", "none")
  }, update:function(a) {
    this.showValues && -1 != this.showValues.indexOf(a) ? this.show() : this.hideValues && -1 != this.hideValues.indexOf(a) ? this.hide() : this.showValues ? this.hideValues || this.hide() : this.show()
  }, postCreate:function() {
    var a = this;
    this.inherited(arguments);
    this.own(d.subscribe(a.topic, function(b) {
      a.update(b)
    }))
  }})
});

//# sourceMappingURL=SubscribeShowHide.js.map