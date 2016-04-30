//>>built
define("dojo/touch", "./_base/kernel ./aspect ./dom ./dom-class ./_base/lang ./on ./has ./mouse ./domReady ./_base/window".split(" "), function(F, v, w, G, H, g, m, s, x, e) {
  function l(a, d, c) {
    return t && c ? function(a, d) {
      return g(a, c, d)
    } : y ? function(c, e) {
      var b = g(c, d, function(b) {
        e.call(this, b);
        n = (new Date).getTime()
      }), I = g(c, a, function(b) {
        (!n || (new Date).getTime() > n + 1E3) && e.call(this, b)
      });
      return{remove:function() {
        b.remove();
        I.remove()
      }}
    } : function(d, c) {
      return g(d, a, c)
    }
  }
  function J(a) {
    do {
      if(void 0 !== a.dojoClick) {
        return a
      }
    }while(a = a.parentNode)
  }
  function z(a, d, c) {
    var f = J(a.target);
    if(h = !a.target.disabled && f && f.dojoClick) {
      if(q = (p = "useTarget" == h) ? f : a.target, p && a.preventDefault(), A = a.changedTouches ? a.changedTouches[0].pageX - e.global.pageXOffset : a.clientX, B = a.changedTouches ? a.changedTouches[0].pageY - e.global.pageYOffset : a.clientY, C = ("object" == typeof h ? h.x : "number" == typeof h ? h : 0) || 4, D = ("object" == typeof h ? h.y : "number" == typeof h ? h : 0) || 4, !E) {
        E = !0;
        var k = function(b) {
          h = p ? w.isDescendant(e.doc.elementFromPoint(b.changedTouches ? b.changedTouches[0].pageX - e.global.pageXOffset : b.clientX, b.changedTouches ? b.changedTouches[0].pageY - e.global.pageYOffset : b.clientY), q) : h && (b.changedTouches ? b.changedTouches[0].target : b.target) == q && Math.abs((b.changedTouches ? b.changedTouches[0].pageX - e.global.pageXOffset : b.clientX) - A) <= C && Math.abs((b.changedTouches ? b.changedTouches[0].pageY - e.global.pageYOffset : b.clientY) - B) <= D
        };
        e.doc.addEventListener(d, function(b) {
          k(b);
          p && b.preventDefault()
        }, !0);
        e.doc.addEventListener(c, function(b) {
          k(b);
          if(h) {
            u = (new Date).getTime();
            var d = p ? q : b.target;
            "LABEL" === d.tagName && (d = w.byId(d.getAttribute("for")) || d);
            var a = b.changedTouches ? b.changedTouches[0] : b, c = document.createEvent("MouseEvents");
            c._dojo_click = !0;
            c.initMouseEvent("click", !0, !0, b.view, b.detail, a.screenX, a.screenY, a.clientX, a.clientY, b.ctrlKey, b.altKey, b.shiftKey, b.metaKey, 0, null);
            setTimeout(function() {
              g.emit(d, "click", c);
              u = (new Date).getTime()
            }, 0)
          }
        }, !0);
        a = function(d) {
          e.doc.addEventListener(d, function(a) {
            !a._dojo_click && ((new Date).getTime() <= u + 1E3 && !("INPUT" == a.target.tagName && G.contains(a.target, "dijitOffScreen"))) && (a.stopPropagation(), a.stopImmediatePropagation && a.stopImmediatePropagation(), "click" == d && (("INPUT" != a.target.tagName || "radio" == a.target.type || "checkbox" == a.target.type) && "TEXTAREA" != a.target.tagName && "AUDIO" != a.target.tagName && "VIDEO" != a.target.tagName) && a.preventDefault())
          }, !0)
        };
        a("click");
        a("mousedown");
        a("mouseup")
      }
    }
  }
  var r = 5 > m("ios"), t = m("pointer-events") || m("MSPointer"), f = function() {
    var a = {}, d;
    for(d in{down:1, move:1, up:1, cancel:1, over:1, out:1}) {
      a[d] = m("MSPointer") ? "MSPointer" + d.charAt(0).toUpperCase() + d.slice(1) : "pointer" + d
    }
    return a
  }(), y = m("touch-events"), E, h, p = !1, q, A, B, C, D, u, n, k;
  t ? x(function() {
    e.doc.addEventListener(f.down, function(a) {
      z(a, f.move, f.up)
    }, !0)
  }) : y && x(function() {
    function a(a) {
      var c = H.delegate(a, {bubbles:!0});
      6 <= m("ios") && (c.touches = a.touches, c.altKey = a.altKey, c.changedTouches = a.changedTouches, c.ctrlKey = a.ctrlKey, c.metaKey = a.metaKey, c.shiftKey = a.shiftKey, c.targetTouches = a.targetTouches);
      return c
    }
    k = e.body();
    e.doc.addEventListener("touchstart", function(a) {
      n = (new Date).getTime();
      var c = k;
      k = a.target;
      g.emit(c, "dojotouchout", {relatedTarget:k, bubbles:!0});
      g.emit(k, "dojotouchover", {relatedTarget:c, bubbles:!0});
      z(a, "touchmove", "touchend")
    }, !0);
    g(e.doc, "touchmove", function(d) {
      n = (new Date).getTime();
      var c = e.doc.elementFromPoint(d.pageX - (r ? 0 : e.global.pageXOffset), d.pageY - (r ? 0 : e.global.pageYOffset));
      c && (k !== c && (g.emit(k, "dojotouchout", {relatedTarget:c, bubbles:!0}), g.emit(c, "dojotouchover", {relatedTarget:k, bubbles:!0}), k = c), g.emit(c, "dojotouchmove", a(d)) || d.preventDefault())
    });
    g(e.doc, "touchend", function(d) {
      n = (new Date).getTime();
      var c = e.doc.elementFromPoint(d.pageX - (r ? 0 : e.global.pageXOffset), d.pageY - (r ? 0 : e.global.pageYOffset)) || e.body();
      g.emit(c, "dojotouchend", a(d))
    })
  });
  v = {press:l("mousedown", "touchstart", f.down), move:l("mousemove", "dojotouchmove", f.move), release:l("mouseup", "dojotouchend", f.up), cancel:l(s.leave, "touchcancel", t ? f.cancel : null), over:l("mouseover", "dojotouchover", f.over), out:l("mouseout", "dojotouchout", f.out), enter:s._eventHandler(l("mouseover", "dojotouchover", f.over)), leave:s._eventHandler(l("mouseout", "dojotouchout", f.out))};
  return F.touch = v
});

//# sourceMappingURL=touch.js.map