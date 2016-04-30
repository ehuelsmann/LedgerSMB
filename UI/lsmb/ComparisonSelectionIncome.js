define("lsmb/ComparisonSelectionIncome",
       ["dijit/layout/ContentPane",
        "dojo/_base/declare",
        "dojo/dom",
        "dojo/topic",
        "dojo/dom-style"
        ],
        function(ContentPane, declare, dom, topic, domStyle) {
            return declare('lsmb/ComparisonSelectionIncome', ContentPane, {
                topic: "",
                type: "",
                comparisons: 0,
                show: function(c) {
                    if ( !dom.byId(c)) return;
                    if ( c ) domStyle.set(c,'display','block');
                },
                hide: function(c) {
                    if ( !dom.byId(c)) return;
                    if ( c ) domStyle.set(c,'display','none');
                },
                toggles: function(ids,l) {
                    for ( i = 1 ; i <= 9 ; i++ ) {
                        var _cdDom = dom.byId(ids + "_" + i);
                        (( i <= this.comparisons && l) ? this.show : this.hide)(_cdDom);
                    }
                },
                update: function(targetValue) {
                    var _cDom = dom.byId(this.id);
                    if ( targetValue == 'by_dates'   ) {
                        this.type = targetValue;
                        this.hide("date_period_id");
                        this.show("comparison_dates_to");
                        this.toggles("comparison_dates",1);
                        this.toggles("comparison_dates_to",1);
                    } else if ( targetValue == 'by_periods' ) {
                        this.type = targetValue;
                        this.show("date_period_id");
                        this.hide("comparison_dates_to");
                        this.toggles("comparison_dates",0);
                        this.toggles("comparison_dates_to",0);
                    } else if ( targetValue >= 0 && targetValue <= 9 ) {
                        this.comparisons = targetValue;
                        this.toggles("comparison_dates",this.type=="by_dates");
                        this.toggles("comparison_dates_to",this.type=="by_dates");
                    }
                },
                buildRendering: function() {    // Instead of postCreate to make sure that we listen before publishers
                    var self = this;
                    this.inherited(arguments);

                    this.own(
                        topic.subscribe(self.topic,function(targetValue) {
                            self.update(targetValue);
                        })
                    );
                },
                postCreate: function () {
                    this.update(0);
                    this.update('by_periods');
                }
            });
       });
