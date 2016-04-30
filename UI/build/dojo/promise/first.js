//>>built
define("dojo/promise/first", ["../_base/array", "../Deferred", "../when"], function(f, d, g) {
  var h = f.forEach;
  return function(a) {
    var b;
    if(a instanceof Array) {
      b = a
    }else {
      if(a && "object" === typeof a) {
        b = [];
        for(var e in a) {
          Object.hasOwnProperty.call(a, e) && b.push(a[e])
        }
      }
    }
    if(!b || !b.length) {
      return(new d).resolve()
    }
    var c = new d;
    h(b, function(a) {
      g(a, c.resolve, c.reject)
    });
    return c.promise
  }
});

//# sourceMappingURL=first.js.map