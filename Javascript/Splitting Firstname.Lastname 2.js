// First Name / Last Name JS from Alex
if(utag.data.customer_email) {
    // xPath lookup of "Welcome, your name!" from account page
    var mystring = jQuery( "p.welcome-msg" ).text().trim();
    // if string is defined (catch to see if it can be found on page)
    if(mystring) {
        // Overall length of the string
        var stringlength = mystring.length;
        // Space after first name
        var firstSpaceBetweenNames = mystring.indexOf(" ",9);
        // Space before last name
        var lastSpaceBetweenNames = mystring.lastIndexOf(" ");
        // Set full name
        utag.data.customer_full_name = mystring.slice(9, stringlength-1);
        // Set first name
        utag.data.customer_first_name = mystring.slice(9, firstSpaceBetweenNames);
        // set last name
        utag.data.customer_last_name = mystring.slice(lastSpaceBetweenNames+1, stringlength-1);
      // if string can not be found, fall back to checking the email    
    } 
}