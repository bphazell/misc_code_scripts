$(document).ready(function(){
   //perform function when mouse enters div
$('.btn').mouseenter(function(){
	//adds buton large class, '.css' changes the bacground color
	//'.css' can be used to change/add any css element
 $(this).addClass('btn-large').css('background', '#FFFF00')
 //animate moves the object to the margin specified
   .animate({marginTop: "-20px",
             marginLeft:"20px"},
            "slow");
   //Change a css class from 'hide' to 'show'
      $('.comment').show();
      }); 