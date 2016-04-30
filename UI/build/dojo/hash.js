//>>built
define("dojo/hash", "./_base/kernel require ./_base/config ./aspect ./_base/lang ./topic ./domReady ./sniff".split(" "), function(d, x, s, y, h, z, A, k) {
  function t(a, f) {
    var b = a.indexOf(f);
    return 0 <= b ? a.substring(b + 1) : ""
  }
  function c() {
    return t(location.href, "#")
  }
  function n() {
    z.publish("/dojo/hashchange", c())
  }
  function l() {
    c() !== b && (b = c(), n())
  }
  function v(a) {
    if(e) {
      if(e.isTransitioning()) {
        setTimeout(h.hitch(null, v, a), p)
      }else {
        var b = e.iframe.location.href, c = b.indexOf("?");
        e.iframe.location.replace(b.substring(0, c) + "?" + a)
      }
    }else {
      location.replace("#" + a), !w && l()
    }
  }
  function B() {
    function a() {
      b = c();
      k = g ? b : t(u.href, "?");
      q = !1;
      r = null
    }
    var f = document.createElement("iframe"), e = s.dojoBlankHtmlUrl || x.toUrl("./resources/blank.html");
    f.id = "dojo-hash-iframe";
    f.src = e + "?" + c();
    f.style.display = "none";
    document.body.appendChild(f);
    this.iframe = d.global["dojo-hash-iframe"];
    var k, q, r, l, g, u = this.iframe.location;
    this.isTransitioning = function() {
      return q
    };
    this.pollLocation = function() {
      if(!g) {
        try {
          var d = t(u.href, "?");
          document.title != l && (l = this.iframe.document.title = document.title)
        }catch(s) {
          g = !0, console.error("dojo/hash: Error adding history entry. Server unreachable.")
        }
      }
      var m = c();
      if(q && b === m) {
        if(g || d === r) {
          a(), n()
        }else {
          setTimeout(h.hitch(this, this.pollLocation), 0);
          return
        }
      }else {
        if(!(b === m && (g || k === d))) {
          if(b !== m) {
            b = m;
            q = !0;
            r = m;
            f.src = e + "?" + r;
            g = !1;
            setTimeout(h.hitch(this, this.pollLocation), 0);
            return
          }
          g || (location.href = "#" + u.search.substring(1), a(), n())
        }
      }
      setTimeout(h.hitch(this, this.pollLocation), p)
    };
    a();
    setTimeout(h.hitch(this, this.pollLocation), p)
  }
  d.hash = function(a, b) {
    if(!arguments.length) {
      return c()
    }
    "#" == a.charAt(0) && (a = a.substring(1));
    b ? v(a) : location.href = "#" + a;
    return a
  };
  var b, e, w, p = s.hashPollFrequency || 100;
  A(function() {
    "onhashchange" in d.global && (!k("ie") || 8 <= k("ie") && "BackCompat" != document.compatMode) ? w = y.after(d.global, "onhashchange", n, !0) : document.addEventListener ? (b = c(), setInterval(l, p)) : document.attachEvent && (e = new B)
  });
  return d.hash
});

//# sourceMappingURL=hash.js.map