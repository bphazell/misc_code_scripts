require(['jquery-noconflict'], function(jQuery) {
    
  //Ensure MooTools is where it must be
  Window.implement('$', function(el, nc){
    return document.id(el, nc, this.document);
  });
  var $ = window.jQuery;
  // Use `$` in here.
  
  $('.target_parent_urls-output-js').each(function(){
    var urls = $(this).text().trim();
    
    if (urls != "No data available") 
    { 
      var urlbtns = ''
          urls = urls.split(",")
            urls.each(function(el, i){
              urlbtns += '<a target="_blank" class="btn et-click-me" href="http://www.'+el.trim()+'"><i class="icon-search"></i> Parent Website '+(i+1)+'</a><br><br>'
                });
      
      console.log(urlbtns);
      
      $(this).closest('.url-list-wrapper-js').find('.link-list-js').html(urlbtns);
    }
  });
  
  $(document).ready(function(){
    setTimeout(function(){
      $('.cml-table-row-title').each(function(){
        var h = $(this).parent('.cml-table-row').height();
        $(this).height(h);
      });  
    }, 200);
  });
  
  $(".et-click-me").click(function(){
    $(this).removeClass('et-click-me').addClass('et-clicked');
    // console.log(a);
  }) 
   
});