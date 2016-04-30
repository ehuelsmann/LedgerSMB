//>>built
require({cache:{"url:dijit/layout/templates/AccordionButton.html":"\x3cdiv data-dojo-attach-event\x3d'ondijitclick:_onTitleClick' class\x3d'dijitAccordionTitle' role\x3d\"presentation\"\x3e\n\t\x3cdiv data-dojo-attach-point\x3d'titleNode,focusNode' data-dojo-attach-event\x3d'onkeydown:_onTitleKeyDown'\n\t\t\tclass\x3d'dijitAccordionTitleFocus' role\x3d\"tab\" aria-expanded\x3d\"false\"\n\t\t\x3e\x3cspan class\x3d'dijitInline dijitAccordionArrow' role\x3d\"presentation\"\x3e\x3c/span\n\t\t\x3e\x3cspan class\x3d'arrowTextUp' role\x3d\"presentation\"\x3e+\x3c/span\n\t\t\x3e\x3cspan class\x3d'arrowTextDown' role\x3d\"presentation\"\x3e-\x3c/span\n\t\t\x3e\x3cspan role\x3d\"presentation\" class\x3d\"dijitInline dijitIcon\" data-dojo-attach-point\x3d\"iconNode\"\x3e\x3c/span\x3e\n\t\t\x3cspan role\x3d\"presentation\" data-dojo-attach-point\x3d'titleTextNode, textDirNode' class\x3d'dijitAccordionText'\x3e\x3c/span\x3e\n\t\x3c/div\x3e\n\x3c/div\x3e\n"}});
define("dijit/layout/AccordionContainer", "require dojo/_base/array dojo/_base/declare dojo/_base/fx dojo/dom dojo/dom-attr dojo/dom-class dojo/dom-construct dojo/dom-geometry dojo/keys dojo/_base/lang dojo/sniff dojo/topic ../focus ../_base/manager dojo/ready ../_Widget ../_Container ../_TemplatedMixin ../_CssStateMixin ./StackContainer ./ContentPane dojo/text!./templates/AccordionButton.html ../a11yclick".split(" "), function(u, n, e, v, w, p, x, g, k, f, h, m, q, y, z, A, s, E, B, t, C, F, D) {
  q = e("dijit.layout._AccordionButton", [s, B, t], {templateString:D, label:"", _setLabelAttr:{node:"titleTextNode", type:"innerHTML"}, title:"", _setTitleAttr:{node:"titleTextNode", type:"attribute", attribute:"title"}, iconClassAttr:"", _setIconClassAttr:{node:"iconNode", type:"class"}, baseClass:"dijitAccordionTitle", getParent:function() {
    return this.parent
  }, buildRendering:function() {
    this.inherited(arguments);
    var a = this.id.replace(" ", "_");
    p.set(this.titleTextNode, "id", a + "_title");
    this.focusNode.setAttribute("aria-labelledby", p.get(this.titleTextNode, "id"));
    w.setSelectable(this.domNode, !1)
  }, getTitleHeight:function() {
    return k.getMarginSize(this.domNode).h
  }, _onTitleClick:function() {
    this.getParent().selectChild(this.contentWidget, !0);
    y.focus(this.focusNode)
  }, _onTitleKeyDown:function(a) {
    return this.getParent()._onKeyDown(a, this.contentWidget)
  }, _setSelectedAttr:function(a) {
    this._set("selected", a);
    this.focusNode.setAttribute("aria-expanded", a ? "true" : "false");
    this.focusNode.setAttribute("aria-selected", a ? "true" : "false");
    this.focusNode.setAttribute("tabIndex", a ? "0" : "-1")
  }});
  m("dojo-bidi") && q.extend({_setLabelAttr:function(a) {
    this._set("label", a);
    p.set(this.titleTextNode, "innerHTML", a);
    this.applyTextDir(this.titleTextNode)
  }, _setTitleAttr:function(a) {
    this._set("title", a);
    p.set(this.titleTextNode, "title", a);
    this.applyTextDir(this.titleTextNode)
  }});
  var r = e("dijit.layout._AccordionInnerContainer" + (m("dojo-bidi") ? "_NoBidi" : ""), [s, t], {baseClass:"dijitAccordionInnerContainer", isLayoutContainer:!0, buildRendering:function() {
    this.domNode = g.place("\x3cdiv class\x3d'" + this.baseClass + "' role\x3d'presentation'\x3e", this.contentWidget.domNode, "after");
    var a = this.contentWidget, b = h.isString(this.buttonWidget) ? h.getObject(this.buttonWidget) : this.buttonWidget;
    this.button = a._buttonWidget = (new b({contentWidget:a, label:a.title, title:a.tooltip, dir:a.dir, lang:a.lang, textDir:a.textDir || this.textDir, iconClass:a.iconClass, id:a.id + "_button", parent:this.parent})).placeAt(this.domNode);
    this.containerNode = g.place("\x3cdiv class\x3d'dijitAccordionChildWrapper' role\x3d'tabpanel' style\x3d'display:none'\x3e", this.domNode);
    this.containerNode.setAttribute("aria-labelledby", this.button.id);
    g.place(this.contentWidget.domNode, this.containerNode)
  }, postCreate:function() {
    this.inherited(arguments);
    var a = this.button, b = this.contentWidget;
    this._contentWidgetWatches = [b.watch("title", h.hitch(this, function(b, d, l) {
      a.set("label", l)
    })), b.watch("tooltip", h.hitch(this, function(b, d, l) {
      a.set("title", l)
    })), b.watch("iconClass", h.hitch(this, function(b, d, l) {
      a.set("iconClass", l)
    }))]
  }, _setSelectedAttr:function(a) {
    this._set("selected", a);
    this.button.set("selected", a);
    if(a && (a = this.contentWidget, a.onSelected)) {
      a.onSelected()
    }
  }, startup:function() {
    this.contentWidget.startup()
  }, destroy:function() {
    this.button.destroyRecursive();
    n.forEach(this._contentWidgetWatches || [], function(a) {
      a.unwatch()
    });
    delete this.contentWidget._buttonWidget;
    delete this.contentWidget._wrapperWidget;
    this.inherited(arguments)
  }, destroyDescendants:function(a) {
    this.contentWidget.destroyRecursive(a)
  }});
  m("dojo-bidi") && (r = e("dijit.layout._AccordionInnerContainer", r, {postCreate:function() {
    this.inherited(arguments);
    var a = this.button;
    this._contentWidgetWatches.push(this.contentWidget.watch("textDir", function(b, c, d) {
      a.set("textDir", d)
    }))
  }}));
  e = e("dijit.layout.AccordionContainer", C, {duration:z.defaultDuration, buttonWidget:q, baseClass:"dijitAccordionContainer", buildRendering:function() {
    this.inherited(arguments);
    this.domNode.style.overflow = "hidden";
    this.domNode.setAttribute("role", "tablist")
  }, startup:function() {
    this._started || (this.inherited(arguments), this.selectedChildWidget && this.selectedChildWidget._wrapperWidget.set("selected", !0))
  }, layout:function() {
    var a = this.selectedChildWidget;
    if(a) {
      var b = a._wrapperWidget.domNode, c = k.getMarginExtents(b), b = k.getPadBorderExtents(b), d = a._wrapperWidget.containerNode, l = k.getMarginExtents(d), d = k.getPadBorderExtents(d), e = this._contentBox, f = 0;
      n.forEach(this.getChildren(), function(b) {
        b != a && (f += k.getMarginSize(b._wrapperWidget.domNode).h)
      });
      this._verticalSpace = e.h - f - c.h - b.h - l.h - d.h - a._buttonWidget.getTitleHeight();
      this._containerContentBox = {h:this._verticalSpace, w:this._contentBox.w - c.w - b.w - l.w - d.w};
      a && a.resize(this._containerContentBox)
    }
  }, _setupChild:function(a) {
    a._wrapperWidget = r({contentWidget:a, buttonWidget:this.buttonWidget, id:a.id + "_wrapper", dir:a.dir, lang:a.lang, textDir:a.textDir || this.textDir, parent:this});
    this.inherited(arguments);
    g.place(a.domNode, a._wrapper, "replace")
  }, removeChild:function(a) {
    a._wrapperWidget && (g.place(a.domNode, a._wrapperWidget.domNode, "after"), a._wrapperWidget.destroy(), delete a._wrapperWidget);
    x.remove(a.domNode, "dijitHidden");
    this.inherited(arguments)
  }, getChildren:function() {
    return n.map(this.inherited(arguments), function(a) {
      return"dijit.layout._AccordionInnerContainer" == a.declaredClass ? a.contentWidget : a
    }, this)
  }, destroy:function() {
    this._animation && this._animation.stop();
    n.forEach(this.getChildren(), function(a) {
      a._wrapperWidget ? a._wrapperWidget.destroy() : a.destroyRecursive()
    });
    this.inherited(arguments)
  }, _showChild:function(a) {
    a._wrapperWidget.containerNode.style.display = "block";
    return this.inherited(arguments)
  }, _hideChild:function(a) {
    a._wrapperWidget.containerNode.style.display = "none";
    this.inherited(arguments)
  }, _transition:function(a, b, c) {
    8 > m("ie") && (c = !1);
    this._animation && (this._animation.stop(!0), delete this._animation);
    var d = this;
    if(a) {
      a._wrapperWidget.set("selected", !0);
      var f = this._showChild(a);
      this.doLayout && a.resize && a.resize(this._containerContentBox)
    }
    b && (b._wrapperWidget.set("selected", !1), c || this._hideChild(b));
    if(c) {
      var e = a._wrapperWidget.containerNode, g = b._wrapperWidget.containerNode;
      c = a._wrapperWidget.containerNode;
      a = k.getMarginExtents(c);
      c = k.getPadBorderExtents(c);
      var h = a.h + c.h;
      g.style.height = d._verticalSpace - h + "px";
      this._animation = new v.Animation({node:e, duration:this.duration, curve:[1, this._verticalSpace - h - 1], onAnimate:function(a) {
        a = Math.floor(a);
        e.style.height = a + "px";
        g.style.height = d._verticalSpace - h - a + "px"
      }, onEnd:function() {
        delete d._animation;
        e.style.height = "auto";
        b._wrapperWidget.containerNode.style.display = "none";
        g.style.height = "auto";
        d._hideChild(b)
      }});
      this._animation.onStop = this._animation.onEnd;
      this._animation.play()
    }
    return f
  }, _onKeyDown:function(a, b) {
    if(!this.disabled && !(a.altKey || !b && !a.ctrlKey)) {
      var c = a.keyCode;
      if(b && (c == f.LEFT_ARROW || c == f.UP_ARROW) || a.ctrlKey && c == f.PAGE_UP) {
        this._adjacent(!1)._buttonWidget._onTitleClick(), a.stopPropagation(), a.preventDefault()
      }else {
        if(b && (c == f.RIGHT_ARROW || c == f.DOWN_ARROW) || a.ctrlKey && (c == f.PAGE_DOWN || c == f.TAB)) {
          this._adjacent(!0)._buttonWidget._onTitleClick(), a.stopPropagation(), a.preventDefault()
        }
      }
    }
  }});
  m("dijit-legacy-requires") && A(0, function() {
    u(["dijit/layout/AccordionPane"])
  });
  e._InnerContainer = r;
  e._Button = q;
  return e
});

//# sourceMappingURL=AccordionContainer.js.map