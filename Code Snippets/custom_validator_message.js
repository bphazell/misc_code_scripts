var validator_options = CMLFormValidator.getValidator('url').options

validator_options.errorMessage = function(){ return ('CUSTOM ERROR MESSSAGE HERE.'); }

CMLFormValidator.addAllThese([ ['url', validator_options] ]);