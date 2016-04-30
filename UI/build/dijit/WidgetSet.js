//>>built
define("dijit/WidgetSet", ["dojo/_base/array", "dojo/_base/declare", "dojo/_base/kernel", "./registry"], function(e, k, f, l) {
  var g = k("dijit.WidgetSet", null, {constructor:function() {
    this._hash = {};
    this.length = 0
  }, add:function(a) {
    if(this._hash[a.id]) {
      throw Error("Tried to register widget with id\x3d\x3d" + a.id + " but that id is already registered");
    }
    this._hash[a.id] = a;
    this.length++
  }, remove:function(a) {
    this._hash[a] && (delete this._hash[a], this.length--)
  }, forEach:function(a, b) {
    b = b || f.global;
    var d = 0, c;
    for(c in this._hash) {
      a.call(b, this._hash[c], d++, this._hash)
    }
    return this
  }, filter:function(a, b) {
    b = b || f.global;
    var d = new g, c = 0, e;
    for(e in this._hash) {
      var h = this._hash[e];
      a.call(b, h, c++, this._hash) && d.add(h)
    }
    return d
  }, byId:function(a) {
    return this._hash[a]
  }, byClass:function(a) {
    var b = new g, d, c;
    for(d in this._hash) {
      c = this._hash[d], c.declaredClass == a && b.add(c)
    }
    return b
  }, toArray:function() {
    var a = [], b;
    for(b in this._hash) {
      a.push(this._hash[b])
    }
    return a
  }, map:function(a, b) {
    return e.map(this.toArray(), a, b)
  }, every:function(a, b) {
    b = b || f.global;
    var d = 0, c;
    for(c in this._hash) {
      if(!a.call(b, this._hash[c], d++, this._hash)) {
        return!1
      }
    }
    return!0
  }, some:function(a, b) {
    b = b || f.global;
    var d = 0, c;
    for(c in this._hash) {
      if(a.call(b, this._hash[c], d++, this._hash)) {
        return!0
      }
    }
    return!1
  }});
  e.forEach("forEach filter byClass map every some".split(" "), function(a) {
    l[a] = g.prototype[a]
  });
  return g
});

//# sourceMappingURL=WidgetSet.js.map