define(['dojo/_base/declare',
        'dojo/on',
        'dojo/topic',
        'lsmb/PublishRadioButton'],
       function(declare, on, topic, RadioButton) {
           return declare('lsmb/ComparisonSelection', [RadioButton], {
               topic: "",
               showValues: null,
               hideValues: null,
               show: function() {
                   style.set(this.domNode,'display','block');
                   alert('show called');
               },
               hide: function() {
                   style.set(this.domNode,'display','none');
                   alert('hide called');
               },
               update: function(targetValue) {
                   if (       this.showValues && this.showValues.indexOf(targetValue) != -1) { this.show(); }
                   else if (  this.hideValues && this.hideValues.indexOf(targetValue) != -1) { this.hide(); }
                   else if ( !this.showValues)                                               { this.show(); }
                   else if ( !this.hideValues)                                               { this.hide(); }
                                                                                     // otherwise, do nothing
                   alert('update called');
               },
               postCreate: function() {
                   var self = this;
                   this.inherited(arguments);

                   this.own(
                       topic.subscribe(self.topic,function(targetValue) {
                           self.update(targetValue);
                       })
                   );
                   alert('postCreate called');
               }
           });
       });
