//>>built
define("dojo/dnd/Container", "../_base/array ../_base/declare ../_base/kernel ../_base/lang ../_base/window ../dom ../dom-class ../dom-construct ../Evented ../has ../on ../query ../touch ./common".split(" "), function(r, n, s, h, v, p, g, l, t, w, m, u, q, e) {
  n = n("dojo.dnd.Container", t, {skipForm:!1, allowNested:!1, constructor:function(a, b) {
    this.node = p.byId(a);
    b || (b = {});
    this.creator = b.creator || null;
    this.skipForm = b.skipForm;
    this.parent = b.dropParent && p.byId(b.dropParent);
    this.map = {};
    this.current = null;
    this.containerState = "";
    g.add(this.node, "dojoDndContainer");
    (!b || !b._skipStartup) && this.startup();
    this.events = [m(this.node, q.over, h.hitch(this, "onMouseOver")), m(this.node, q.out, h.hitch(this, "onMouseOut")), m(this.node, "dragstart", h.hitch(this, "onSelectStart")), m(this.node, "selectstart", h.hitch(this, "onSelectStart"))]
  }, creator:function() {
  }, getItem:function(a) {
    return this.map[a]
  }, setItem:function(a, b) {
    this.map[a] = b
  }, delItem:function(a) {
    delete this.map[a]
  }, forInItems:function(a, b) {
    b = b || s.global;
    var c = this.map, d = e._empty, f;
    for(f in c) {
      f in d || a.call(b, c[f], f, this)
    }
    return b
  }, clearItems:function() {
    this.map = {}
  }, getAllNodes:function() {
    return u((this.allowNested ? "" : "\x3e ") + ".dojoDndItem", this.parent)
  }, sync:function() {
    var a = {};
    this.getAllNodes().forEach(function(b) {
      if(b.id) {
        var c = this.getItem(b.id);
        if(c) {
          a[b.id] = c;
          return
        }
      }else {
        b.id = e.getUniqueId()
      }
      var c = b.getAttribute("dndType"), d = b.getAttribute("dndData");
      a[b.id] = {data:d || b.innerHTML, type:c ? c.split(/\s*,\s*/) : ["text"]}
    }, this);
    this.map = a;
    return this
  }, insertNodes:function(a, b, c) {
    this.parent.firstChild ? b ? c || (c = this.parent.firstChild) : c && (c = c.nextSibling) : c = null;
    var d;
    if(c) {
      for(b = 0;b < a.length;++b) {
        d = this._normalizedCreator(a[b]), this.setItem(d.node.id, {data:d.data, type:d.type}), c.parentNode.insertBefore(d.node, c)
      }
    }else {
      for(b = 0;b < a.length;++b) {
        d = this._normalizedCreator(a[b]), this.setItem(d.node.id, {data:d.data, type:d.type}), this.parent.appendChild(d.node)
      }
    }
    return this
  }, destroy:function() {
    r.forEach(this.events, function(a) {
      a.remove()
    });
    this.clearItems();
    this.node = this.parent = this.current = null
  }, markupFactory:function(a, b, c) {
    a._skipStartup = !0;
    return new c(b, a)
  }, startup:function() {
    if(!this.parent && (this.parent = this.node, "table" == this.parent.tagName.toLowerCase())) {
      var a = this.parent.getElementsByTagName("tbody");
      a && a.length && (this.parent = a[0])
    }
    this.defaultCreator = e._defaultCreator(this.parent);
    this.sync()
  }, onMouseOver:function(a) {
    for(var b = a.relatedTarget;b && b != this.node;) {
      try {
        b = b.parentNode
      }catch(c) {
        b = null
      }
    }
    b || (this._changeState("Container", "Over"), this.onOverEvent());
    b = this._getChildByEvent(a);
    this.current != b && (this.current && this._removeItemClass(this.current, "Over"), b && this._addItemClass(b, "Over"), this.current = b)
  }, onMouseOut:function(a) {
    for(a = a.relatedTarget;a;) {
      if(a == this.node) {
        return
      }
      try {
        a = a.parentNode
      }catch(b) {
        a = null
      }
    }
    this.current && (this._removeItemClass(this.current, "Over"), this.current = null);
    this._changeState("Container", "");
    this.onOutEvent()
  }, onSelectStart:function(a) {
    if(!this.skipForm || !e.isFormElement(a)) {
      a.stopPropagation(), a.preventDefault()
    }
  }, onOverEvent:function() {
  }, onOutEvent:function() {
  }, _changeState:function(a, b) {
    var c = "dojoDnd" + a, d = a.toLowerCase() + "State";
    g.replace(this.node, c + b, c + this[d]);
    this[d] = b
  }, _addItemClass:function(a, b) {
    g.add(a, "dojoDndItem" + b)
  }, _removeItemClass:function(a, b) {
    g.remove(a, "dojoDndItem" + b)
  }, _getChildByEvent:function(a) {
    if(a = a.target) {
      for(var b = a.parentNode;b;a = b, b = a.parentNode) {
        if((b == this.parent || this.allowNested) && g.contains(a, "dojoDndItem")) {
          return a
        }
      }
    }
    return null
  }, _normalizedCreator:function(a, b) {
    var c = (this.creator || this.defaultCreator).call(this, a, b);
    h.isArray(c.type) || (c.type = ["text"]);
    c.node.id || (c.node.id = e.getUniqueId());
    g.add(c.node, "dojoDndItem");
    return c
  }});
  e._createNode = function(a) {
    return!a ? e._createSpan : function(b) {
      return l.create(a, {innerHTML:b})
    }
  };
  e._createTrTd = function(a) {
    var b = l.create("tr");
    l.create("td", {innerHTML:a}, b);
    return b
  };
  e._createSpan = function(a) {
    return l.create("span", {innerHTML:a})
  };
  e._defaultCreatorNodes = {ul:"li", ol:"li", div:"div", p:"div"};
  e._defaultCreator = function(a) {
    a = a.tagName.toLowerCase();
    var b = "tbody" == a || "thead" == a ? e._createTrTd : e._createNode(e._defaultCreatorNodes[a]);
    return function(a, d) {
      var f = a && h.isObject(a), g, k;
      f && a.tagName && a.nodeType && a.getAttribute ? (g = a.getAttribute("dndData") || a.innerHTML, f = (f = a.getAttribute("dndType")) ? f.split(/\s*,\s*/) : ["text"], k = a) : (g = f && a.data ? a.data : a, f = f && a.type ? a.type : ["text"], k = ("avatar" == d ? e._createSpan : b)(String(g)));
      k.id || (k.id = e.getUniqueId());
      return{node:k, data:g, type:f}
    }
  };
  return n
});

//# sourceMappingURL=Container.js.map