define(
    [ 'dijit/layout/BorderContainer'],
    function(BorderContainer) {
        var DojoBorderContainer = {
            data: function() {
                return {};
            },
            props: [ 'persist' ],
            template: '<div><slot/></div>',
            mounted: function() {
                this.widget = new BorderContainer({
                    persist: this.persist
                }, this.$el).startup();
            }
        };

        return DojoBorderContainer;
    });
