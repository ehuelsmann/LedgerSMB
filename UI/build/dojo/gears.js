//>>built
define("dojo/gears", ["./_base/lang", "./sniff"], function(c, d) {
  var b = {};
  c.setObject("dojo.gears", b);
  b._gearsObject = function() {
    var a, b = c.getObject("google.gears");
    if(b) {
      return b
    }
    if("undefined" != typeof GearsFactory) {
      a = new GearsFactory
    }else {
      if(d("ie")) {
        try {
          a = new ActiveXObject("Gears.Factory")
        }catch(e) {
        }
      }else {
        navigator.mimeTypes["application/x-googlegears"] && (a = document.createElement("object"), a.setAttribute("type", "application/x-googlegears"), a.setAttribute("width", 0), a.setAttribute("height", 0), a.style.display = "none", document.documentElement.appendChild(a))
      }
    }
    if(!a) {
      return null
    }
    c.setObject("google.gears.factory", a);
    return c.getObject("google.gears")
  };
  b.available = !!b._gearsObject() || 0;
  return b
});

//# sourceMappingURL=gears.js.map