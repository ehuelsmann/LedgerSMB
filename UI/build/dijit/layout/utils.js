//>>built
define("dijit/layout/utils", ["dojo/_base/array", "dojo/dom-class", "dojo/dom-geometry", "dojo/dom-style", "dojo/_base/lang"], function(k, n, g, l, f) {
  function m(b, a) {
    var c = b.resize ? b.resize(a) : g.setMarginBox(b.domNode, a);
    c ? f.mixin(b, c) : (f.mixin(b, g.getMarginBox(b.domNode)), f.mixin(b, a))
  }
  var p = {marginBox2contentBox:function(b, a) {
    var c = l.getComputedStyle(b), f = g.getMarginExtents(b, c), h = g.getPadBorderExtents(b, c);
    return{l:l.toPixelValue(b, c.paddingLeft), t:l.toPixelValue(b, c.paddingTop), w:a.w - (f.w + h.w), h:a.h - (f.h + h.h)}
  }, layoutChildren:function(b, a, c, g, h) {
    a = f.mixin({}, a);
    n.add(b, "dijitLayoutContainer");
    c = k.filter(c, function(a) {
      return"center" != a.region && "client" != a.layoutAlign
    }).concat(k.filter(c, function(a) {
      return"center" == a.region || "client" == a.layoutAlign
    }));
    k.forEach(c, function(d) {
      var b = d.domNode, e = d.region || d.layoutAlign;
      if(!e) {
        throw Error("No region setting for " + d.id);
      }
      var c = b.style;
      c.left = a.l + "px";
      c.top = a.t + "px";
      c.position = "absolute";
      n.add(b, "dijitAlign" + (e.substring(0, 1).toUpperCase() + e.substring(1)));
      b = {};
      g && g == d.id && (b["top" == d.region || "bottom" == d.region ? "h" : "w"] = h);
      "leading" == e && (e = d.isLeftToRight() ? "left" : "right");
      "trailing" == e && (e = d.isLeftToRight() ? "right" : "left");
      "top" == e || "bottom" == e ? (b.w = a.w, m(d, b), a.h -= d.h, "top" == e ? a.t += d.h : c.top = a.t + a.h + "px") : "left" == e || "right" == e ? (b.h = a.h, m(d, b), a.w -= d.w, "left" == e ? a.l += d.w : c.left = a.l + a.w + "px") : ("client" == e || "center" == e) && m(d, a)
    })
  }};
  f.setObject("dijit.layout.utils", p);
  return p
});

//# sourceMappingURL=utils.js.map