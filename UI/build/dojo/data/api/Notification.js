//>>built
define("dojo/data/api/Notification", ["../../_base/declare", "./Read"], function(a, b) {
  return a("dojo.data.api.Notification", b, {getFeatures:function() {
    return{"dojo.data.api.Read":!0, "dojo.data.api.Notification":!0}
  }, onSet:function(c, a, b, d) {
    throw Error("Unimplemented API: dojo.data.api.Notification.onSet");
  }, onNew:function(a, b) {
    throw Error("Unimplemented API: dojo.data.api.Notification.onNew");
  }, onDelete:function(a) {
    throw Error("Unimplemented API: dojo.data.api.Notification.onDelete");
  }})
});

//# sourceMappingURL=Notification.js.map