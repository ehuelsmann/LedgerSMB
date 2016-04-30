//>>built
define("lsmb/accounts/AccountStore", ["dojo/store/Memory", "dojo/store/Observable", "dojo/request", "dojo/_base/array", "dojo/Evented"], function(c, d, e, f, g) {
  var a = new d(new c({idProperty:"text", emitter:new g}));
  e.get("journal.pl?action\x3dchart_json", {handleAs:"json"}).then(function(h) {
    f.forEach(h, function(b) {
      b.text = b.accno + "--" + b.description;
      a.put(b)
    });
    a.emitter.emit("accountstore_loadcomplete", {bubbles:!0, cancelable:!1})
  }, function(a) {
  });
  return a
});

//# sourceMappingURL=AccountStore.js.map