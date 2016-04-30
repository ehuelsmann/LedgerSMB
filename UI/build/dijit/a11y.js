//>>built
define("dijit/a11y", "dojo/_base/array dojo/dom dojo/dom-attr dojo/dom-style dojo/_base/lang dojo/sniff ./main".split(" "), function(v, g, f, m, s, t, u) {
  var e = {_isElementShown:function(a) {
    var c = m.get(a);
    return"hidden" != c.visibility && "collapsed" != c.visibility && "none" != c.display && "hidden" != f.get(a, "type")
  }, hasDefaultTabStop:function(a) {
    switch(a.nodeName.toLowerCase()) {
      case "a":
        return f.has(a, "href");
      case "area":
      ;
      case "button":
      ;
      case "input":
      ;
      case "object":
      ;
      case "select":
      ;
      case "textarea":
        return!0;
      case "iframe":
        var c;
        try {
          var d = a.contentDocument;
          if("designMode" in d && "on" == d.designMode) {
            return!0
          }
          c = d.body
        }catch(e) {
          try {
            c = a.contentWindow.document.body
          }catch(h) {
            return!1
          }
        }
        return c && ("true" == c.contentEditable || c.firstChild && "true" == c.firstChild.contentEditable);
      default:
        return"true" == a.contentEditable
    }
  }, effectiveTabIndex:function(a) {
    return f.get(a, "disabled") ? void 0 : f.has(a, "tabIndex") ? +f.get(a, "tabIndex") : e.hasDefaultTabStop(a) ? 0 : void 0
  }, isTabNavigable:function(a) {
    return 0 <= e.effectiveTabIndex(a)
  }, isFocusable:function(a) {
    return-1 <= e.effectiveTabIndex(a)
  }, _getTabNavigable:function(a) {
    function c(b) {
      return b && "input" == b.tagName.toLowerCase() && b.type && "radio" == b.type.toLowerCase() && b.name && b.name.toLowerCase()
    }
    var d, n, h, g, l, p, k = {}, q = e._isElementShown, m = e.effectiveTabIndex, r = function(b) {
      for(b = b.firstChild;b;b = b.nextSibling) {
        if(!(1 != b.nodeType || 9 >= t("ie") && "HTML" !== b.scopeName || !q(b))) {
          var a = m(b);
          if(0 <= a) {
            if(0 == a) {
              d || (d = b), n = b
            }else {
              if(0 < a) {
                if(!h || a < g) {
                  g = a, h = b
                }
                if(!l || a >= p) {
                  p = a, l = b
                }
              }
            }
            a = c(b);
            f.get(b, "checked") && a && (k[a] = b)
          }
          "SELECT" != b.nodeName.toUpperCase() && r(b)
        }
      }
    };
    q(a) && r(a);
    return{first:k[c(d)] || d, last:k[c(n)] || n, lowest:k[c(h)] || h, highest:k[c(l)] || l}
  }, getFirstInTabbingOrder:function(a, c) {
    var d = e._getTabNavigable(g.byId(a, c));
    return d.lowest ? d.lowest : d.first
  }, getLastInTabbingOrder:function(a, c) {
    var d = e._getTabNavigable(g.byId(a, c));
    return d.last ? d.last : d.highest
  }};
  s.mixin(u, e);
  return e
});

//# sourceMappingURL=a11y.js.map