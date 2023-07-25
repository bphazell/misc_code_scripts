// another mens/womens category


var currentWomensTotal = 0; 
var currentMensTotal = 0;

for (i=0; i< b.product_sku.length;i++){     // loop through product SKUs from current order
    if (b.product_sku[i].startsWith("w")){  // product is womenswear
        currentWomensTotal += b.product_price[i] * b.product_quantity[i];
    }
    if (b.product_sku[i].startsWith("m")){  // product is menswear
        currentMensTotal += b.product_price[i] * b.product_quantity[i];
    }
}

b.womenswear_total = currentWomensTotal;
b.menswear_total = currentMensTotal;

console.log(b.menswear_total);
console.log(b.womenswear_total);


// Subtotal mens/women's categories

var order_subtotal_men_category = 0;
var order_subtotal_women_category = 0;

for (var index = 0; index < b.product_sku.length; index++) {
    var sku = b.product_sku[index];
    
    // If SKU first letter is m then is a product from men categories
    if (sku !== undefined && sku[0] == 'm') {
        order_subtotal_men_category += parseFloat(b.product_price[index]) * parseFloat(b.product_quantity[index]);
    }
    
    // If SKU first letter is w then is a product from women categories
    if (sku !== undefined && sku[0] == 'w') {
        order_subtotal_women_category += parseFloat(b.product_price[index]) * parseFloat(b.product_quantity[index]);
    }
}

// Add the Javascript Code extension to set total_menswear and total_womenswear:

b.product_quantity = b.product_quantity || [];
b.product_price = b.product_price || [];
b.product_category_m_w = b.product_category_m_w || [];

if (b.product_quantity.length === b.product_price.length &&
    b.product_quantity.length === b.product_category_m_w.length &&
    b.product_price.length === b.product_category_m_w.length){

    b.total_menswear = 0;
    b.total_womenswear = 0;
    for (var i=0; i<b.product_price.length; i++){
        if (b.product_category_m_w[i].toLowerCase() === "menswear")
            b.total_menswear += b.product_quantity[i] * b.product_price[i];
        else if (b.product_category_m_w[i].toLowerCase() === "womenswear")    
            b.total_womenswear += b.product_quantity[i] * b.product_price[i];
    }
}

// Mens/Womens Categories

var c = utag_data.product_category;
var q = utag_data.product_quantity;
var p = utag_data.product_unit_price;
var menswearSpend = 0;
var womenswearSpend = 0;

for(i=0;i<c.length;i++){
  if(c[i]=='Menswear'){
    menswearSpend = menswearSpend + parseFloat(q[i])*parseFloat(p[i]);
  }
}

for(i=0;i<c.length;i++){
  if(c[i]=='Womenswear'){
    womenswearSpend = womenswearSpend + parseFloat(q[i])*parseFloat(p[i]);
  }
}
// window.alert("Womens: " + womenswearSpend + "Mens: " + menswearSpend);

// Category JS from client: 

(function()  { 
    var total=0; 
    if(utag.data.order_total>0) { 
        for(var i=0;i<utag.data.product_sku.length;i++) {     
            var sku=utag.data.product_sku[i];     
            
        if(sku && (sku.startsWith("m") || sku.startsWith("w")))     {         
                total+=utag.data.product_quantity[i]*utag.data.product_price[i];     } 
    } 
} 
    return total; })();

