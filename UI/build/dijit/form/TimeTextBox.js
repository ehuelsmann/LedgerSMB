//>>built
define("dijit/form/TimeTextBox", ["dojo/_base/declare", "dojo/keys", "dojo/_base/lang", "../_TimePicker", "./_DateTimeTextBox"], function(b, a, e, c, d) {
  return b("dijit.form.TimeTextBox", d, {baseClass:"dijitTextBox dijitComboBox dijitTimeTextBox", popupClass:c, _selector:"time", value:new Date(""), maxHeight:-1, _onKey:function(b) {
    if(!this.disabled && !this.readOnly) {
      switch(this.inherited(arguments), b.keyCode) {
        case a.ENTER:
        ;
        case a.TAB:
        ;
        case a.ESCAPE:
        ;
        case a.DOWN_ARROW:
        ;
        case a.UP_ARROW:
          break;
        default:
          this.defer(function() {
            var a = this.get("displayedValue");
            this.filterString = a && !this.parse(a, this.constraints) ? a.toLowerCase() : "";
            this._opened && this.closeDropDown();
            this.openDropDown()
          })
      }
    }
  }})
});

//# sourceMappingURL=TimeTextBox.js.map