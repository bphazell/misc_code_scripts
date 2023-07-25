
require 'mail'

#Set up email settings
#you need enable 'allow less secure apps to access your account' in gmail settings 
options = { :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => 'crowdflower',
  :user_name            => 'bphazell',
  :password             => 'Jaydice16',
  :authentication       => 'plain',
  :enable_starttls_auto => true  }
  Mail.defaults do
  delivery_method :smtp, options
end

mail = Mail.deliver do
  from    'bhazell@crowdflower.com'
  to      "bhazell@crowdflower.com"
  subject "This is a test email"
  body    "body"
  end


