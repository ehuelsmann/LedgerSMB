//>>built
define("lsmb/TabularForm", "lsmb/layout/TableContainer dojo/dom dojo/dom-class dijit/registry dijit/layout/ContentPane dojo/query dojo/window dojo/_base/declare dijit/form/TextBox".split(" "), function(g, p, h, k, l, e, m, n, q) {
  return n("lsmb/TabularForm", [g], {vertsize:"mobile", vertlabelsize:"mobile", maxCols:1, initOrient:"horiz", constructor:function(a, b) {
    if(void 0 !== b) {
      var d = " " + b.className + " ", c = d.match(/ col-\d+ /);
      c && (this.cols = c[0].replace(/ col-(\d+) /, "$1"));
      if(c = d.match("/ virtsize-w+ /")) {
        this.vertsize = c[0].replace(/ virtsize-(\w+) /, "$1")
      }
      if(c = d.match("/ virtlabel-w+ /")) {
        this.vertlabelsize = c[0].replace(/ virtlabel-(\w+) /, "$1")
      }
    }
    var f = this;
    e("*", f.domNode).forEach(function(a) {
      f.TFRenderElement(a)
    });
    this.maxCols = this.cols;
    this.initOrient = this.orientation
  }, TFRenderElement:function(a) {
    k.byId(a.id) || h.contains(a, "input-row") && TFRenderRow(a)
  }, TFRenderRow:function(a) {
    var b = 0;
    e("*", a).forEach(function(a) {
      TFRenderElement(a);
      ++b
    });
    for(i = b %= this.cols;i < this.cols;++i) {
      a = new l({content:"\x26nbsp;"}), this.addChild(a)
    }
  }, resize:function() {
    var a = m.getBox(), b = this.orientation;
    switch(this.vertlabelsize) {
      case "mobile":
        if(480 <= a.w) {
          this.cols = this.maxCols;
          this.orientation = this.initOrient;
          break
        }
      ;
      case "small":
        if(768 <= a.w) {
          this.cols = this.maxCols;
          this.orientation = this.initOrient;
          break
        }
      ;
      case "med":
        if(992 <= a.w) {
          this.cols = this.maxCols;
          this.orientation = this.initOrient;
          break
        }
      ;
      default:
        this.cols = 1, this.orientation = "vert"
    }
    switch(this.vertsize) {
      case "mobile":
        if(480 <= a.w) {
          break
        }
      ;
      case "small":
        if(768 <= a.w) {
          break
        }
      ;
      case "med":
        if(992 <= a.w) {
          break
        }
      ;
      default:
        this.cols = 1
    }
    this.orientation !== b && this.startup();
    return this.inherited(arguments)
  }})
});

//# sourceMappingURL=TabularForm.js.map