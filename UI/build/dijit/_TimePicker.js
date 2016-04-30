//>>built
define("dijit/_TimePicker", "dojo/_base/array dojo/date dojo/date/locale dojo/date/stamp dojo/_base/declare dojo/dom-class dojo/dom-construct dojo/_base/kernel dojo/keys dojo/_base/lang dojo/sniff dojo/query dojo/mouse dojo/on ./_WidgetBase ./form/_ListMouseMixin".split(" "), function(g, h, k, f, l, c, m, n, e, r, s, t, u, v, p, q) {
  return l("dijit._TimePicker", [p, q], {baseClass:"dijitTimePicker", pickerMin:"T00:00:00", pickerMax:"T23:59:59", clickableIncrement:"T00:15:00", visibleIncrement:"T01:00:00", value:new Date, _visibleIncrement:2, _clickableIncrement:1, _totalIncrements:10, constraints:{}, serialize:f.toISOString, buildRendering:function() {
    this.inherited(arguments);
    this.timeMenu = this.containerNode = this.domNode
  }, setValue:function(a) {
    n.deprecated("dijit._TimePicker:setValue() is deprecated.  Use set('value', ...) instead.", "", "2.0");
    this.set("value", a)
  }, _setValueAttr:function(a) {
    this._set("value", a);
    this._showText()
  }, _setFilterStringAttr:function(a) {
    this._set("filterString", a);
    this._showText()
  }, isDisabledDate:function() {
    return!1
  }, _getFilteredNodes:function(a, b, c, d) {
    a = [];
    for(b = 0;b < this._maxIncrement;b++) {
      (c = this._createOption(b)) && a.push(c)
    }
    return a
  }, _showText:function() {
    var a = f.fromISOString;
    this.domNode.innerHTML = "";
    this._clickableIncrementDate = a(this.clickableIncrement);
    this._visibleIncrementDate = a(this.visibleIncrement);
    var b = 3600 * this._clickableIncrementDate.getHours() + 60 * this._clickableIncrementDate.getMinutes() + this._clickableIncrementDate.getSeconds(), c = 3600 * this._visibleIncrementDate.getHours() + 60 * this._visibleIncrementDate.getMinutes() + this._visibleIncrementDate.getSeconds();
    (this.value || this.currentFocus).getTime();
    this._refDate = a(this.pickerMin);
    this._refDate.setFullYear(1970, 0, 1);
    this._clickableIncrement = 1;
    this._visibleIncrement = c / b;
    a = a(this.pickerMax);
    a.setFullYear(1970, 0, 1);
    a = 0.001 * (a.getTime() - this._refDate.getTime());
    this._maxIncrement = Math.ceil((a + 1) / b);
    b = this._getFilteredNodes();
    g.forEach(b, function(a) {
      this.domNode.appendChild(a)
    }, this);
    !b.length && this.filterString && (this.filterString = "", this._showText())
  }, constructor:function() {
    this.constraints = {}
  }, postMixInProperties:function() {
    this.inherited(arguments);
    this._setConstraintsAttr(this.constraints)
  }, _setConstraintsAttr:function(a) {
    for(var b in{clickableIncrement:1, visibleIncrement:1, pickerMin:1, pickerMax:1}) {
      b in a && (this[b] = a[b])
    }
    a.locale || (a.locale = this.lang)
  }, _createOption:function(a) {
    var b = new Date(this._refDate), e = this._clickableIncrementDate;
    b.setHours(b.getHours() + e.getHours() * a, b.getMinutes() + e.getMinutes() * a, b.getSeconds() + e.getSeconds() * a);
    "time" == this.constraints.selector && b.setFullYear(1970, 0, 1);
    e = k.format(b, this.constraints);
    if(this.filterString && 0 !== e.toLowerCase().indexOf(this.filterString)) {
      return null
    }
    var d = this.ownerDocument.createElement("div");
    d.className = this.baseClass + "Item";
    d.date = b;
    d.idx = a;
    m.create("div", {"class":this.baseClass + "ItemInner", innerHTML:e}, d);
    1 > a % this._visibleIncrement && -1 < a % this._visibleIncrement ? c.add(d, this.baseClass + "Marker") : a % this._clickableIncrement || c.add(d, this.baseClass + "Tick");
    this.isDisabledDate(b) && c.add(d, this.baseClass + "ItemDisabled");
    this.value && !h.compare(this.value, b, this.constraints.selector) && (d.selected = !0, c.add(d, this.baseClass + "ItemSelected"), this._selectedDiv = d, c.contains(d, this.baseClass + "Marker") ? c.add(d, this.baseClass + "MarkerSelected") : c.add(d, this.baseClass + "TickSelected"), this._highlightOption(d, !0));
    return d
  }, onOpen:function() {
    this.inherited(arguments);
    this.set("selected", this._selectedDiv)
  }, _onOptionSelected:function(a) {
    if((a = a.target.date || a.target.parentNode.date) && !this.isDisabledDate(a)) {
      this._highlighted_option = null, this.set("value", a), this.onChange(a)
    }
  }, onChange:function() {
  }, _highlightOption:function(a, b) {
    if(a) {
      if(b) {
        this._highlighted_option && this._highlightOption(this._highlighted_option, !1), this._highlighted_option = a
      }else {
        if(this._highlighted_option !== a) {
          return
        }
        this._highlighted_option = null
      }
      c.toggle(a, this.baseClass + "ItemHover", b);
      c.contains(a, this.baseClass + "Marker") ? c.toggle(a, this.baseClass + "MarkerHover", b) : c.toggle(a, this.baseClass + "TickHover", b)
    }
  }, handleKey:function(a) {
    if(a.keyCode == e.DOWN_ARROW) {
      return this.selectNextNode(), a.stopPropagation(), a.preventDefault(), !1
    }
    if(a.keyCode == e.UP_ARROW) {
      return this.selectPreviousNode(), a.stopPropagation(), a.preventDefault(), !1
    }
    if(a.keyCode == e.ENTER || a.keyCode === e.TAB) {
      if(!this._keyboardSelected && a.keyCode === e.TAB) {
        return!0
      }
      this._highlighted_option && this._onOptionSelected({target:this._highlighted_option});
      return a.keyCode === e.TAB
    }
  }, onHover:function(a) {
    this._highlightOption(a, !0)
  }, onUnhover:function(a) {
    this._highlightOption(a, !1)
  }, onSelect:function(a) {
    this._highlightOption(a, !0)
  }, onDeselect:function(a) {
    this._highlightOption(a, !1)
  }, onClick:function(a) {
    this._onOptionSelected({target:a})
  }})
});

//# sourceMappingURL=_TimePicker.js.map