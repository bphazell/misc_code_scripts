require(['jquery-noconflict'], function (_, modal, jQuery) {

//Ensure MooTools is where it must be
  Window.implement('$', function(el, nc){
    return document.id(el, nc, this.document);
  });
  

var $ = window.jQuery;


$(document).ready(function() {
  console.log("I load");
    $(".rp").click(function() {
        var rot = (parseInt($(this).attr("data-rotate"))+90)%360;
        $(this).attr("data-rotate",rot);
        $(this).css("-webkit-transform", "rotate("+rot+"deg)");
        $(this).css("-moz-transform", "rotate("+rot+"deg)");
    });
});