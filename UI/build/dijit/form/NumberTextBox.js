//>>built
define("dijit/form/NumberTextBox", "dojo/_base/declare dojo/_base/lang dojo/i18n dojo/string dojo/number ./RangeBoundTextBox".split(" "), function(f, d, g, m, e, n) {
  var k = function(a) {
    a = a || {};
    var b = g.getLocalization("dojo.cldr", "number", g.normalizeLocale(a.locale)), c = a.pattern ? a.pattern : b[(a.type || "decimal") + "Format"];
    a = "number" == typeof a.places ? a.places : "string" === typeof a.places && 0 < a.places.length ? a.places.replace(/.*,/, "") : -1 != c.indexOf(".") ? c.split(".")[1].replace(/[^#0]/g, "").length : 0;
    return{sep:b.decimal, places:a}
  }, l = f("dijit.form.NumberTextBoxMixin", null, {pattern:function(a) {
    return"(" + (this.focused && this.editOptions ? this._regExpGenerator(d.delegate(a, this.editOptions)) + "|" : "") + this._regExpGenerator(a) + ")"
  }, value:NaN, editOptions:{pattern:"#.######"}, _formatter:e.format, _regExpGenerator:e.regexp, _decimalInfo:k(), postMixInProperties:function() {
    this.inherited(arguments);
    this._set("type", "text")
  }, _setConstraintsAttr:function(a) {
    var b = "number" == typeof a.places ? a.places : 0;
    b && b++;
    "number" != typeof a.max && (a.max = 9 * Math.pow(10, 15 - b));
    "number" != typeof a.min && (a.min = -9 * Math.pow(10, 15 - b));
    this.inherited(arguments, [a]);
    this.focusNode && (this.focusNode.value && !isNaN(this.value)) && this.set("value", this.value);
    this._decimalInfo = k(a)
  }, _onFocus:function() {
    if(!this.disabled && !this.readOnly) {
      var a = this.get("value");
      "number" == typeof a && !isNaN(a) && (a = this.format(a, this.constraints), void 0 !== a && (this.textbox.value = a));
      this.inherited(arguments)
    }
  }, format:function(a, b) {
    var c = String(a);
    if("number" != typeof a) {
      return c
    }
    if(isNaN(a)) {
      return""
    }
    if(!("rangeCheck" in this && this.rangeCheck(a, b)) && !1 !== b.exponent && /\de[-+]?\d/i.test(c)) {
      return c
    }
    this.editOptions && this.focused && (b = d.mixin({}, b, this.editOptions));
    return this._formatter(a, b)
  }, _parser:e.parse, parse:function(a, b) {
    var c = this._parser(a, d.mixin({}, b, this.editOptions && this.focused ? this.editOptions : {}));
    this.editOptions && (this.focused && isNaN(c)) && (c = this._parser(a, b));
    return c
  }, _getDisplayedValueAttr:function() {
    var a = this.inherited(arguments);
    return isNaN(a) ? this.textbox.value : a
  }, filter:function(a) {
    if(null == a || "string" == typeof a && "" == a) {
      return NaN
    }
    "number" == typeof a && (!isNaN(a) && 0 != a) && (a = e.round(a, this._decimalInfo.places));
    return this.inherited(arguments, [a])
  }, serialize:function(a, b) {
    return"number" != typeof a || isNaN(a) ? "" : this.inherited(arguments)
  }, _setBlurValue:function() {
    var a = d.hitch(d.delegate(this, {focused:!0}), "get")("value");
    this._setValueAttr(a, !0)
  }, _setValueAttr:function(a, b, c) {
    if(void 0 !== a && void 0 === c) {
      if(c = String(a), "number" == typeof a) {
        if(isNaN(a)) {
          c = ""
        }else {
          if("rangeCheck" in this && this.rangeCheck(a, this.constraints) || !1 === this.constraints.exponent || !/\de[-+]?\d/i.test(c)) {
            c = void 0
          }
        }
      }else {
        a ? a = void 0 : (c = "", a = NaN)
      }
    }
    this.inherited(arguments, [a, b, c])
  }, _getValueAttr:function() {
    var a = this.inherited(arguments);
    if(isNaN(a) && "" !== this.textbox.value) {
      if(!1 !== this.constraints.exponent && /\de[-+]?\d/i.test(this.textbox.value) && RegExp("^" + e._realNumberRegexp(d.delegate(this.constraints)) + "$").test(this.textbox.value)) {
        return a = Number(this.textbox.value), isNaN(a) ? void 0 : a
      }
    }else {
      return a
    }
  }, isValid:function(a) {
    if(!this.focused || this._isEmpty(this.textbox.value)) {
      return this.inherited(arguments)
    }
    var b = this.get("value");
    return!isNaN(b) && this.rangeCheck(b, this.constraints) ? !1 !== this.constraints.exponent && /\de[-+]?\d/i.test(this.textbox.value) ? !0 : this.inherited(arguments) : !1
  }, _isValidSubset:function() {
    var a = "number" == typeof this.constraints.min, b = "number" == typeof this.constraints.max, c = this.get("value");
    if(isNaN(c) || !a && !b) {
      return this.inherited(arguments)
    }
    var d = c | 0, f = 0 > c, e = -1 != this.textbox.value.indexOf(this._decimalInfo.sep), h = (this.maxLength || 20) - this.textbox.value.length, g = e ? this.textbox.value.split(this._decimalInfo.sep)[1].replace(/[^0-9]/g, "") : "", d = e ? d + "." + g : d + "", h = m.rep("9", h), e = c;
    f ? e = Number(d + h) : c = Number(d + h);
    return!(a && c < this.constraints.min || b && e > this.constraints.max)
  }});
  f = f("dijit.form.NumberTextBox", [n, l], {baseClass:"dijitTextBox dijitNumberTextBox"});
  f.Mixin = l;
  return f
});

//# sourceMappingURL=NumberTextBox.js.map