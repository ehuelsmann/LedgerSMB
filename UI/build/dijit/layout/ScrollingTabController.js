//>>built
require({cache:{"url:dijit/layout/templates/ScrollingTabController.html":'\x3cdiv class\x3d"dijitTabListContainer-${tabPosition}" style\x3d"visibility:hidden"\x3e\n\t\x3cdiv data-dojo-type\x3d"dijit.layout._ScrollingTabControllerMenuButton"\n\t\t class\x3d"tabStripButton-${tabPosition}"\n\t\t id\x3d"${id}_menuBtn"\n\t\t data-dojo-props\x3d"containerId: \'${containerId}\', iconClass: \'dijitTabStripMenuIcon\',\n\t\t\t\t\tdropDownPosition: [\'below-alt\', \'above-alt\']"\n\t\t data-dojo-attach-point\x3d"_menuBtn" showLabel\x3d"false" title\x3d""\x3e\x26#9660;\x3c/div\x3e\n\t\x3cdiv data-dojo-type\x3d"dijit.layout._ScrollingTabControllerButton"\n\t\t class\x3d"tabStripButton-${tabPosition}"\n\t\t id\x3d"${id}_leftBtn"\n\t\t data-dojo-props\x3d"iconClass:\'dijitTabStripSlideLeftIcon\', showLabel:false, title:\'\'"\n\t\t data-dojo-attach-point\x3d"_leftBtn" data-dojo-attach-event\x3d"onClick: doSlideLeft"\x3e\x26#9664;\x3c/div\x3e\n\t\x3cdiv data-dojo-type\x3d"dijit.layout._ScrollingTabControllerButton"\n\t\t class\x3d"tabStripButton-${tabPosition}"\n\t\t id\x3d"${id}_rightBtn"\n\t\t data-dojo-props\x3d"iconClass:\'dijitTabStripSlideRightIcon\', showLabel:false, title:\'\'"\n\t\t data-dojo-attach-point\x3d"_rightBtn" data-dojo-attach-event\x3d"onClick: doSlideRight"\x3e\x26#9654;\x3c/div\x3e\n\t\x3cdiv class\x3d\'dijitTabListWrapper\' data-dojo-attach-point\x3d\'tablistWrapper\'\x3e\n\t\t\x3cdiv role\x3d\'tablist\' data-dojo-attach-event\x3d\'onkeydown:onkeydown\'\n\t\t\t data-dojo-attach-point\x3d\'containerNode\' class\x3d\'nowrapTabStrip\'\x3e\x3c/div\x3e\n\t\x3c/div\x3e\n\x3c/div\x3e', 
"url:dijit/layout/templates/_ScrollingTabControllerButton.html":'\x3cdiv data-dojo-attach-event\x3d"ondijitclick:_onClick" class\x3d"dijitTabInnerDiv dijitTabContent dijitButtonContents"  data-dojo-attach-point\x3d"focusNode" role\x3d"button"\x3e\n\t\x3cspan role\x3d"presentation" class\x3d"dijitInline dijitTabStripIcon" data-dojo-attach-point\x3d"iconNode"\x3e\x3c/span\x3e\n\t\x3cspan data-dojo-attach-point\x3d"containerNode,titleNode" class\x3d"dijitButtonText"\x3e\x3c/span\x3e\n\x3c/div\x3e'}});
define("dijit/layout/ScrollingTabController", "dojo/_base/array dojo/_base/declare dojo/dom-class dojo/dom-geometry dojo/dom-style dojo/_base/fx dojo/_base/lang dojo/on dojo/query dojo/sniff ../registry dojo/text!./templates/ScrollingTabController.html dojo/text!./templates/_ScrollingTabControllerButton.html ./TabController ./utils ../_WidgetsInTemplateMixin ../Menu ../MenuItem ../form/Button ../_HasDropDown dojo/NodeList-dom ../a11yclick".split(" "), function(q, f, g, l, c, m, r, s, t, e, u, k, 
h, v, n, w, x, y, p, z) {
  k = f("dijit.layout.ScrollingTabController", [v, w], {baseClass:"dijitTabController dijitScrollingTabController", templateString:k, useMenu:!0, useSlider:!0, tabStripClass:"", _minScroll:5, _setClassAttr:{node:"containerNode", type:"class"}, buildRendering:function() {
    this.inherited(arguments);
    var a = this.domNode;
    this.scrollNode = this.tablistWrapper;
    this._initButtons();
    this.tabStripClass || (this.tabStripClass = "dijitTabContainer" + this.tabPosition.charAt(0).toUpperCase() + this.tabPosition.substr(1).replace(/-.*/, "") + "None", g.add(a, "tabStrip-disabled"));
    g.add(this.tablistWrapper, this.tabStripClass)
  }, onStartup:function() {
    this.inherited(arguments);
    c.set(this.domNode, "visibility", "");
    this._postStartup = !0;
    this.own(s(this.containerNode, "attrmodified-label, attrmodified-iconclass", r.hitch(this, function(a) {
      this._dim && this.resize(this._dim)
    })))
  }, onAddChild:function(a, b) {
    this.inherited(arguments);
    c.set(this.containerNode, "width", c.get(this.containerNode, "width") + 200 + "px")
  }, onRemoveChild:function(a, b) {
    var d = this.pane2button(a.id);
    this._selectedTab === d.domNode && (this._selectedTab = null);
    this.inherited(arguments)
  }, _initButtons:function() {
    this._btnWidth = 0;
    this._buttons = t("\x3e .tabStripButton", this.domNode).filter(function(a) {
      if(this.useMenu && a == this._menuBtn.domNode || this.useSlider && (a == this._rightBtn.domNode || a == this._leftBtn.domNode)) {
        return this._btnWidth += l.getMarginSize(a).w, !0
      }
      c.set(a, "display", "none");
      return!1
    }, this)
  }, _getTabsWidth:function() {
    var a = this.getChildren();
    if(a.length) {
      var b = a[this.isLeftToRight() ? 0 : a.length - 1].domNode, a = a[this.isLeftToRight() ? a.length - 1 : 0].domNode;
      return a.offsetLeft + a.offsetWidth - b.offsetLeft
    }
    return 0
  }, _enableBtn:function(a) {
    var b = this._getTabsWidth();
    a = a || c.get(this.scrollNode, "width");
    return 0 < b && a < b
  }, resize:function(a) {
    this._dim = a;
    this.scrollNode.style.height = "auto";
    var b = this._contentBox = n.marginBox2contentBox(this.domNode, {h:0, w:a.w});
    b.h = this.scrollNode.offsetHeight;
    l.setContentSize(this.domNode, b);
    b = this._enableBtn(this._contentBox.w);
    this._buttons.style("display", b ? "" : "none");
    this._leftBtn.region = "left";
    this._rightBtn.region = "right";
    this._menuBtn.region = this.isLeftToRight() ? "right" : "left";
    n.layoutChildren(this.domNode, this._contentBox, [this._menuBtn, this._leftBtn, this._rightBtn, {domNode:this.scrollNode, region:"center"}]);
    this._selectedTab && (this._anim && "playing" == this._anim.status() && this._anim.stop(), this.scrollNode.scrollLeft = this._convertToScrollLeft(this._getScrollForSelectedTab()));
    this._setButtonClass(this._getScroll());
    this._postResize = !0;
    return{h:this._contentBox.h, w:a.w}
  }, _getScroll:function() {
    return this.isLeftToRight() || 8 > e("ie") || e("ie") && e("quirks") || e("webkit") ? this.scrollNode.scrollLeft : c.get(this.containerNode, "width") - c.get(this.scrollNode, "width") + (8 <= e("ie") ? -1 : 1) * this.scrollNode.scrollLeft
  }, _convertToScrollLeft:function(a) {
    if(this.isLeftToRight() || 8 > e("ie") || e("ie") && e("quirks") || e("webkit")) {
      return a
    }
    var b = c.get(this.containerNode, "width") - c.get(this.scrollNode, "width");
    return(8 <= e("ie") ? -1 : 1) * (a - b)
  }, onSelectChild:function(a) {
    var b = this.pane2button(a.id);
    if(b) {
      b = b.domNode;
      if(b != this._selectedTab && (this._selectedTab = b, this._postResize)) {
        var d = this._getScroll();
        (d > b.offsetLeft || d + c.get(this.scrollNode, "width") < b.offsetLeft + c.get(b, "width")) && this.createSmoothScroll().play()
      }
      this.inherited(arguments)
    }
  }, _getScrollBounds:function() {
    var a = this.getChildren(), b = c.get(this.scrollNode, "width"), d = c.get(this.containerNode, "width") - b, e = this._getTabsWidth();
    if(a.length && e > b) {
      return{min:this.isLeftToRight() ? 0 : a[a.length - 1].domNode.offsetLeft, max:this.isLeftToRight() ? a[a.length - 1].domNode.offsetLeft + a[a.length - 1].domNode.offsetWidth - b : d}
    }
    a = this.isLeftToRight() ? 0 : d;
    return{min:a, max:a}
  }, _getScrollForSelectedTab:function() {
    var a = this._selectedTab, b = c.get(this.scrollNode, "width"), d = this._getScrollBounds(), a = a.offsetLeft + c.get(a, "width") / 2 - b / 2;
    return a = Math.min(Math.max(a, d.min), d.max)
  }, createSmoothScroll:function(a) {
    if(0 < arguments.length) {
      var b = this._getScrollBounds();
      a = Math.min(Math.max(a, b.min), b.max)
    }else {
      a = this._getScrollForSelectedTab()
    }
    this._anim && "playing" == this._anim.status() && this._anim.stop();
    var d = this, c = this.scrollNode, e = new m.Animation({beforeBegin:function() {
      this.curve && delete this.curve;
      var b = c.scrollLeft, f = d._convertToScrollLeft(a);
      e.curve = new m._Line(b, f)
    }, onAnimate:function(a) {
      c.scrollLeft = a
    }});
    this._anim = e;
    this._setButtonClass(a);
    return e
  }, _getBtnNode:function(a) {
    for(a = a.target;a && !g.contains(a, "tabStripButton");) {
      a = a.parentNode
    }
    return a
  }, doSlideRight:function(a) {
    this.doSlide(1, this._getBtnNode(a))
  }, doSlideLeft:function(a) {
    this.doSlide(-1, this._getBtnNode(a))
  }, doSlide:function(a, b) {
    if(!b || !g.contains(b, "dijitTabDisabled")) {
      var d = 0.75 * c.get(this.scrollNode, "width") * a, d = this._getScroll() + d;
      this._setButtonClass(d);
      this.createSmoothScroll(d).play()
    }
  }, _setButtonClass:function(a) {
    var b = this._getScrollBounds();
    this._leftBtn.set("disabled", a <= b.min);
    this._rightBtn.set("disabled", a >= b.max)
  }});
  h = f("dijit.layout._ScrollingTabControllerButtonMixin", null, {baseClass:"dijitTab tabStripButton", templateString:h, tabIndex:"", isFocusable:function() {
    return!1
  }});
  f("dijit.layout._ScrollingTabControllerButton", [p, h]);
  f("dijit.layout._ScrollingTabControllerMenuButton", [p, z, h], {containerId:"", tabIndex:"-1", isLoaded:function() {
    return!1
  }, loadDropDown:function(a) {
    this.dropDown = new x({id:this.containerId + "_menu", ownerDocument:this.ownerDocument, dir:this.dir, lang:this.lang, textDir:this.textDir});
    var b = u.byId(this.containerId);
    q.forEach(b.getChildren(), function(a) {
      var c = new y({id:a.id + "_stcMi", label:a.title, iconClass:a.iconClass, disabled:a.disabled, ownerDocument:this.ownerDocument, dir:a.dir, lang:a.lang, textDir:a.textDir || b.textDir, onClick:function() {
        b.selectChild(a)
      }});
      this.dropDown.addChild(c)
    }, this);
    a()
  }, closeDropDown:function(a) {
    this.inherited(arguments);
    this.dropDown && (this._popupStateNode.removeAttribute("aria-owns"), this.dropDown.destroyRecursive(), delete this.dropDown)
  }});
  return k
});

//# sourceMappingURL=ScrollingTabController.js.map