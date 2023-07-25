
// Load Jquery

if (typeof jQuery.ui != 'undefined') {
    // do nothing
} else if (document.title == "Shopping Cart") {
    var script = document.createElement('script');
    script.src = "https://code.jquery.com/ui/1.12.1/jquery-ui.min.js";
    script.integrity = "sha256-VazP97ZCwtekAsvgPBSUwPFKdrwD3unUfSGVYrahUqU=";
    script.crossOrigin = "anonymous";
    document.getElementsByTagName('head')[0].appendChild(script);
    console.log("jQuery UI loaded");
} else {
    // do nothing
}

// Load Bootstrap

var bootstrapcss = document.createElement('link');
bootstrapcss.rel = "stylesheet";
bootstrapcss.href = "https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css";
bootstrapcss.integrity = "sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T";
bootstrapcss.crossOrigin = "anonymous";
document.getElementsByTagName('head')[0].appendChild(bootstrapcss);

var bootstrapjs = document.createElement('script');
bootstrapjs.src = "https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js";
bootstrapjs.integrity = "sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl";
bootstrapjs.crossOrigin = "anonymous";
document.getElementsByTagName('head')[0].appendChild(bootstrapjs);

// calculate cart quanity


var i = 0;
var q = 0;

while (i < b.product_quantity.length) {
    q += Number(b.product_quantity[i]);
    i++;
}

b.cart_quantity = q;


// Calculate cart total and cart_offer

var i = 0;
var q = 0;

while (i < b.product_quantity.length) {
    q += (Number(b.product_quantity[i]) * Number(b.product_price[i]));
    i++;
}

b.cart_total = q;

if (q >= 500 && q < 1000) {
    b.cart_offer = 10;
} else if (q >= 1000 && q < 1500) {
    b.cart_offer = 15;
} else if (q >= 1500) {
    b.cart_offer = 20;
} else {
    b.cart_offer = 0;
}

// privacy banner

<div id="privacyBanner" style="display: none;" class="alert alert-primary alert-dismissible fade show" role="alert">
    We use your data! Click to update your <a href="#" class="alert-link" onClick="utag.gdpr.showConsentPreferences()">Consent Preferences</a>.
    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
        <span aria-hidden="true">&times;</span>
    </button>
</div>

// discount banner
<div id="secretOffer" style="display: none;" class="alert alert-primary" role="alert">A Secret Discount Just For You! Enter <strong>PARTY10</strong> to get 10% off your order.</div>

