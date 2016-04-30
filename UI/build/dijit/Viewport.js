//>>built
define("dijit/Viewport", ["dojo/Evented", "dojo/on", "dojo/domReady", "dojo/sniff", "dojo/window"], function(h, e, k, f, g) {
  var d = new h, b;
  k(function() {
    var a = g.getBox();
    d._rlh = e(window, "resize", function() {
      var b = g.getBox();
      a.h == b.h && a.w == b.w || (a = b, d.emit("resize"))
    });
    if(8 == f("ie")) {
      var c = screen.deviceXDPI;
      setInterval(function() {
        screen.deviceXDPI != c && (c = screen.deviceXDPI, d.emit("resize"))
      }, 500)
    }
    f("ios") && (e(document, "focusin", function(a) {
      b = a.target
    }), e(document, "focusout", function(a) {
      b = null
    }))
  });
  d.getEffectiveBox = function(a) {
    a = g.getBox(a);
    var c = b && b.tagName && b.tagName.toLowerCase();
    if(f("ios") && b && !b.readOnly && ("textarea" == c || "input" == c && /^(color|email|number|password|search|tel|text|url)$/.test(b.type))) {
      a.h *= 0 == orientation || 180 == orientation ? 0.66 : 0.4, c = b.getBoundingClientRect(), a.h = Math.max(a.h, c.top + c.height)
    }
    return a
  };
  return d
});

//# sourceMappingURL=Viewport.js.map