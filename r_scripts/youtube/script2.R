setwd("~/Dropbox (CrowdFlower)/YouTubeDocs/PS-176/Final_Package/")
options(stringsAsFactors=F)

cat = read.csv("cat_and_recat_for_check.csv")
names(cat)[14] = "old_subcat_cf"

df = cat


df$new_subcat_cf = ""

for(i in 1:nrow(df)){
  
  if(df$subcat_cf[i] == "Visual_Art__amp__Design"){
    df$new_subcat_cf[i] ="Visual Art & Design"}
  
  if(df$subcat_cf[i] == "Beauty_Pageants"){
    df$new_subcat_cf[i] ="Beauty Pageants"}
  
  if(df$subcat_cf[i] == "Body_Art__amp__Body_Care"){
    df$new_subcat_cf[i] ="Body Art & Body Care"}
  
  if(df$subcat_cf[i] == "Fashion__amp__Style__Clothing__amp__Accessories_"){
    df$new_subcat_cf[i] ="Fashion & Style (Clothing & Accessories)"}
  
  if(df$subcat_cf[i] == "Haircare_and_Hair_Styling"){
    df$new_subcat_cf[i] ="Haircare and Hair Styling"}
  
  if(df$subcat_cf[i] == "Makeup_and_Skincare"){
    df$new_subcat_cf[i] ="Makeup and Skincare"}
  
  if(df$subcat_cf[i] == "Runway_Fashion"){
    df$new_subcat_cf[i] ="Runway Fashion"}
  
  
  if(df$subcat_cf[i] == "Music_Parody"){
    df$new_subcat_cf[i] ="Music  Parody"}
  
  if(df$subcat_cf[i] == "Parody_"){
    df$new_subcat_cf[i] ="Parody "}
  
  if(df$subcat_cf[i] == "Stand_Up"){
    df$new_subcat_cf[i] ="Stand-Up"}
  
  if(df$subcat_cf[i] == "Commentary__amp__News_Analysis_"){
    df$new_subcat_cf[i] ="Commentary & News Analysis "}
  
  if(df$subcat_cf[i] == "General_Interest___Headline_News"){
    df$new_subcat_cf[i] ="General Interest / Headline News"}
  
  if(df$subcat_cf[i] == "Local_News"){
    df$new_subcat_cf[i] ="Local News"}
  
  if(df$subcat_cf[i] == "Engineering_"){
    df$new_subcat_cf[i] ="Engineering "}
  
  if(df$subcat_cf[i] == "English__amp__Literature"){
    df$new_subcat_cf[i] ="English & Literature"}
  
  
  if(df$subcat_cf[i] == "Language_Resources"){
    df$new_subcat_cf[i] ="Language Resources"}
  
  
  if(df$subcat_cf[i] == "Life_Long_Learning"){
    df$new_subcat_cf[i] ="Life-Long Learning"}
  
  if(df$subcat_cf[i] == "Medicine__amp__Health"){
    df$new_subcat_cf[i] ="Medicine & Health"}
  
  if(df$subcat_cf[i] == "Social_Science"){
    df$new_subcat_cf[i] ="Social Science"}
  
  if(df$subcat_cf[i] == "Cooking__amp__Recipes"){
    df$new_subcat_cf[i] ="Cooking & Recipes"}
  
  
  if(df$subcat_cf[i] == "Game_Show"){
    df$new_subcat_cf[i] ="Game Show"}
  
  if(df$subcat_cf[i] == "Card_games__amp__gambling"){
    df$new_subcat_cf[i] ="Card games & gambling"}
  
  if(df$subcat_cf[i] == "Casual__amp__Board_games"){
    df$new_subcat_cf[i] ="Casual & Board games"}
  
  if(df$subcat_cf[i] == "Other_"){
    df$new_subcat_cf[i] ="Other  "}
  
  if(df$subcat_cf[i] == "Video_Games___GamePlay__amp__eSports"){
    df$new_subcat_cf[i] ="Video Games - GamePlay & eSports"}
  
  if(df$subcat_cf[i] == "Video_Games___Game_Powered"){
    df$new_subcat_cf[i] ="Video Games - Game-Powered"}
  
  if(df$subcat_cf[i] == "Video_Games___other"){
    df$new_subcat_cf[i] ="Video Games - other"}
  
  if(df$subcat_cf[i] == "Video_Games___Tutorials__Walkthroughs__Tips_and_Tricks"){
    df$new_subcat_cf[i] ="Video Games -  Tutorials, Walkthroughs, Tips and Tricks"}
  
  if(df$subcat_cf[i] == "Video_Games___Trailers__Demos__amp__Cinematics__a_k_a_Publisher_Content_"){
    df$new_subcat_cf[i] ="Video Games - Trailers, Demos & Cinematics (a.k.a Publisher Content)"}
  
  if(df$subcat_cf[i] == "Alternative__amp__Natural_Medicine"){
    df$new_subcat_cf[i] ="Alternative & Natural Medicine"}
  
  
  
  if(df$subcat_cf[i] == "Health_Conditions_"){
    df$new_subcat_cf[i] ="Health Conditions "}
  
  if(df$subcat_cf[i] == "Healthy_Living__amp__Personal_Care"){
    df$new_subcat_cf[i] ="Healthy Living & Personal Care"}
  
  if(df$subcat_cf[i] == "Mental_Health"){
    df$new_subcat_cf[i] ="Mental Health"}
  
  
  if(df$subcat_cf[i] == "Weight_loss__amp__nutrition"){
    df$new_subcat_cf[i] ="Weight loss & nutrition"}
  
  if(df$subcat_cf[i] == "Ambient_noise"){
    df$new_subcat_cf[i] ="Ambient noise"}
  
  if(df$subcat_cf[i] == "Clubs__amp__Organizations"){
    df$new_subcat_cf[i] ="Clubs & Organizations"}
  
  
  
  if(df$subcat_cf[i] == "Special_Occasions"){
    df$new_subcat_cf[i] ="Special Occasions"}
  
  
  if(df$subcat_cf[i] == "Crafts___DIY"){
    df$new_subcat_cf[i] ="Crafts / DIY"}
  
  if(df$subcat_cf[i] == "Gardening__amp__Landscaping"){
    df$new_subcat_cf[i] ="Gardening & Landscaping"}
  
  if(df$subcat_cf[i] == "Home_Decor"){
    df$new_subcat_cf[i] ="Home Decor"}
  
  if(df$subcat_cf[i] == "Home_Improvement"){
    df$new_subcat_cf[i] ="Home Improvement"}
  
  
  if(df$subcat_cf[i] == "Real_Estate__amp__House_Hunting"){
    df$new_subcat_cf[i] ="Real Estate & House Hunting"}
  
  if(df$subcat_cf[i] == "Advocacy__amp__Lobbying"){
    df$new_subcat_cf[i] ="Advocacy & Lobbying"}
  
  if(df$subcat_cf[i] == "Crime__amp__Justice"){
    df$new_subcat_cf[i] ="Crime & Justice"}
  
  if(df$subcat_cf[i] == "Federal_Government_Agency"){
    df$new_subcat_cf[i] ="Federal Government Agency"}
  
  if(df$subcat_cf[i] == "Individual_Public_Officer_Politician"){
    df$new_subcat_cf[i] ="Individual Public Officer/Politician"}
  
  if(df$subcat_cf[i] == "State___Local_Government_Agency"){
    df$new_subcat_cf[i] ="State / Local Government Agency"}
  
  
  if(df$subcat_cf[i] == "Easy_Listening"){
    df$new_subcat_cf[i] ="Easy Listening"}
  
  
  if(df$subcat_cf[i] == "Hip_Hop_Rap"){
    df$new_subcat_cf[i] ="Hip-Hop/Rap"}
  
  if(df$subcat_cf[i] == "J_Pop"){
    df$new_subcat_cf[i] ="J-Pop"}
  
  
  if(df$subcat_cf[i] == "K_Pop"){
    df$new_subcat_cf[i] ="K-Pop"}
  
  if(df$subcat_cf[i] == "Music_News___Magazines___Lifestyle___Culture"){
    df$new_subcat_cf[i] ="Music News / Magazines / Lifestyle / Culture"}
  
  if(df$subcat_cf[i] == "Music_M&#xC3;&#xBA;sica_Popular_Brasileira___MPB__"){
    df$new_subcat_cf[i] ="Music/M├â┬║sica Popular Brasileira ('MPB')"}
  
  if(df$subcat_cf[i] == "New_Age"){
    df$new_subcat_cf[i] ="New Age"}
  
  
  if(df$subcat_cf[i] == "R_amp_B_Soul"){
    df$new_subcat_cf[i] ="R&B/Soul"}
  
  if(df$subcat_cf[i] == "Radio_Station"){
    df$new_subcat_cf[i] ="Radio Station"}
  
  
  if(df$subcat_cf[i] == "Show_Tunes"){
    df$new_subcat_cf[i] ="Show Tunes"}
  
  
  if(df$subcat_cf[i] == "LGBT"){
    df$new_subcat_cf[i] ="LGBT"}
  
  if(df$subcat_cf[i] == "Men_s_Interests"){
    df$new_subcat_cf[i] ="Men's Interests"}
  
  if(df$subcat_cf[i] == "Religious_Groups"){
    df$new_subcat_cf[i] ="Religious Groups"}
  
  if(df$subcat_cf[i] == "Women_s_Interests"){
    df$new_subcat_cf[i] ="Women's Interests"}
  
  if(df$subcat_cf[i] == "Social_Issues__amp__Advocacy"){
    df$new_subcat_cf[i] ="Social Issues & Advocacy"}
  
  if(df$subcat_cf[i] == "Animal_Care_Products__amp__Services"){
    df$new_subcat_cf[i] ="Animal Care Products & Services"}
  
  
  if(df$subcat_cf[i] == "Science_Fiction"){
    df$new_subcat_cf[i] ="Science Fiction"}
  
  if(df$subcat_cf[i] == "Action__amp__Extreme_Sports"){
    df$new_subcat_cf[i] ="Action & Extreme Sports"}
  
  if(df$subcat_cf[i] == "American_Football"){
    df$new_subcat_cf[i] ="American Football"}
  
  if(df$subcat_cf[i] == "Auto_racing"){
    df$new_subcat_cf[i] ="Auto racing"}
  
  
  if(df$subcat_cf[i] == "Body_Building"){
    df$new_subcat_cf[i] ="Body Building"}
  
  if(df$subcat_cf[i] == "College_Sports"){
    df$new_subcat_cf[i] ="College Sports"}
  
  
  if(df$subcat_cf[i] == "Fantasy_Sports"){
    df$new_subcat_cf[i] ="Fantasy Sports"}
  
  if(df$subcat_cf[i] == "Football_or_Soccer"){
    df$new_subcat_cf[i] ="Football or Soccer"}
  
  
  if(df$subcat_cf[i] == "High_School_Sports"){
    df$new_subcat_cf[i] ="High School Sports"}
  
  if(df$subcat_cf[i] == "Ice_Hockey"){
    df$new_subcat_cf[i] ="Ice Hockey"}
  
  if(df$subcat_cf[i] == "Professional_Sports"){
    df$new_subcat_cf[i] ="Professional Sports"}
  
  
  if(df$subcat_cf[i] == "Running__amp__Walking"){
    df$new_subcat_cf[i] ="Running & Walking"}
  
  if(df$subcat_cf[i] == "Track__amp__Field"){
    df$new_subcat_cf[i] ="Track & Field"}
  
  
  
  if(df$subcat_cf[i] == "Computers__amp__Electronics"){
    df$new_subcat_cf[i] ="Computers & Electronics"}
  
  if(df$subcat_cf[i] == "Consumer_Electronics"){
    df$new_subcat_cf[i] ="Consumer Electronics"}
  
  
  if(df$subcat_cf[i] == "Children_s"){
    df$new_subcat_cf[i] ="Children's"}
  
  if(df$subcat_cf[i] == "Science_Fiction"){
    df$new_subcat_cf[i] ="Science Fiction"}
  
  if(df$subcat_cf[i] == "R_amp_B_Soul"){
    df$new_subcat_cf[i] ="R&B/Soul"}
  
  if(df$subcat_cf[i] == "Stand_Up"){
    df$new_subcat_cf[i] = "Stand-Up"}
  
  if(df$subcat_cf[i] == "Video_Games___Tutorials__Walkthroughs__Tips_and_Tricks"){
    df$new_subcat_cf[i] = "Video_Games___Tutorials__Walkthroughs__Tips_and_Tricks"}
  
  if(df$subcat_cf[i] == "Social_Issues__amp__Advocacy"){
    df$new_subcat_cf[i] = "Social Issues & Advocacy"}
    
    if(df$subcat_cf[i] == "General_Interest___Headline_News"){
      df$new_subcat_cf[i] ="General Interest / Headline News"
      
  }else{
    df$new_subcat_cf[i] = df$subcat_cf[i]
  }
  
  print(i)
}
write.csv(df,"cat_recat_double_check.csv", na="", row.names=F)
