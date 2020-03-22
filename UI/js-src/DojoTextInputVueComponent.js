Vue.component('dojo-text-input', function(resolve) {
    require(
        [ 'dijit/form/TextBox',
          'dojo/dom-construct' ],
        function (TextBox, domConstruct) {
            resolve({
                data: function () {
                    return {
                        data: {
                            value: '',
                            disabled: false,
                            name: null,
                            type: null,
                            id: undefined,
                            widget: null
                        }
                    };
                },
                template: '<span></span>',
                props: [ 'value', 'disabled', 'name', 'type', 'title', 'id' ],
                created: function() {
                    const self = this;
                    this.widget = new TextBox({
                        value: this.value,
                        title: this.title,
                        type: this.type,
                        intermediateChanges: true,
                        onChange: (evt) => {
                            self.$emit('input', self.widget.value);
                        }
                    });
                    if (this.id) {
                        this.widget.domNode.setAttribute('id', this.id);
                    }
                    this.widget.startup();
                },
                mounted: function() {
                    const self = this;
                    domConstruct.place(this.widget.domNode, this.$el);
                },
                beforeDestroy: function() {
                    this.widget.destroyRecursive(false); // don't preserve DOM
                }
            });
        });
});
