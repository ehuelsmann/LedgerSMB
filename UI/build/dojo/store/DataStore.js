//>>built
define("dojo/store/DataStore", "../_base/lang ../_base/declare ../Deferred ../_base/array ./util/QueryResults ./util/SimpleQueryEngine".split(" "), function(n, p, d, q, r, s) {
  return p("dojo.store.DataStore", null, {target:"", constructor:function(a) {
    n.mixin(this, a);
    if(!1 in a) {
      var c;
      try {
        c = this.store.getIdentityAttributes()
      }catch(b) {
      }
      this.idProperty = !c || !idAttributes[0] || this.idProperty
    }
    a = this.store.getFeatures();
    a["dojo.data.api.Read"] || (this.get = null);
    a["dojo.data.api.Identity"] || (this.getIdentity = null);
    a["dojo.data.api.Write"] || (this.put = this.add = null)
  }, idProperty:"id", store:null, queryEngine:s, _objectConverter:function(a) {
    function c(a) {
      for(var f = {}, m = b.getAttributes(a), l = 0;l < m.length;l++) {
        var k = m[l], d = b.getValues(a, k);
        if(1 < d.length) {
          for(k = 0;k < d.length;k++) {
            var g = d[k];
            "object" == typeof g && b.isItem(g) && (d[k] = c(g))
          }
          g = d
        }else {
          g = b.getValue(a, k), "object" == typeof g && b.isItem(g) && (g = c(g))
        }
        f[m[l]] = g
      }
      !(e in f) && b.getIdentity && (f[e] = b.getIdentity(a));
      return f
    }
    var b = this.store, e = this.idProperty;
    return function(b) {
      return a(b && c(b))
    }
  }, get:function(a, c) {
    var b, e, h = new d;
    this.store.fetchItemByIdentity({identity:a, onItem:this._objectConverter(function(a) {
      h.resolve(b = a)
    }), onError:function(a) {
      h.reject(e = a)
    }});
    if(void 0 !== b) {
      return null == b ? void 0 : b
    }
    if(e) {
      throw e;
    }
    return h.promise
  }, put:function(a, c) {
    c = c || {};
    var b = "undefined" != typeof c.id ? c.id : this.getIdentity(a), e = this.store, h = this.idProperty, f = new d;
    "undefined" == typeof b ? (e.newItem(a), e.save({onComplete:function() {
      f.resolve(a)
    }, onError:function(a) {
      f.reject(a)
    }})) : e.fetchItemByIdentity({identity:b, onItem:function(b) {
      if(b) {
        if(!1 === c.overwrite) {
          return f.reject(Error("Overwriting existing object not allowed"))
        }
        for(var d in a) {
          d != h && (a.hasOwnProperty(d) && e.getValue(b, d) != a[d]) && e.setValue(b, d, a[d])
        }
      }else {
        if(!0 === c.overwrite) {
          return f.reject(Error("Creating new object not allowed"))
        }
        e.newItem(a)
      }
      e.save({onComplete:function() {
        f.resolve(a)
      }, onError:function(a) {
        f.reject(a)
      }})
    }, onError:function(a) {
      f.reject(a)
    }});
    return f.promise
  }, add:function(a, c) {
    (c = c || {}).overwrite = !1;
    return this.put(a, c)
  }, remove:function(a) {
    var c = this.store, b = new d;
    this.store.fetchItemByIdentity({identity:a, onItem:function(a) {
      try {
        null == a ? b.resolve(!1) : (c.deleteItem(a), c.save(), b.resolve(!0))
      }catch(d) {
        b.reject(d)
      }
    }, onError:function(a) {
      b.reject(a)
    }});
    return b.promise
  }, query:function(a, c) {
    var b, e = new d(function() {
      b.abort && b.abort()
    });
    e.total = new d;
    var h = this._objectConverter(function(a) {
      return a
    });
    b = this.store.fetch(n.mixin({query:a, onBegin:function(a) {
      e.total.resolve(a)
    }, onComplete:function(a) {
      e.resolve(q.map(a, h))
    }, onError:function(a) {
      e.reject(a)
    }}, c));
    return r(e)
  }, getIdentity:function(a) {
    return a[this.idProperty]
  }})
});

//# sourceMappingURL=DataStore.js.map