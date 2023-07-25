// Splitting Firstname/Lastname JS : 


var t = jQuery(".welcome-msg")
utag.data.customer_last_name = "";
utag.data.customer_first_name = "";
if (t) {
   var r = t.html().split(",")[1];
   var r = r.replace("!", "").trim();
   var z = r.split(" ");
   utag.data.customer_last_name = z[z.length - 1];
   utag.data.customer_first_name = "";
   for(var i = 0; i < z.length - 1; i++)
       utag.data.customer_first_name += z[i] + " ";
   utag.data.customer_first_name = utag.data.customer_first_name.trim();
}