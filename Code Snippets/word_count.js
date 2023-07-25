require(['jquery-noconflict'], function(jQuery) {    
  //Ensure MooTools is where it must be
  Window.implement('$', function(el, nc){
    return document.id(el, nc, this.document);
  });
  var $ = window.jQuery;
  // Use `$` in here.

  // if you want to set up an override, give the class 'remove-stopword-listener'
  // to the checkbox
  var $stopValidationListenerTargetElement = $(".remove-stopword-validation"),
      $wordCountTargetElement = $("textarea.count-my-words"),
      $wordCountShowElement = $(".show-word-count"),
      minOkWordCount = 250,
      useCustomValidator = false,
      stopwords = ["a", "able", "about", "above", "abst", "accordance", "according", "accordingly", "across", "act", "actually", "added", "adj", "adopted", "affected", "affecting", "affects", "after", "afterwards", "again", "against", "ah", "all", "almost", "alone", "along", "already", "also", "although", "always", "am", "among", "amongst", "an", "and", "announce", "another", "any", "anybody", "anyhow", "anymore", "anyone", "anything", "anyway", "anyways", "anywhere", "apparently", "approximately", "are", "aren", "arent", "arise", "around", "as", "aside", "ask", "asking", "at", "auth", "available", "away", "awfully", "b", "back", "be", "became", "because", "become", "becomes", "becoming", "been", "before", "beforehand", "begin", "beginning", "beginnings", "begins", "behind", "being", "believe", "below", "beside", "besides", "between", "beyond", "biol", "both", "brief", "briefly", "but", "by", "c", "ca", "came", "can", "cannot", "can't", "cause", "causes", "certain", "certainly", "co", "com", "come", "comes", "contain", "containing", "contains", "could", "couldnt", "d", "date", "did", "didn't", "different", "do", "does", "doesn't", "doing", "done", "don't", "down", "downwards", "due", "during", "e", "each", "ed", "edu", "effect", "eg", "eight", "eighty", "either", "else", "elsewhere", "end", "ending", "enough", "especially", "et", "et-al", "etc", "even", "ever", "every", "everybody", "everyone", "everything", "everywhere", "ex", "except", "f", "far", "few", "ff", "fifth", "first", "five", "fix", "followed", "following", "follows", "for", "former", "formerly", "forth", "found", "four", "from", "further", "furthermore", "g", "gave", "get", "gets", "getting", "give", "given", "gives", "giving", "go", "goes", "gone", "got", "gotten", "h", "had", "happens", "hardly", "has", "hasn't", "have", "haven't", "having", "he", "hed", "hence", "her", "here", "hereafter", "hereby", "herein", "heres", "hereupon", "hers", "herself", "hes", "hi", "hid", "him", "himself", "his", "hither", "home", "how", "howbeit", "however", "hundred", "i", "id", "ie", "if", "i'll", "im", "immediate", "immediately", "importance", "important", "in", "inc", "indeed", "index", "information", "instead", "into", "invention", "inward", "is", "isn't", "it", "itd", "it'll", "its", "itself", "i've", "j", "just", "k", "keep", "keeps", "kept", "keys", "kg", "km", "know", "known", "knows", "l", "largely", "last", "lately", "later", "latter", "latterly", "least", "less", "lest", "let", "lets", "like", "liked", "likely", "line", "little", "'ll", "look", "looking", "looks", "ltd", "m", "made", "mainly", "make", "makes", "many", "may", "maybe", "me", "mean", "means", "meantime", "meanwhile", "merely", "mg", "might", "million", "miss", "ml", "more", "moreover", "most", "mostly", "mr", "mrs", "much", "mug", "must", "my", "myself", "n", "na", "name", "namely", "nay", "nd", "near", "nearly", "necessarily", "necessary", "need", "needs", "neither", "never", "nevertheless", "new", "next", "nine", "ninety", "no", "nobody", "non", "none", "nonetheless", "noone", "nor", "normally", "nos", "not", "noted", "nothing", "now", "nowhere", "o", "obtain", "obtained", "obviously", "of", "off", "often", "oh", "ok", "okay", "old", "omitted", "on", "once", "one", "ones", "only", "onto", "or", "ord", "other", "others", "otherwise", "ought", "our", "ours", "ourselves", "out", "outside", "over", "overall", "owing", "own", "p", "page", "pages", "part", "particular", "particularly", "past", "per", "perhaps", "placed", "please", "plus", "poorly", "possible", "possibly", "potentially", "pp", "predominantly", "present", "previously", "primarily", "probably", "promptly", "proud", "provides", "put", "q", "que", "quickly", "quite", "qv", "r", "ran", "rather", "rd", "re", "readily", "really", "recent", "recently", "ref", "refs", "regarding", "regardless", "regards", "related", "relatively", "research", "respectively", "resulted", "resulting", "results", "right", "run", "s", "said", "Sam", "same", "Sara", "saw", "say", "saying", "says", "sec", "section", "see", "seeing", "seem", "seemed", "seeming", "seems", "seen", "self", "selves", "sent", "seven", "several", "shall", "she", "shed", "she'll", "shes", "should", "shouldn't", "show", "showed", "shown", "showns", "shows", "significant", "significantly", "similar", "similarly", "since", "six", "slightly", "so", "some", "somebody", "somehow", "someone", "somethan", "something", "sometime", "sometimes", "somewhat", "somewhere", "soon", "sorry", "specifically", "specified", "specify", "specifying", "state", "states", "still", "stop", "strongly", "sub", "substantially", "successfully", "such", "sufficiently", "suggest", "sup", "sure", "t", "take", "taken", "taking", "tell", "tends", "th", "than", "thank", "thanks", "thanx", "that", "that'll", "thats", "that've", "the", "their", "theirs", "them", "themselves", "then", "thence", "there", "thereafter", "thereby", "thered", "therefore", "therein", "there'll", "thereof", "therere", "theres", "thereto", "thereupon", "there've", "these", "they", "theyd", "they'll", "theyre", "they've", "think", "this", "those", "thou", "though", "thoughh", "thousand", "throug", "through", "throughout", "thru", "thus", "til", "tip", "to", "together", "too", "took", "toward", "towards", "tried", "tries", "truly", "try", "trying", "ts", "twice", "two", "u", "un", "under", "unfortunately", "unless", "unlike", "unlikely", "until", "unto", "up", "upon", "ups", "us", "use", "used", "useful", "usefully", "usefulness", "uses", "using", "usually", "v", "value", "various", "'ve", "very", "via", "viz", "vol", "vols", "vs", "w", "want", "wants", "was", "wasn't", "way", "we", "wed", "welcome", "we'll", "went", "were", "weren't", "we've", "what", "whatever", "what'll", "whats", "when", "whence", "whenever", "where", "whereafter", "whereas", "whereby", "wherein", "wheres", "whereupon", "wherever", "whether", "which", "while", "whim", "whither", "who", "whod", "whoever", "whole", "who'll", "whom", "whomever", "whos", "whose", "why", "widely", "willing", "wish", "with", "within", "without", "won't", "words", "world", "would", "wouldn't", "www", "x", "y", "yes", "yet", "you", "youd", "you'll", "your", "youre", "yours", "yourself", "yourselves", "you've", "z", "zero", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "", ",", ".", "?", "!"];

  // initialization vars
  var stopword_count = 0,
      wordCountOverride = false,
      word_limit_passed = false

  // validationKillerListener();

  $wordCountTargetElement.on('change keyup', function() {
    console.log("changing");
    wordCountCheck()
  });
  
  // turns off validation if checkbox checked (optional)
  function validationKillerListener(){ 
    $stopValidationListenerTargetElement.click(function(){
      if(this.checked){
        wordCountOverride = true
        wordCountCheck()
      } else {
        wordCountOverride = false
        wordCountCheck()
      }
    })
  }

  function wordCountCheck(){
    var $textBox = $wordCountTargetElement,
        words = $textBox.val().split(" "),
        wordcount = words.length;

    reset_variables() // resets stopword_count, word_limit_passed
    count_stopwords(words) // calculates stopword_count

    var ok_wordcount = wordcount - stopword_count;
    check_word_limit(ok_wordcount)

    var text = ok_wordcount + " words";
    
    $wordCountShowElement.html(text);
    
    if (wordcount < minOkWordCount && wordCountOverride != true ) {
      $wordCountShowElement.removeClass('yellow green').addClass('red');    
    } else if (wordcount < minOkWordCount*2 && wordCountOverride != true) {
      $wordCountShowElement.removeClass('red green').addClass('yellow');    
    } else {
      $wordCountShowElement.removeClass('yellow red').addClass('green'); 
    }
  }

  function reset_variables(){
    stopword_count = 0
    word_limit_passed = false
  }

  function count_stopwords(words){
    $.each(words, function(index, value) {
      var lowerCased = value.toLowerCase()
      if(stopwords.contains(lowerCased)){
        stopword_count += 1
      };
    });
  }

  function check_word_limit(okwordcount){
    if (okwordcount >= minOkWordCount || wordCountOverride == true){
      word_limit_passed = true
    } 
    else{
      word_limit_passed = false    
    }
  }

  window.validatorWordLimitPassed = function() {
    if (useCustomValidator == true && !word_limit_passed) {
      return false
    } else {
      return true
    }
  }
});    

window.content_grader = CMLFormValidator.addAllThese([
  ['internationalAddress', {
    errorMessage: function(){
      return ("Whoops! Looks like you're under the minimum word count.");
    },
    validate: function(element, props){
      return window.validatorWordLimitPassed();
    }
  }]
]);

