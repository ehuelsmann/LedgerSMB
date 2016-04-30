//>>built
define("dijit/_Container", ["dojo/_base/array", "dojo/_base/declare", "dojo/dom-construct", "dojo/_base/kernel"], function(e, d, f, g) {
  return d("dijit._Container", null, {buildRendering:function() {
    this.inherited(arguments);
    this.containerNode || (this.containerNode = this.domNode)
  }, addChild:function(a, c) {
    var b = this.containerNode;
    if(0 < c) {
      for(b = b.firstChild;0 < c;) {
        1 == b.nodeType && c--, b = b.nextSibling
      }
      b ? c = "before" : (b = this.containerNode, c = "last")
    }
    f.place(a.domNode, b, c);
    this._started && !a._started && a.startup()
  }, removeChild:function(a) {
    "number" == typeof a && (a = this.getChildren()[a]);
    a && (a = a.domNode) && a.parentNode && a.parentNode.removeChild(a)
  }, hasChildren:function() {
    return 0 < this.getChildren().length
  }, _getSiblingOfChild:function(a, c) {
    g.deprecated(this.declaredClass + "::_getSiblingOfChild() is deprecated. Use _KeyNavMixin::_getNext() instead.", "", "2.0");
    var b = this.getChildren(), d = e.indexOf(b, a);
    return b[d + c]
  }, getIndexOfChild:function(a) {
    return e.indexOf(this.getChildren(), a)
  }})
});

//# sourceMappingURL=_Container.js.map