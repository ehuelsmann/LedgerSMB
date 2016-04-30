//>>built
define("dijit/form/_FormSelectWidget", "dojo/_base/array dojo/_base/Deferred dojo/aspect dojo/data/util/sorter dojo/_base/declare dojo/dom dojo/dom-class dojo/_base/kernel dojo/_base/lang dojo/query dojo/when dojo/store/util/QueryResults ./_FormValueWidget".split(" "), function(d, h, k, m, n, p, q, l, e, r, s, t, u) {
  return n("dijit.form._FormSelectWidget", u, {multiple:!1, options:null, store:null, _setStoreAttr:function(a) {
    this._created && this._deprecatedSetStore(a)
  }, query:null, _setQueryAttr:function(a) {
    this._created && this._deprecatedSetStore(this.store, this.selectedValue, {query:a})
  }, queryOptions:null, _setQueryOptionsAttr:function(a) {
    this._created && this._deprecatedSetStore(this.store, this.selectedValue, {queryOptions:a})
  }, labelAttr:"", onFetch:null, sortByLabel:!0, loadChildrenOnOpen:!1, onLoadDeferred:null, getOptions:function(a) {
    var c = this.options || [];
    if(null == a) {
      return c
    }
    if(e.isArray(a)) {
      return d.map(a, "return this.getOptions(item);", this)
    }
    e.isString(a) && (a = {value:a});
    e.isObject(a) && (d.some(c, function(c, d) {
      for(var f in a) {
        if(!(f in c) || c[f] != a[f]) {
          return!1
        }
      }
      a = d;
      return!0
    }) || (a = -1));
    return 0 <= a && a < c.length ? c[a] : null
  }, addOption:function(a) {
    d.forEach(e.isArray(a) ? a : [a], function(a) {
      a && e.isObject(a) && this.options.push(a)
    }, this);
    this._loadChildren()
  }, removeOption:function(a) {
    a = this.getOptions(e.isArray(a) ? a : [a]);
    d.forEach(a, function(a) {
      a && (this.options = d.filter(this.options, function(b) {
        return b.value !== a.value || b.label !== a.label
      }), this._removeOptionItem(a))
    }, this);
    this._loadChildren()
  }, updateOption:function(a) {
    d.forEach(e.isArray(a) ? a : [a], function(a) {
      var b = this.getOptions({value:a.value}), d;
      if(b) {
        for(d in a) {
          b[d] = a[d]
        }
      }
    }, this);
    this._loadChildren()
  }, setStore:function(a, c, b) {
    l.deprecated(this.declaredClass + "::setStore(store, selectedValue, fetchArgs) is deprecated. Use set('query', fetchArgs.query), set('queryOptions', fetchArgs.queryOptions), set('store', store), or set('value', selectedValue) instead.", "", "2.0");
    this._deprecatedSetStore(a, c, b)
  }, _deprecatedSetStore:function(a, c, b) {
    var g = this.store;
    b = b || {};
    if(g !== a) {
      for(var f;f = this._notifyConnections.pop();) {
        f.remove()
      }
      a.get || (e.mixin(a, {_oldAPI:!0, get:function(a) {
        var b = new h;
        this.fetchItemByIdentity({identity:a, onItem:function(a) {
          b.resolve(a)
        }, onError:function(a) {
          b.reject(a)
        }});
        return b.promise
      }, query:function(a, b) {
        var c = new h(function() {
          d.abort && d.abort()
        });
        c.total = new h;
        var d = this.fetch(e.mixin({query:a, onBegin:function(a) {
          c.total.resolve(a)
        }, onComplete:function(a) {
          c.resolve(a)
        }, onError:function(a) {
          c.reject(a)
        }}, b));
        return new t(c)
      }}), a.getFeatures()["dojo.data.api.Notification"] && (this._notifyConnections = [k.after(a, "onNew", e.hitch(this, "_onNewItem"), !0), k.after(a, "onDelete", e.hitch(this, "_onDeleteItem"), !0), k.after(a, "onSet", e.hitch(this, "_onSetItem"), !0)]));
      this._set("store", a)
    }
    this.options && this.options.length && this.removeOption(this.options);
    this._queryRes && this._queryRes.close && this._queryRes.close();
    this._observeHandle && this._observeHandle.remove && (this._observeHandle.remove(), this._observeHandle = null);
    b.query && this._set("query", b.query);
    b.queryOptions && this._set("queryOptions", b.queryOptions);
    a && a.query && (this._loadingStore = !0, this.onLoadDeferred = new h, this._queryRes = a.query(this.query, this.queryOptions), s(this._queryRes, e.hitch(this, function(f) {
      if(this.sortByLabel && !b.sort && f.length) {
        if(a.getValue) {
          f.sort(m.createSortFunction([{attribute:a.getLabelAttributes(f[0])[0]}], a))
        }else {
          var g = this.labelAttr;
          f.sort(function(a, b) {
            return a[g] > b[g] ? 1 : b[g] > a[g] ? -1 : 0
          })
        }
      }
      b.onFetch && (f = b.onFetch.call(this, f, b));
      d.forEach(f, function(a) {
        this._addOptionForItem(a)
      }, this);
      this._queryRes.observe && (this._observeHandle = this._queryRes.observe(e.hitch(this, function(a, b, c) {
        b == c ? this._onSetItem(a) : (-1 != b && this._onDeleteItem(a), -1 != c && this._onNewItem(a))
      }), !0));
      this._loadingStore = !1;
      this.set("value", "_pendingValue" in this ? this._pendingValue : c);
      delete this._pendingValue;
      this.loadChildrenOnOpen ? this._pseudoLoadChildren(f) : this._loadChildren();
      this.onLoadDeferred.resolve(!0);
      this.onSetStore()
    }), function(a) {
      console.error("dijit.form.Select: " + a.toString());
      this.onLoadDeferred.reject(a)
    }));
    return g
  }, _setValueAttr:function(a, c) {
    this._onChangeActive || (c = null);
    if(this._loadingStore) {
      this._pendingValue = a
    }else {
      if(null != a) {
        a = e.isArray(a) ? d.map(a, function(a) {
          return e.isObject(a) ? a : {value:a}
        }) : e.isObject(a) ? [a] : [{value:a}];
        a = d.filter(this.getOptions(a), function(a) {
          return a && a.value
        });
        var b = this.getOptions() || [];
        if(!this.multiple && (!a[0] || !a[0].value) && b.length) {
          a[0] = b[0]
        }
        d.forEach(b, function(b) {
          b.selected = d.some(a, function(a) {
            return a.value === b.value
          })
        });
        b = d.map(a, function(a) {
          return a.value
        });
        if(!("undefined" == typeof b || "undefined" == typeof b[0])) {
          var g = d.map(a, function(a) {
            return a.label
          });
          this._setDisplay(this.multiple ? g : g[0]);
          this.inherited(arguments, [this.multiple ? b : b[0], c]);
          this._updateSelection()
        }
      }
    }
  }, _getDisplayedValueAttr:function() {
    var a = d.map([].concat(this.get("selectedOptions")), function(a) {
      return a && "label" in a ? a.label : a ? a.value : null
    }, this);
    return this.multiple ? a : a[0]
  }, _setDisplayedValueAttr:function(a) {
    this.set("value", this.getOptions("string" == typeof a ? {label:a} : a))
  }, _loadChildren:function() {
    this._loadingStore || (d.forEach(this._getChildren(), function(a) {
      a.destroyRecursive()
    }), d.forEach(this.options, this._addOptionItem, this), this._updateSelection())
  }, _updateSelection:function() {
    this.focusedChild = null;
    this._set("value", this._getValueFromOpts());
    var a = [].concat(this.value);
    if(a && a[0]) {
      var c = this;
      d.forEach(this._getChildren(), function(b) {
        var e = d.some(a, function(a) {
          return b.option && a === b.option.value
        });
        e && !c.multiple && (c.focusedChild = b);
        q.toggle(b.domNode, this.baseClass.replace(/\s+|$/g, "SelectedOption "), e);
        b.domNode.setAttribute("aria-selected", e ? "true" : "false")
      }, this)
    }
  }, _getValueFromOpts:function() {
    var a = this.getOptions() || [];
    if(!this.multiple && a.length) {
      var c = d.filter(a, function(a) {
        return a.selected
      })[0];
      if(c && c.value) {
        return c.value
      }
      a[0].selected = !0;
      return a[0].value
    }
    return this.multiple ? d.map(d.filter(a, function(a) {
      return a.selected
    }), function(a) {
      return a.value
    }) || [] : ""
  }, _onNewItem:function(a, c) {
    (!c || !c.parent) && this._addOptionForItem(a)
  }, _onDeleteItem:function(a) {
    this.removeOption({value:this.store.getIdentity(a)})
  }, _onSetItem:function(a) {
    this.updateOption(this._getOptionObjForItem(a))
  }, _getOptionObjForItem:function(a) {
    var c = this.store, b = this.labelAttr && this.labelAttr in a ? a[this.labelAttr] : c.getLabel(a);
    return{value:b ? c.getIdentity(a) : null, label:b, item:a}
  }, _addOptionForItem:function(a) {
    var c = this.store;
    c.isItemLoaded && !c.isItemLoaded(a) ? c.loadItem({item:a, onItem:function(a) {
      this._addOptionForItem(a)
    }, scope:this}) : (a = this._getOptionObjForItem(a), this.addOption(a))
  }, constructor:function(a) {
    this._oValue = (a || {}).value || null;
    this._notifyConnections = []
  }, buildRendering:function() {
    this.inherited(arguments);
    p.setSelectable(this.focusNode, !1)
  }, _fillContent:function() {
    this.options || (this.options = this.srcNodeRef ? r("\x3e *", this.srcNodeRef).map(function(a) {
      return"separator" === a.getAttribute("type") ? {value:"", label:"", selected:!1, disabled:!1} : {value:a.getAttribute("data-" + l._scopeName + "-value") || a.getAttribute("value"), label:String(a.innerHTML), selected:a.getAttribute("selected") || !1, disabled:a.getAttribute("disabled") || !1}
    }, this) : []);
    this.value ? this.multiple && "string" == typeof this.value && this._set("value", this.value.split(",")) : this._set("value", this._getValueFromOpts())
  }, postCreate:function() {
    this.inherited(arguments);
    k.after(this, "onChange", e.hitch(this, "_updateSelection"));
    var a = this.store;
    if(a && (a.getIdentity || a.getFeatures()["dojo.data.api.Identity"])) {
      this.store = null, this._deprecatedSetStore(a, this._oValue, {query:this.query, queryOptions:this.queryOptions})
    }
    this._storeInitialized = !0
  }, startup:function() {
    this._loadChildren();
    this.inherited(arguments)
  }, destroy:function() {
    for(var a;a = this._notifyConnections.pop();) {
      a.remove()
    }
    this._queryRes && this._queryRes.close && this._queryRes.close();
    this._observeHandle && this._observeHandle.remove && (this._observeHandle.remove(), this._observeHandle = null);
    this.inherited(arguments)
  }, _addOptionItem:function() {
  }, _removeOptionItem:function() {
  }, _setDisplay:function() {
  }, _getChildren:function() {
    return[]
  }, _getSelectedOptionsAttr:function() {
    return this.getOptions({selected:!0})
  }, _pseudoLoadChildren:function() {
  }, onSetStore:function() {
  }})
});

//# sourceMappingURL=_FormSelectWidget.js.map