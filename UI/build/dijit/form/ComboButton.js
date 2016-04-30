//>>built
require({cache:{"url:dijit/form/templates/ComboButton.html":'\x3ctable class\x3d"dijit dijitReset dijitInline dijitLeft"\n\tcellspacing\x3d\'0\' cellpadding\x3d\'0\' role\x3d"presentation"\n\t\x3e\x3ctbody role\x3d"presentation"\x3e\x3ctr role\x3d"presentation"\n\t\t\x3e\x3ctd class\x3d"dijitReset dijitStretch dijitButtonNode" data-dojo-attach-point\x3d"buttonNode" data-dojo-attach-event\x3d"ondijitclick:__onClick,onkeydown:_onButtonKeyDown"\n\t\t\x3e\x3cdiv id\x3d"${id}_button" class\x3d"dijitReset dijitButtonContents"\n\t\t\tdata-dojo-attach-point\x3d"titleNode"\n\t\t\trole\x3d"button" aria-labelledby\x3d"${id}_label"\n\t\t\t\x3e\x3cdiv class\x3d"dijitReset dijitInline dijitIcon" data-dojo-attach-point\x3d"iconNode" role\x3d"presentation"\x3e\x3c/div\n\t\t\t\x3e\x3cdiv class\x3d"dijitReset dijitInline dijitButtonText" id\x3d"${id}_label" data-dojo-attach-point\x3d"containerNode" role\x3d"presentation"\x3e\x3c/div\n\t\t\x3e\x3c/div\n\t\t\x3e\x3c/td\n\t\t\x3e\x3ctd id\x3d"${id}_arrow" class\x3d\'dijitReset dijitRight dijitButtonNode dijitArrowButton\'\n\t\t\tdata-dojo-attach-point\x3d"_popupStateNode,focusNode,_buttonNode"\n\t\t\tdata-dojo-attach-event\x3d"onkeydown:_onArrowKeyDown"\n\t\t\ttitle\x3d"${optionsTitle}"\n\t\t\trole\x3d"button" aria-haspopup\x3d"true"\n\t\t\t\x3e\x3cdiv class\x3d"dijitReset dijitArrowButtonInner" role\x3d"presentation"\x3e\x3c/div\n\t\t\t\x3e\x3cdiv class\x3d"dijitReset dijitArrowButtonChar" role\x3d"presentation"\x3e\x26#9660;\x3c/div\n\t\t\x3e\x3c/td\n\t\t\x3e\x3ctd style\x3d"display:none !important;"\n\t\t\t\x3e\x3cinput ${!nameAttrSetting} type\x3d"${type}" value\x3d"${value}" data-dojo-attach-point\x3d"valueNode"\n\t\t\t\tclass\x3d"dijitOffScreen"\n\t\t\t\trole\x3d"presentation" aria-hidden\x3d"true"\n\t\t\t\tdata-dojo-attach-event\x3d"onclick:_onClick"\n\t\t/\x3e\x3c/td\x3e\x3c/tr\x3e\x3c/tbody\n\x3e\x3c/table\x3e\n'}});
define("dijit/form/ComboButton", "dojo/_base/declare dojo/keys ../focus ./DropDownButton dojo/text!./templates/ComboButton.html ../a11yclick".split(" "), function(d, c, b, e, f) {
  return d("dijit.form.ComboButton", e, {templateString:f, _setIdAttr:"", _setTabIndexAttr:["focusNode", "titleNode"], _setTitleAttr:"titleNode", optionsTitle:"", baseClass:"dijitComboButton", cssStateNodes:{buttonNode:"dijitButtonNode", titleNode:"dijitButtonContents", _popupStateNode:"dijitDownArrowButton"}, _focusedNode:null, _onButtonKeyDown:function(a) {
    if(a.keyCode == c[this.isLeftToRight() ? "RIGHT_ARROW" : "LEFT_ARROW"]) {
      b.focus(this._popupStateNode), a.stopPropagation(), a.preventDefault()
    }
  }, _onArrowKeyDown:function(a) {
    if(a.keyCode == c[this.isLeftToRight() ? "LEFT_ARROW" : "RIGHT_ARROW"]) {
      b.focus(this.titleNode), a.stopPropagation(), a.preventDefault()
    }
  }, focus:function(a) {
    this.disabled || b.focus("start" == a ? this.titleNode : this._popupStateNode)
  }})
});

//# sourceMappingURL=ComboButton.js.map