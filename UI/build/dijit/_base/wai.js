//>>built
define("dijit/_base/wai", ["dojo/dom-attr", "dojo/_base/lang", "../main", "../hccss"], function(d, e, f) {
  e.mixin(f, {hasWaiRole:function(a, b) {
    var c = this.getWaiRole(a);
    return b ? -1 < c.indexOf(b) : 0 < c.length
  }, getWaiRole:function(a) {
    return e.trim((d.get(a, "role") || "").replace("wairole:", ""))
  }, setWaiRole:function(a, b) {
    d.set(a, "role", b)
  }, removeWaiRole:function(a, b) {
    var c = d.get(a, "role");
    c && (b ? (c = e.trim((" " + c + " ").replace(" " + b + " ", " ")), d.set(a, "role", c)) : a.removeAttribute("role"))
  }, hasWaiState:function(a, b) {
    return a.hasAttribute ? a.hasAttribute("aria-" + b) : !!a.getAttribute("aria-" + b)
  }, getWaiState:function(a, b) {
    return a.getAttribute("aria-" + b) || ""
  }, setWaiState:function(a, b, c) {
    a.setAttribute("aria-" + b, c)
  }, removeWaiState:function(a, b) {
    a.removeAttribute("aria-" + b)
  }});
  return f
});

//# sourceMappingURL=wai.js.map