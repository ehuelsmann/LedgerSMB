//>>built
define("dojo/dom-geometry", ["./sniff", "./_base/window", "./dom", "./dom-style"], function(k, l, n, m) {
  function p(a, d, b, c, e, g) {
    g = g || "px";
    a = a.style;
    isNaN(d) || (a.left = d + g);
    isNaN(b) || (a.top = b + g);
    0 <= c && (a.width = c + g);
    0 <= e && (a.height = e + g)
  }
  function q(a) {
    return"button" == a.tagName.toLowerCase() || "input" == a.tagName.toLowerCase() && "button" == (a.getAttribute("type") || "").toLowerCase()
  }
  function r(a) {
    return"border-box" == f.boxModel || "table" == a.tagName.toLowerCase() || q(a)
  }
  var f = {boxModel:"content-box"};
  k("ie") && (f.boxModel = "BackCompat" == document.compatMode ? "border-box" : "content-box");
  f.getPadExtents = function(a, d) {
    a = n.byId(a);
    var b = d || m.getComputedStyle(a), c = m.toPixelValue, e = c(a, b.paddingLeft), g = c(a, b.paddingTop), f = c(a, b.paddingRight), b = c(a, b.paddingBottom);
    return{l:e, t:g, r:f, b:b, w:e + f, h:g + b}
  };
  f.getBorderExtents = function(a, d) {
    a = n.byId(a);
    var b = m.toPixelValue, c = d || m.getComputedStyle(a), e = "none" != c.borderLeftStyle ? b(a, c.borderLeftWidth) : 0, f = "none" != c.borderTopStyle ? b(a, c.borderTopWidth) : 0, h = "none" != c.borderRightStyle ? b(a, c.borderRightWidth) : 0, b = "none" != c.borderBottomStyle ? b(a, c.borderBottomWidth) : 0;
    return{l:e, t:f, r:h, b:b, w:e + h, h:f + b}
  };
  f.getPadBorderExtents = function(a, d) {
    a = n.byId(a);
    var b = d || m.getComputedStyle(a), c = f.getPadExtents(a, b), b = f.getBorderExtents(a, b);
    return{l:c.l + b.l, t:c.t + b.t, r:c.r + b.r, b:c.b + b.b, w:c.w + b.w, h:c.h + b.h}
  };
  f.getMarginExtents = function(a, d) {
    a = n.byId(a);
    var b = d || m.getComputedStyle(a), c = m.toPixelValue, e = c(a, b.marginLeft), f = c(a, b.marginTop), h = c(a, b.marginRight), b = c(a, b.marginBottom);
    return{l:e, t:f, r:h, b:b, w:e + h, h:f + b}
  };
  f.getMarginBox = function(a, d) {
    a = n.byId(a);
    var b = d || m.getComputedStyle(a), c = f.getMarginExtents(a, b), e = a.offsetLeft - c.l, g = a.offsetTop - c.t, h = a.parentNode, l = m.toPixelValue;
    if(k("mozilla")) {
      var p = parseFloat(b.left), b = parseFloat(b.top);
      !isNaN(p) && !isNaN(b) ? (e = p, g = b) : h && h.style && (h = m.getComputedStyle(h), "visible" != h.overflow && (e += "none" != h.borderLeftStyle ? l(a, h.borderLeftWidth) : 0, g += "none" != h.borderTopStyle ? l(a, h.borderTopWidth) : 0))
    }else {
      if((k("opera") || 8 == k("ie") && !k("quirks")) && h) {
        h = m.getComputedStyle(h), e -= "none" != h.borderLeftStyle ? l(a, h.borderLeftWidth) : 0, g -= "none" != h.borderTopStyle ? l(a, h.borderTopWidth) : 0
      }
    }
    return{l:e, t:g, w:a.offsetWidth + c.w, h:a.offsetHeight + c.h}
  };
  f.getContentBox = function(a, d) {
    a = n.byId(a);
    var b = d || m.getComputedStyle(a), c = a.clientWidth, e = f.getPadExtents(a, b), g = f.getBorderExtents(a, b);
    c ? (b = a.clientHeight, g.w = g.h = 0) : (c = a.offsetWidth, b = a.offsetHeight);
    k("opera") && (e.l += g.l, e.t += g.t);
    return{l:e.l, t:e.t, w:c - e.w - g.w, h:b - e.h - g.h}
  };
  f.setContentSize = function(a, d, b) {
    a = n.byId(a);
    var c = d.w;
    d = d.h;
    r(a) && (b = f.getPadBorderExtents(a, b), 0 <= c && (c += b.w), 0 <= d && (d += b.h));
    p(a, NaN, NaN, c, d)
  };
  var s = {l:0, t:0, w:0, h:0};
  f.setMarginBox = function(a, d, b) {
    a = n.byId(a);
    var c = b || m.getComputedStyle(a);
    b = d.w;
    var e = d.h, g = r(a) ? s : f.getPadBorderExtents(a, c), c = f.getMarginExtents(a, c);
    if(k("webkit") && q(a)) {
      var h = a.style;
      0 <= b && !h.width && (h.width = "4px");
      0 <= e && !h.height && (h.height = "4px")
    }
    0 <= b && (b = Math.max(b - g.w - c.w, 0));
    0 <= e && (e = Math.max(e - g.h - c.h, 0));
    p(a, d.l, d.t, b, e)
  };
  f.isBodyLtr = function(a) {
    a = a || l.doc;
    return"ltr" == (l.body(a).dir || a.documentElement.dir || "ltr").toLowerCase()
  };
  f.docScroll = function(a) {
    a = a || l.doc;
    var d = l.doc.parentWindow || l.doc.defaultView;
    return"pageXOffset" in d ? {x:d.pageXOffset, y:d.pageYOffset} : (d = k("quirks") ? l.body(a) : a.documentElement) && {x:f.fixIeBiDiScrollLeft(d.scrollLeft || 0, a), y:d.scrollTop || 0}
  };
  k("ie") && (f.getIeDocumentElementOffset = function(a) {
    a = a || l.doc;
    a = a.documentElement;
    if(8 > k("ie")) {
      var d = a.getBoundingClientRect(), b = d.left, d = d.top;
      7 > k("ie") && (b += a.clientLeft, d += a.clientTop);
      return{x:0 > b ? 0 : b, y:0 > d ? 0 : d}
    }
    return{x:0, y:0}
  });
  f.fixIeBiDiScrollLeft = function(a, d) {
    d = d || l.doc;
    var b = k("ie");
    if(b && !f.isBodyLtr(d)) {
      var c = k("quirks"), e = c ? l.body(d) : d.documentElement, g = l.global;
      6 == b && (!c && g.frameElement && e.scrollHeight > e.clientHeight) && (a += e.clientLeft);
      return 8 > b || c ? a + e.clientWidth - e.scrollWidth : -a
    }
    return a
  };
  f.position = function(a, d) {
    a = n.byId(a);
    var b = l.body(a.ownerDocument), c = a.getBoundingClientRect(), c = {x:c.left, y:c.top, w:c.right - c.left, h:c.bottom - c.top};
    if(9 > k("ie")) {
      var e = f.getIeDocumentElementOffset(a.ownerDocument);
      c.x -= e.x + (k("quirks") ? b.clientLeft + b.offsetLeft : 0);
      c.y -= e.y + (k("quirks") ? b.clientTop + b.offsetTop : 0)
    }
    d && (b = f.docScroll(a.ownerDocument), c.x += b.x, c.y += b.y);
    return c
  };
  f.getMarginSize = function(a, d) {
    a = n.byId(a);
    var b = f.getMarginExtents(a, d || m.getComputedStyle(a)), c = a.getBoundingClientRect();
    return{w:c.right - c.left + b.w, h:c.bottom - c.top + b.h}
  };
  f.normalizeEvent = function(a) {
    "layerX" in a || (a.layerX = a.offsetX, a.layerY = a.offsetY);
    if(!k("dom-addeventlistener")) {
      var d = a.target, d = d && d.ownerDocument || document, b = k("quirks") ? d.body : d.documentElement, c = f.getIeDocumentElementOffset(d);
      a.pageX = a.clientX + f.fixIeBiDiScrollLeft(b.scrollLeft || 0, d) - c.x;
      a.pageY = a.clientY + (b.scrollTop || 0) - c.y
    }
  };
  return f
});

//# sourceMappingURL=dom-geometry.js.map