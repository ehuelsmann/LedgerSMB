//>>built
define("dijit/Editor", "require dojo/_base/array dojo/_base/declare dojo/Deferred dojo/i18n dojo/dom-attr dojo/dom-class dojo/dom-geometry dojo/dom-style dojo/keys dojo/_base/lang dojo/sniff dojo/string dojo/topic ./_Container ./Toolbar ./ToolbarSeparator ./layout/_LayoutWidget ./form/ToggleButton ./_editor/_Plugin ./_editor/plugins/EnterKeyHandling ./_editor/html ./_editor/range ./_editor/RichText ./main dojo/i18n!./_editor/nls/commands".split(" "), function(v, l, q, w, x, y, s, t, r, d, h, g, z, 
A, I, B, C, D, E, m, F, u, f, G, H) {
  function e(a) {
    return new m({command:a.name})
  }
  function n(a) {
    return new m({buttonClass:E, command:a.name})
  }
  q = q("dijit.Editor", G, {plugins:null, extraPlugins:null, constructor:function() {
    h.isArray(this.plugins) || (this.plugins = ["undo", "redo", "|", "cut", "copy", "paste", "|", "bold", "italic", "underline", "strikethrough", "|", "insertOrderedList", "insertUnorderedList", "indent", "outdent", "|", "justifyLeft", "justifyRight", "justifyCenter", "justifyFull", F]);
    this._plugins = [];
    this._editInterval = 1E3 * this.editActionInterval;
    if(g("ie") || g("trident")) {
      this.events.push("onBeforeDeactivate"), this.events.push("onBeforeActivate")
    }
  }, postMixInProperties:function() {
    this.setValueDeferred = new w;
    this.inherited(arguments)
  }, postCreate:function() {
    this.inherited(arguments);
    this._steps = this._steps.slice(0);
    this._undoedSteps = this._undoedSteps.slice(0);
    h.isArray(this.extraPlugins) && (this.plugins = this.plugins.concat(this.extraPlugins));
    this.commands = x.getLocalization("dijit._editor", "commands", this.lang);
    g("webkit") && r.set(this.domNode, "KhtmlUserSelect", "none")
  }, startup:function() {
    this.inherited(arguments);
    this.toolbar || (this.toolbar = new B({ownerDocument:this.ownerDocument, dir:this.dir, lang:this.lang, "aria-label":this.id}), this.header.appendChild(this.toolbar.domNode));
    l.forEach(this.plugins, this.addPlugin, this);
    this.setValueDeferred.resolve(!0);
    s.add(this.iframe.parentNode, "dijitEditorIFrameContainer");
    s.add(this.iframe, "dijitEditorIFrame");
    y.set(this.iframe, "allowTransparency", !0);
    this.toolbar.startup();
    this.onNormalizedDisplayChanged()
  }, destroy:function() {
    l.forEach(this._plugins, function(a) {
      a && a.destroy && a.destroy()
    });
    this._plugins = [];
    this.toolbar.destroyRecursive();
    delete this.toolbar;
    this.inherited(arguments)
  }, addPlugin:function(a, b) {
    var c = h.isString(a) ? {name:a} : h.isFunction(a) ? {ctor:a} : a;
    if(!c.setEditor) {
      var p = {args:c, plugin:null, editor:this};
      c.name && (m.registry[c.name] ? p.plugin = m.registry[c.name](c) : A.publish(H._scopeName + ".Editor.getPlugin", p));
      if(!p.plugin) {
        try {
          var d = c.ctor || h.getObject(c.name) || v(c.name);
          d && (p.plugin = new d(c))
        }catch(e) {
          throw Error(this.id + ": cannot find plugin [" + c.name + "]");
        }
      }
      if(!p.plugin) {
        throw Error(this.id + ": cannot find plugin [" + c.name + "]");
      }
      a = p.plugin
    }
    1 < arguments.length ? this._plugins[b] = a : this._plugins.push(a);
    a.setEditor(this);
    h.isFunction(a.setToolbar) && a.setToolbar(this.toolbar)
  }, resize:function(a) {
    a && D.prototype.resize.apply(this, arguments)
  }, layout:function() {
    var a = this._contentBox.h - (this.getHeaderHeight() + this.getFooterHeight() + t.getPadBorderExtents(this.iframe.parentNode).h + t.getMarginExtents(this.iframe.parentNode).h);
    this.editingArea.style.height = a + "px";
    this.iframe && (this.iframe.style.height = "100%");
    this._layoutMode = !0
  }, _onIEMouseDown:function(a) {
    var b, c = this.document.body, d = c.clientWidth, e = c.clientHeight, g = c.clientLeft, f = c.offsetWidth, h = c.offsetHeight, l = c.offsetLeft;
    /^rtl$/i.test(c.dir || "") ? d < f && (a.x > d && a.x < f) && (b = !0) : a.x < g && a.x > l && (b = !0);
    b || e < h && (a.y > e && a.y < h) && (b = !0);
    b || (delete this._cursorToStart, delete this._savedSelection, "BODY" == a.target.tagName && this.defer("placeCursorAtEnd"), this.inherited(arguments))
  }, onBeforeActivate:function() {
    this._restoreSelection()
  }, onBeforeDeactivate:function(a) {
    this.customUndo && this.endEditing(!0);
    "BODY" != a.target.tagName && this._saveSelection()
  }, customUndo:!0, editActionInterval:3, beginEditing:function(a) {
    this._inEditing || (this._inEditing = !0, this._beginEditing(a));
    0 < this.editActionInterval && (this._editTimer && this._editTimer.remove(), this._editTimer = this.defer("endEditing", this._editInterval))
  }, _steps:[], _undoedSteps:[], execCommand:function(a) {
    if(this.customUndo && ("undo" == a || "redo" == a)) {
      return this[a]()
    }
    this.customUndo && (this.endEditing(), this._beginEditing());
    var b = this.inherited(arguments);
    this.customUndo && this._endEditing();
    return b
  }, _pasteImpl:function() {
    return this._clipboardCommand("paste")
  }, _cutImpl:function() {
    return this._clipboardCommand("cut")
  }, _copyImpl:function() {
    return this._clipboardCommand("copy")
  }, _clipboardCommand:function(a) {
    var b;
    try {
      if(b = this.document.execCommand(a, !1, null), g("webkit") && !b) {
        throw{code:1011};
      }
    }catch(c) {
      if(1011 == c.code || 9 == c.code && g("opera")) {
        b = z.substitute, alert(b(this.commands.systemShortcut, [this.commands[a], b(this.commands[g("mac") ? "appleKey" : "ctrlKey"], [{cut:"X", copy:"C", paste:"V"}[a]])]))
      }
      b = !1
    }
    return b
  }, queryCommandEnabled:function(a) {
    return this.customUndo && ("undo" == a || "redo" == a) ? "undo" == a ? 1 < this._steps.length : 0 < this._undoedSteps.length : this.inherited(arguments)
  }, _moveToBookmark:function(a) {
    var b = a.mark, c = a.mark;
    a = a.isCollapsed;
    var d, e, k;
    if(c) {
      if(9 > g("ie") || 9 === g("ie") && g("quirks")) {
        if(h.isArray(c)) {
          b = [], l.forEach(c, function(a) {
            b.push(f.getNode(a, this.editNode))
          }, this), this.selection.moveToBookmark({mark:b, isCollapsed:a})
        }else {
          if(c.startContainer && c.endContainer && (k = f.getSelection(this.window)) && k.removeAllRanges) {
            k.removeAllRanges(), a = f.create(this.window), d = f.getNode(c.startContainer, this.editNode), e = f.getNode(c.endContainer, this.editNode), d && e && (a.setStart(d, c.startOffset), a.setEnd(e, c.endOffset), k.addRange(a))
          }
        }
      }else {
        if((k = f.getSelection(this.window)) && k.removeAllRanges) {
          k.removeAllRanges(), a = f.create(this.window), d = f.getNode(c.startContainer, this.editNode), e = f.getNode(c.endContainer, this.editNode), d && e && (a.setStart(d, c.startOffset), a.setEnd(e, c.endOffset), k.addRange(a))
        }
      }
    }
  }, _changeToStep:function(a, b) {
    this.setValue(b.text);
    var c = b.bookmark;
    c && this._moveToBookmark(c)
  }, undo:function() {
    var a = !1;
    if(!this._undoRedoActive) {
      this._undoRedoActive = !0;
      this.endEditing(!0);
      var b = this._steps.pop();
      b && 0 < this._steps.length && (this.focus(), this._changeToStep(b, this._steps[this._steps.length - 1]), this._undoedSteps.push(b), this.onDisplayChanged(), delete this._undoRedoActive, a = !0);
      delete this._undoRedoActive
    }
    return a
  }, redo:function() {
    var a = !1;
    if(!this._undoRedoActive) {
      this._undoRedoActive = !0;
      this.endEditing(!0);
      var b = this._undoedSteps.pop();
      b && 0 < this._steps.length && (this.focus(), this._changeToStep(this._steps[this._steps.length - 1], b), this._steps.push(b), this.onDisplayChanged(), a = !0);
      delete this._undoRedoActive
    }
    return a
  }, endEditing:function(a) {
    this._editTimer && (this._editTimer = this._editTimer.remove());
    this._inEditing && (this._endEditing(a), this._inEditing = !1)
  }, _getBookmark:function() {
    var a = this.selection.getBookmark(), b = [];
    if(a && a.mark) {
      var c = a.mark;
      if(9 > g("ie") || 9 === g("ie") && g("quirks")) {
        var d = f.getSelection(this.window);
        if(h.isArray(c)) {
          l.forEach(a.mark, function(a) {
            b.push(f.getIndex(a, this.editNode).o)
          }, this), a.mark = b
        }else {
          if(d) {
            var e;
            d.rangeCount && (e = d.getRangeAt(0));
            a.mark = e ? e.cloneRange() : this.selection.getBookmark()
          }
        }
      }
      try {
        a.mark && a.mark.startContainer && (b = f.getIndex(a.mark.startContainer, this.editNode).o, a.mark = {startContainer:b, startOffset:a.mark.startOffset, endContainer:a.mark.endContainer === a.mark.startContainer ? b : f.getIndex(a.mark.endContainer, this.editNode).o, endOffset:a.mark.endOffset})
      }catch(k) {
        a.mark = null
      }
    }
    return a
  }, _beginEditing:function() {
    0 === this._steps.length && this._steps.push({text:u.getChildrenHtml(this.editNode), bookmark:this._getBookmark()})
  }, _endEditing:function() {
    var a = u.getChildrenHtml(this.editNode);
    this._undoedSteps = [];
    this._steps.push({text:a, bookmark:this._getBookmark()})
  }, onKeyDown:function(a) {
    !g("ie") && (!this.iframe && a.keyCode == d.TAB && !this.tabIndent) && this._saveSelection();
    if(this.customUndo) {
      var b = a.keyCode;
      if(a.ctrlKey && !a.shiftKey && !a.altKey) {
        if(90 == b || 122 == b) {
          a.stopPropagation();
          a.preventDefault();
          this.undo();
          return
        }
        if(89 == b || 121 == b) {
          a.stopPropagation();
          a.preventDefault();
          this.redo();
          return
        }
      }
      this.inherited(arguments);
      switch(b) {
        case d.ENTER:
        ;
        case d.BACKSPACE:
        ;
        case d.DELETE:
          this.beginEditing();
          break;
        case 88:
        ;
        case 86:
          if(a.ctrlKey && !a.altKey && !a.metaKey) {
            this.endEditing();
            88 == a.keyCode ? this.beginEditing("cut") : this.beginEditing("paste");
            this.defer("endEditing", 1);
            break
          }
        ;
        default:
          if(!a.ctrlKey && !a.altKey && !a.metaKey && (a.keyCode < d.F1 || a.keyCode > d.F15)) {
            this.beginEditing();
            break
          }
        ;
        case d.ALT:
          this.endEditing();
          break;
        case d.UP_ARROW:
        ;
        case d.DOWN_ARROW:
        ;
        case d.LEFT_ARROW:
        ;
        case d.RIGHT_ARROW:
        ;
        case d.HOME:
        ;
        case d.END:
        ;
        case d.PAGE_UP:
        ;
        case d.PAGE_DOWN:
          this.endEditing(!0);
        case d.CTRL:
        ;
        case d.SHIFT:
        ;
        case d.TAB:
      }
    }else {
      this.inherited(arguments)
    }
  }, _onBlur:function() {
    this.inherited(arguments);
    this.endEditing(!0)
  }, _saveSelection:function() {
    try {
      this._savedSelection = this._getBookmark()
    }catch(a) {
    }
  }, _restoreSelection:function() {
    this._savedSelection && (delete this._cursorToStart, this.selection.isCollapsed() && this._moveToBookmark(this._savedSelection), delete this._savedSelection)
  }, onClick:function() {
    this.endEditing(!0);
    this.inherited(arguments)
  }, replaceValue:function(a) {
    this.customUndo ? this.isClosed ? this.setValue(a) : (this.beginEditing(), a || (a = "\x26#160;"), this.setValue(a), this.endEditing()) : this.inherited(arguments)
  }, _setDisabledAttr:function(a) {
    this.setValueDeferred.then(h.hitch(this, function() {
      !this.disabled && a || !this._buttonEnabledPlugins && a ? l.forEach(this._plugins, function(a) {
        a.set("disabled", !0)
      }) : this.disabled && !a && l.forEach(this._plugins, function(a) {
        a.set("disabled", !1)
      })
    }));
    this.inherited(arguments)
  }, _setStateClass:function() {
    try {
      this.inherited(arguments), this.document && this.document.body && r.set(this.document.body, "color", r.get(this.iframe, "color"))
    }catch(a) {
    }
  }});
  h.mixin(m.registry, {undo:e, redo:e, cut:e, copy:e, paste:e, insertOrderedList:e, insertUnorderedList:e, indent:e, outdent:e, justifyCenter:e, justifyFull:e, justifyLeft:e, justifyRight:e, "delete":e, selectAll:e, removeFormat:e, unlink:e, insertHorizontalRule:e, bold:n, italic:n, underline:n, strikethrough:n, subscript:n, superscript:n, "|":function() {
    return new m({setEditor:function(a) {
      this.editor = a;
      this.button = new C({ownerDocument:a.ownerDocument})
    }})
  }});
  return q
});

//# sourceMappingURL=Editor.js.map