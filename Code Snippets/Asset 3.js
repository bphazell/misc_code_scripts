if(_cf_cml.digging_gold) { var ElegantHack = function() { 
	var data = $('form').retrieve('gold')[0].options.unitData; 
	$('.checkboxes').each(function(cb) {  
    cb.getElements('input').each(function(input) {
    	if(data[input.get('class').split(" ")[0]].some(function(c) {
    		return input.value == c })) { 
    			input.checked = true; input.fireEvent('change')
    		}
    	})
    })
}

if(_cf_cml.digging_gold) { 
	elegantHack.delay(100) 
}