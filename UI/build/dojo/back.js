//>>built
define("dojo/back", "./_base/config ./_base/lang ./sniff ./dom ./dom-construct ./_base/window require".split(" "), function(h, B, l, C, D, E, w) {
  function f() {
    var a = c.pop();
    if(a) {
      var b = c[c.length - 1];
      !b && 0 == c.length && (b = m);
      b && (b.kwArgs.back ? b.kwArgs.back() : b.kwArgs.backButton ? b.kwArgs.backButton() : b.kwArgs.handle && b.kwArgs.handle("back"));
      e.push(a)
    }
  }
  function q() {
    var a = e.pop();
    a && (a.kwArgs.forward ? a.kwArgs.forward() : a.kwArgs.forwardButton ? a.kwArgs.forwardButton() : a.kwArgs.handle && a.kwArgs.handle("forward"), c.push(a))
  }
  function n(a, b, c) {
    return{url:a, kwArgs:b, urlHash:c}
  }
  function r(a) {
    a = a.split("?");
    return 2 > a.length ? null : a[1]
  }
  function x() {
    var a = (h.dojoIframeHistoryUrl || w.toUrl("./resources/iframe_history.html")) + "?" + (new Date).getTime();
    s = !0;
    k && (l("webkit") ? k.location = a : window.frames[k.name].location = a);
    return a
  }
  function F() {
    if(!t) {
      var a = c.length, b = p();
      (b === y || window.location.href == z) && 1 == a ? f() : 0 < e.length && e[e.length - 1].urlHash === b ? q() : 2 <= a && c[a - 2] && c[a - 2].urlHash === b && f()
    }
  }
  var d = {};
  B.setObject("dojo.back", d);
  var p = d.getHash = function() {
    var a = window.location.hash;
    "#" == a.charAt(0) && (a = a.substring(1));
    return l("mozilla") ? a : decodeURIComponent(a)
  }, u = d.setHash = function(a) {
    a || (a = "");
    window.location.hash = encodeURIComponent(a)
  }, z = "undefined" !== typeof window ? window.location.href : "", y = "undefined" !== typeof window ? p() : "", m = null, A = null, v = null, k = null, e = [], c = [], s = !1, t = !1;
  d.goBack = f;
  d.goForward = q;
  d.init = function() {
    if(!C.byId("dj_history")) {
      var a = h.dojoIframeHistoryUrl || w.toUrl("./resources/iframe_history.html");
      h.afterOnLoad ? console.error("dojo/back::init() must be called before the DOM has loaded. Include dojo/back in a build layer.") : document.write('\x3ciframe style\x3d"border:0;width:1px;height:1px;position:absolute;visibility:hidden;bottom:0;right:0;" name\x3d"dj_history" id\x3d"dj_history" src\x3d"' + a + '"\x3e\x3c/iframe\x3e')
    }
  };
  d.setInitialState = function(a) {
    m = n(z, a, y)
  };
  d.addToHistory = function(a) {
    e = [];
    var b = null, d = null;
    k || (k = window.frames.dj_history);
    v || (v = D.create("a", {style:{display:"none"}}, E.body()));
    if(a.changeUrl) {
      b = "" + (!0 !== a.changeUrl ? a.changeUrl : (new Date).getTime());
      if(0 == c.length && m.urlHash == b) {
        m = n(d, a, b);
        return
      }
      if(0 < c.length && c[c.length - 1].urlHash == b) {
        c[c.length - 1] = n(d, a, b);
        return
      }
      t = !0;
      setTimeout(function() {
        u(b);
        t = !1
      }, 1);
      v.href = b;
      if(l("ie")) {
        var d = x(), f = a.back || a.backButton || a.handle, g = function(a) {
          "" != p() && setTimeout(function() {
            u(b)
          }, 1);
          f.apply(this, [a])
        };
        a.back ? a.back = g : a.backButton ? a.backButton = g : a.handle && (a.handle = g);
        var h = a.forward || a.forwardButton || a.handle, g = function(a) {
          "" != p() && u(b);
          h && h.apply(this, [a])
        };
        a.forward ? a.forward = g : a.forwardButton ? a.forwardButton = g : a.handle && (a.handle = g)
      }else {
        l("ie") || A || (A = setInterval(F, 200))
      }
    }else {
      d = x()
    }
    c.push(n(d, a, b))
  };
  d._iframeLoaded = function(a, b) {
    var d = r(b.href);
    null == d ? 1 == c.length && f() : s ? s = !1 : 2 <= c.length && d == r(c[c.length - 2].url) ? f() : 0 < e.length && d == r(e[e.length - 1].url) && q()
  };
  return d
});

//# sourceMappingURL=back.js.map