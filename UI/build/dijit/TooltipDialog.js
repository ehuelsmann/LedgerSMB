//>>built
require({cache:{"url:dijit/templates/TooltipDialog.html":'\x3cdiv role\x3d"alertdialog" tabIndex\x3d"-1"\x3e\n\t\x3cdiv class\x3d"dijitTooltipContainer" role\x3d"presentation"\x3e\n\t\t\x3cdiv data-dojo-attach-point\x3d"contentsNode" class\x3d"dijitTooltipContents dijitTooltipFocusNode"\x3e\n\t\t\t\x3cdiv data-dojo-attach-point\x3d"containerNode"\x3e\x3c/div\x3e\n\t\t\t${!actionBarTemplate}\n\t\t\x3c/div\x3e\n\t\x3c/div\x3e\n\t\x3cdiv class\x3d"dijitTooltipConnector" role\x3d"presentation" data-dojo-attach-point\x3d"connectorNode"\x3e\x3c/div\x3e\n\x3c/div\x3e\n'}});
define("dijit/TooltipDialog", "dojo/_base/declare dojo/dom-class dojo/has dojo/keys dojo/_base/lang dojo/on ./focus ./layout/ContentPane ./_DialogMixin ./form/_FormMixin ./_TemplatedMixin dojo/text!./templates/TooltipDialog.html ./main".split(" "), function(c, f, g, e, h, k, d, l, m, n, p, q, r) {
  c = c("dijit.TooltipDialog", [l, p, n, m], {title:"", doLayout:!1, autofocus:!0, baseClass:"dijitTooltipDialog", _firstFocusItem:null, _lastFocusItem:null, templateString:q, _setTitleAttr:"containerNode", postCreate:function() {
    this.inherited(arguments);
    this.own(k(this.domNode, "keydown", h.hitch(this, "_onKey")))
  }, orient:function(a, b, c) {
    a = {"MR-ML":"dijitTooltipRight", "ML-MR":"dijitTooltipLeft", "TM-BM":"dijitTooltipAbove", "BM-TM":"dijitTooltipBelow", "BL-TL":"dijitTooltipBelow dijitTooltipABLeft", "TL-BL":"dijitTooltipAbove dijitTooltipABLeft", "BR-TR":"dijitTooltipBelow dijitTooltipABRight", "TR-BR":"dijitTooltipAbove dijitTooltipABRight", "BR-BL":"dijitTooltipRight", "BL-BR":"dijitTooltipLeft", "BR-TL":"dijitTooltipBelow dijitTooltipABLeft", "BL-TR":"dijitTooltipBelow dijitTooltipABRight", "TL-BR":"dijitTooltipAbove dijitTooltipABRight", 
    "TR-BL":"dijitTooltipAbove dijitTooltipABLeft"}[b + "-" + c];
    f.replace(this.domNode, a, this._currentOrientClass || "");
    this._currentOrientClass = a
  }, focus:function() {
    this._getFocusItems();
    d.focus(this._firstFocusItem)
  }, onOpen:function(a) {
    this.orient(this.domNode, a.aroundCorner, a.corner);
    var b = a.aroundNodePos;
    "M" == a.corner.charAt(0) && "M" == a.aroundCorner.charAt(0) ? (this.connectorNode.style.top = b.y + (b.h - this.connectorNode.offsetHeight >> 1) - a.y + "px", this.connectorNode.style.left = "") : "M" == a.corner.charAt(1) && "M" == a.aroundCorner.charAt(1) && (this.connectorNode.style.left = b.x + (b.w - this.connectorNode.offsetWidth >> 1) - a.x + "px");
    this._onShow()
  }, onClose:function() {
    this.onHide()
  }, _onKey:function(a) {
    if(a.keyCode == e.ESCAPE) {
      this.defer("onCancel"), a.stopPropagation(), a.preventDefault()
    }else {
      if(a.keyCode == e.TAB) {
        var b = a.target;
        this._getFocusItems();
        this._firstFocusItem == this._lastFocusItem ? (a.stopPropagation(), a.preventDefault()) : b == this._firstFocusItem && a.shiftKey ? (d.focus(this._lastFocusItem), a.stopPropagation(), a.preventDefault()) : b == this._lastFocusItem && !a.shiftKey ? (d.focus(this._firstFocusItem), a.stopPropagation(), a.preventDefault()) : a.stopPropagation()
      }
    }
  }});
  g("dojo-bidi") && c.extend({_setTitleAttr:function(a) {
    this.containerNode.title = this.textDir && this.enforceTextDirWithUcc ? this.enforceTextDirWithUcc(null, a) : a;
    this._set("title", a)
  }, _setTextDirAttr:function(a) {
    if(!this._created || this.textDir != a) {
      this._set("textDir", a), this.textDir && this.title && (this.containerNode.title = this.enforceTextDirWithUcc(null, this.title))
    }
  }});
  return c
});

//# sourceMappingURL=TooltipDialog.js.map