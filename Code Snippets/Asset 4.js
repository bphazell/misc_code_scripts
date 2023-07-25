var requiredTotal = 100;
var checkMath = {};

require(
  ['jquery-noconflict','bootstrap-modal','bootstrap-tooltip','bootstrap-popover','jquery-cookie'], 
  function(_, modal, jQuery) {
  //Ensure MooTools is where it must be
  Window.implement('$', function(el, nc){
    return document.id(el, nc, this.document);
  }); 
  
  var $ = window.jQuery;

  checkMath = function(element) {
    var firstVal = parseInt($(element).closest(".cml").find("input.keyword_1").val());
    var secondVal = parseInt($(element).closest(".cml").find("input.keyword_2").val());

    return (firstVal + secondVal == requiredTotal)
  }

});

if(!_cf_cml.digging_gold) {
  CMLFormValidator.addAllThese([
    ['yext_no_international_url', {
      errorMessage: function(){
        return ('Values must equal ' + requiredTotal);
      },
      validate: function(element, props){
        return checkMath(element);
      }
    }]
  ]);
} else {
  CMLFormValidator.addAllThese([
   ['yext_no_international_url', {
      validate: function(element,props){
         return true
      }
   }]           
  ]);
}