//>>built
define("lsmb/MaximizeMinimize", ["dojo/_base/declare", "dojo/dom", "dojo/dom-style", "dojo/on", "dijit/_WidgetBase"], function(c, d, e, f, g) {
  return c("lsmb/MaximizeMinimize", [g], {state:"min", stateData:{max:{nextState:"min", imgURL:"UI/payments/img/up.gif", display:"block"}, min:{nextState:"max", imgURL:"UI/payments/img/down.gif", display:"none"}}, mmNodeId:null, setState:function(a) {
    var b = this.stateData[a];
    this.domNode.src = b.imgURL;
    this.state = a;
    e.set(d.byId(this.mmNodeId), "display", b.display)
  }, toggle:function() {
    this.setState(this.stateData[this.state].nextState)
  }, postCreate:function() {
    var a = this.domNode, b = this;
    this.inherited(arguments);
    this.own(f(a, "click", function() {
      b.toggle()
    }));
    this.setState(this.state)
  }})
});

//# sourceMappingURL=MaximizeMinimize.js.map