Vue.component('dojo-button', function(resolve) {
    require(
        [ 'dijit/form/Button',
          'dojo/dom-construct' ],
        function (Button, domConstruct) {
            resolve({
                data: function () {
                    return {
                        data: {
                            value: '',
                            disabled: false,
                            name: null,
                            type: null,
                            widget: null
                        }
                    };
                },
                template: '<span></span>',
                props: [ 'value', 'disabled', 'name', 'type' ],
                mounted: function() {
                    const self = this;
                    this.widget = new Button({
                        label: this.$slots.default[0].text,
                        onClick: (evt) => {
                            self.$emit('click');
                        }
                    });
                    domConstruct.place(this.widget.domNode, this.$el);
                }
            });
        });
});
