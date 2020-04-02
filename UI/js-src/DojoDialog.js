define(
    [ 'dijit/Dialog' ],
    function(Dialog) {
        var DojoDialog = {
            data: function() {
                return {
                };
            },
            props: [ 'id', 'title' ],
            template: '<div></div>',
            mounted: function() {
                this.widget = new Dialog({
                    id: this.id,
                    title: this.title
                }, this.$el).startup();
            }
        };

        return DojoDialog;
    });
