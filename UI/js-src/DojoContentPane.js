define(
    [ 'dijit/layout/ContentPane'],
    function(ContentPane) {
        var DojoContentPane = {
            data: function() {
                return {};
            },
            props: [ 'region', 'splitter', 'min-size', 'id' ],
            template: '<div><slot/></div>',
            mounted: function() {
                this.widget = new ContentPane({
                    id: this.id,
                    region: this.region,
                    splitter: this.splitter,
                    minSize: this['min-size'],
                }, this.$el).startup();
            }
        };

        return DojoContentPane;
    });
