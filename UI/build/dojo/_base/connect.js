//>>built
define("dojo/_base/connect", "./kernel ../on ../topic ../aspect ./event ../mouse ./sniff ./lang ../keys".split(" "), function(m, g, n, u, y, r, h, l) {
  function v(a, c, b, e, s) {
    e = l.hitch(b, e);
    if(!a || !a.addEventListener && !a.attachEvent) {
      return u.after(a || m.global, c, e, !0)
    }
    "string" == typeof c && "on" == c.substring(0, 2) && (c = c.substring(2));
    a || (a = m.global);
    if(!s) {
      switch(c) {
        case "keypress":
          c = p;
          break;
        case "mouseenter":
          c = r.enter;
          break;
        case "mouseleave":
          c = r.leave
      }
    }
    return g(a, c, e, s)
  }
  function t(a) {
    a.keyChar = a.charCode ? String.fromCharCode(a.charCode) : "";
    a.charOrCode = a.keyChar || a.keyCode
  }
  h.add("events-keypress-typed", function() {
    var a = {charCode:0};
    try {
      a = document.createEvent("KeyboardEvent"), (a.initKeyboardEvent || a.initKeyEvent).call(a, "keypress", !0, !0, null, !1, !1, !1, !1, 9, 3)
    }catch(c) {
    }
    return 0 == a.charCode && !h("opera")
  });
  var w = {106:42, 111:47, 186:59, 187:43, 188:44, 189:45, 190:46, 191:47, 192:96, 219:91, 220:92, 221:93, 222:39, 229:113}, x = h("mac") ? "metaKey" : "ctrlKey", q = function(a, c) {
    var b = l.mixin({}, a, c);
    t(b);
    b.preventDefault = function() {
      a.preventDefault()
    };
    b.stopPropagation = function() {
      a.stopPropagation()
    };
    return b
  }, p;
  p = h("events-keypress-typed") ? function(a, c) {
    var b = g(a, "keydown", function(a) {
      var d = a.keyCode, b = 13 != d && 32 != d && (27 != d || !h("ie")) && (48 > d || 90 < d) && (96 > d || 111 < d) && (186 > d || 192 < d) && (219 > d || 222 < d) && 229 != d;
      if(b || a.ctrlKey) {
        b = b ? 0 : d;
        if(a.ctrlKey) {
          if(3 == d || 13 == d) {
            return c.call(a.currentTarget, a)
          }
          b = 95 < b && 106 > b ? b - 48 : !a.shiftKey && 65 <= b && 90 >= b ? b + 32 : w[b] || b
        }
        d = q(a, {type:"keypress", faux:!0, charCode:b});
        c.call(a.currentTarget, d);
        if(h("ie")) {
          try {
            a.keyCode = d.keyCode
          }catch(e) {
          }
        }
      }
    }), e = g(a, "keypress", function(a) {
      var b = a.charCode;
      a = q(a, {charCode:32 <= b ? b : 0, faux:!0});
      return c.call(this, a)
    });
    return{remove:function() {
      b.remove();
      e.remove()
    }}
  } : h("opera") ? function(a, c) {
    return g(a, "keypress", function(a) {
      var e = a.which;
      3 == e && (e = 99);
      e = 32 > e && !a.shiftKey ? 0 : e;
      a.ctrlKey && (!a.shiftKey && 65 <= e && 90 >= e) && (e += 32);
      return c.call(this, q(a, {charCode:e}))
    })
  } : function(a, c) {
    return g(a, "keypress", function(a) {
      t(a);
      return c.call(this, a)
    })
  };
  var f = {_keypress:p, connect:function(a, c, b, e, h) {
    var d = arguments, f = [], k = 0;
    f.push("string" == typeof d[0] ? null : d[k++], d[k++]);
    var g = d[k + 1];
    f.push("string" == typeof g || "function" == typeof g ? d[k++] : null, d[k++]);
    for(g = d.length;k < g;k++) {
      f.push(d[k])
    }
    return v.apply(this, f)
  }, disconnect:function(a) {
    a && a.remove()
  }, subscribe:function(a, c, b) {
    return n.subscribe(a, l.hitch(c, b))
  }, publish:function(a, c) {
    return n.publish.apply(n, [a].concat(c))
  }, connectPublisher:function(a, c, b) {
    var e = function() {
      f.publish(a, arguments)
    };
    return b ? f.connect(c, b, e) : f.connect(c, e)
  }, isCopyKey:function(a) {
    return a[x]
  }};
  f.unsubscribe = f.disconnect;
  l.mixin(m, f);
  return f
});

//# sourceMappingURL=connect.js.map