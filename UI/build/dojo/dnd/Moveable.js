//>>built
define("dojo/dnd/Moveable", "../_base/array ../_base/declare ../_base/lang ../dom ../dom-class ../Evented ../on ../topic ../touch ./common ./Mover ../_base/window".split(" "), function(m, n, c, g, e, p, d, h, f, k, q, l) {
  return n("dojo.dnd.Moveable", [p], {handle:"", delay:0, skip:!1, constructor:function(a, b) {
    this.node = g.byId(a);
    b || (b = {});
    this.handle = b.handle ? g.byId(b.handle) : null;
    this.handle || (this.handle = this.node);
    this.delay = 0 < b.delay ? b.delay : 0;
    this.skip = b.skip;
    this.mover = b.mover ? b.mover : q;
    this.events = [d(this.handle, f.press, c.hitch(this, "onMouseDown")), d(this.handle, "dragstart", c.hitch(this, "onSelectStart")), d(this.handle, "selectstart", c.hitch(this, "onSelectStart"))]
  }, markupFactory:function(a, b, c) {
    return new c(b, a)
  }, destroy:function() {
    m.forEach(this.events, function(a) {
      a.remove()
    });
    this.events = this.node = this.handle = null
  }, onMouseDown:function(a) {
    if(!this.skip || !k.isFormElement(a)) {
      if(this.delay) {
        this.events.push(d(this.handle, f.move, c.hitch(this, "onMouseMove")), d(this.handle, f.release, c.hitch(this, "onMouseUp"))), this._lastX = a.pageX, this._lastY = a.pageY
      }else {
        this.onDragDetected(a)
      }
      a.stopPropagation();
      a.preventDefault()
    }
  }, onMouseMove:function(a) {
    if(Math.abs(a.pageX - this._lastX) > this.delay || Math.abs(a.pageY - this._lastY) > this.delay) {
      this.onMouseUp(a), this.onDragDetected(a)
    }
    a.stopPropagation();
    a.preventDefault()
  }, onMouseUp:function(a) {
    for(var b = 0;2 > b;++b) {
      this.events.pop().remove()
    }
    a.stopPropagation();
    a.preventDefault()
  }, onSelectStart:function(a) {
    if(!this.skip || !k.isFormElement(a)) {
      a.stopPropagation(), a.preventDefault()
    }
  }, onDragDetected:function(a) {
    new this.mover(this.node, a, this)
  }, onMoveStart:function(a) {
    h.publish("/dnd/move/start", a);
    e.add(l.body(), "dojoMove");
    e.add(this.node, "dojoMoveItem")
  }, onMoveStop:function(a) {
    h.publish("/dnd/move/stop", a);
    e.remove(l.body(), "dojoMove");
    e.remove(this.node, "dojoMoveItem")
  }, onFirstMove:function() {
  }, onMove:function(a, b) {
    this.onMoving(a, b);
    var c = a.node.style;
    c.left = b.l + "px";
    c.top = b.t + "px";
    this.onMoved(a, b)
  }, onMoving:function() {
  }, onMoved:function() {
  }})
});

//# sourceMappingURL=Moveable.js.map