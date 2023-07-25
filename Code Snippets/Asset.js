// This snippet must be in all your jobs with JS

require(['jquery-noconflict'], function(jQuery) {
  
  //Ensure MooTools is where it must be
  Window.implement('$', function(el, nc){
    return document.id(el, nc, this.document);
  });
  var $ = window.jQuery;
 
  // Use `$` in here.
  setTimeout({
  
  // ENTER YOUR JQUERY HERE
  
  
  }, 100);  // this delays your code running until after CF iframe loads, in milliseconds
  
});