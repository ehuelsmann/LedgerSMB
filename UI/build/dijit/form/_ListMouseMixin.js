//>>built
define("dijit/form/_ListMouseMixin", ["dojo/_base/declare", "dojo/on", "dojo/touch", "./_ListBase"], function(e, g, h, f) {
  return e("dijit.form._ListMouseMixin", f, {postCreate:function() {
    this.inherited(arguments);
    this.domNode.dojoClick = !0;
    this._listConnect("click", "_onClick");
    this._listConnect("mousedown", "_onMouseDown");
    this._listConnect("mouseup", "_onMouseUp");
    this._listConnect("mouseover", "_onMouseOver");
    this._listConnect("mouseout", "_onMouseOut")
  }, _onClick:function(b, a) {
    this._setSelectedAttr(a, !1);
    this._deferredClick && this._deferredClick.remove();
    this._deferredClick = this.defer(function() {
      this._deferredClick = null;
      this.onClick(a)
    })
  }, _onMouseDown:function(b, a) {
    this._hoveredNode && (this.onUnhover(this._hoveredNode), this._hoveredNode = null);
    this._isDragging = !0;
    this._setSelectedAttr(a, !1)
  }, _onMouseUp:function(b, a) {
    this._isDragging = !1;
    var c = this.selected, d = this._hoveredNode;
    c && a == c ? this.defer(function() {
      this._onClick(b, c)
    }) : d && this.defer(function() {
      this._onClick(b, d)
    })
  }, _onMouseOut:function(b, a) {
    this._hoveredNode && (this.onUnhover(this._hoveredNode), this._hoveredNode = null);
    this._isDragging && (this._cancelDrag = (new Date).getTime() + 1E3)
  }, _onMouseOver:function(b, a) {
    this._cancelDrag && ((new Date).getTime() > this._cancelDrag && (this._isDragging = !1), this._cancelDrag = null);
    this._hoveredNode = a;
    this.onHover(a);
    this._isDragging && this._setSelectedAttr(a, !1)
  }})
});

//# sourceMappingURL=_ListMouseMixin.js.map