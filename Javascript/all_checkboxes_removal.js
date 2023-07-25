require(['jquery-noconflict'], function(jQuery) {
  Window.implement('$', function(el, nc){
    return document.id(el, nc, this.document);
  });
  var $ = window.jQuery;
  

  //console.log(checkboxes);
  
  //checkboxes.on('click', function() {
  //checkboxes.each( function() {
  //  var checked = $(this).attr("checked");
  //  console.log(checked);
  //});
  //});
  
  // Call funciton when document loads
  
  
  // Define Funciton
  function checkbox_counter(unit_id){
    // Define the class you are using in your checkboxes here:
      var checkboxes = $('.check_option'+unit_id);
     // Define the class you are using in your dummy checkbox here:
      var hidden_check = $('.dummy_check'+unit_id);


        var count = 0;
        checkboxes.each( function() {
          var checked = $(this).attr("checked");
          if( checked == "checked") {
            count++;
          };
        });
        
        var check_length = checkboxes.size();
        if (count == check_length){
          hidden_check.attr('checked','checked');
        };

  }; 
// function for iterating over all units
  function checkboxes_for_all_units(){
    $('.cml.jsawesome').each( function(){
      //find unit id for each unit in js awesome and removes the first letter 'u'
      unit_id = $(this).attr('id').substring(1);
      checkbox_counter(unit_id);
    });

  };

  $('form.mobmerge .submit').on('click', function(event){ 
      checkboxes_for_all_units();
  });


  $("form.mobmerge").submit( function(event){
      checkboxes_for_all_units();
  }); 



  
});