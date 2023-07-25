# helper functions for parse_xml_for_testquestion.R

# TODO add taxonomies

enable_multiples_radios <- function(element_node) {
  ## add subcase not ot turn the binary ones into checkboxes
  kids = xmlChildren(element_node)
  if (length(kids) > 2) {
    xmlName(element_node) = "checkboxes"
    xmlApply(element_node, function(x) if (xmlName(x)=="radio") { xmlName(x) = "checkbox" })
  }
}

enable_multiples_checkboxes <- function(element_node) {
  # you don't need to do anything
}

enable_multiples_text <- function(element_node) {
  xmlAttrs(element_node)["multiplez"] = "true"
}

enable_multiples_textarea <- function(element_node) {
  xmlAttrs(element_node)["multiplez"] = "true"
}

enable_multiples_select <- function(element_node) {
  xmlName(element_node) = "checkboxes"
  xmlApply(element_node, function(x) if (xmlName(x)=="option") { xmlName(x) = "checkbox" })
}

enable_multiples_taxonomy <- function(element_node) {
  xmlAttrs(element_node)["multi-select"] = "true"
}

enable_multiples_hours <- function(element_node) {
  # do nothing? extra time range is enabled by default
}

enable_multiples_ratings <- function(element_node) {
  # this one is kind of complex
  # we change the element to "checkboxes" and add children depending on "points" argument
  xmlName(element_node) = "checkboxes"
  num_points = as.numeric(xmlAttrs(element_node)["points"])
  point_vector = 1:num_points
  for (p in point_vector) {
    # make a new element: checkbox
    # value = p
    # label = p
    # and append to element_node
    #element_node = append.xmlNode(to=element_node, new_level)
    addChildren(element_node, newXMLNode("checkbox",
                              attrs = c(label =p, value=p)))
  }
}


update_logic <- function(logic) {
  logic_components = strsplit(logic, split="\\+\\+|\\|\\|")[[1]]
  logic_names = sapply(logic_components, function(x) 
    gsub(gsub(x, pattern="!", replacement="\\!"), pattern="(:.*)", replacement="")
  )
  logic_names = gsub(pattern="[^[:alnum:][:space:]_]", replacement="",
                     logic_names) # drop all non alphanumeric characters
  logic_names = gsub(tolower(logic_names), pattern=" ", replacement="_") # to lower and no spaces
  logic_names_changed = paste0(logic_names, "_testquestion")
  new_logic = logic
  logic_components_changed = c()
  for (i in 1:length(logic_names)) {
    to_replace = paste0("(^|\\!)",logic_names[i],"(\\:|$)")
    if (grepl(logic_names[i], pattern="\\:")) {
      replace_with = paste0(logic_names_changed[i])
    } else {
      replace_with = paste0(logic_names_changed[i], ":")
    }
    logic_components_changed[i] = gsub(logic_components[i], pattern = to_replace, replacement=replace_with)
  }
  for (i in 1:length(logic_components_changed)) {
    to_replace = gsub(gsub(gsub(gsub(logic_components[i], pattern="\\:", replacement="\\\\:"), 
                                pattern="\\!", replacement="\\\\!"),
                           pattern="\\[", replacement="\\\\["),
                      pattern="\\]", replacement="\\\\]")
    replace_with = gsub(gsub(gsub(gsub(logic_components_changed[i], pattern="\\:", replacement="\\\\:"), 
                                  pattern="\\!", replacement="\\\\!"),
                             pattern="\\[", replacement="\\\\["),
                        pattern="\\]", replacement="\\\\]")
    logic = gsub(logic, pattern=to_replace, replacement =replace_with)
  }
  return(logic)
}


make_reason_for_element <- function(element_attributes, el_name) {
  print("IN make_reason_for_element")
  print(el_name)
  attributes = element_attributes
  label = attributes["label"]
  if (is.na(label)) {
    label=""
  }
  name = attributes["name"] # this is the name to use in only-if
  if (is.na(name)) {
    name = label # make one from label
  }
  name = gsub(pattern="[^[:alnum:][:space:]_]", replacement="",
              name) # drop all non alphanumeric characters
  name = gsub(tolower(name), pattern=" ", replacement="_")
  name = paste0(name,"_testquestion") # all elements will be gold now
  new_name = paste(name, "_reason", sep="") # this is the name for the reason
  instructions = paste("This reason box is for the question directly above it.")
  logic = attributes["only-if"]
  print(logic)
  if (is.na(logic) || logic=="") {
    if (el_name != "taxonomy") {
      new_logic = name
    } else {
      new_logic = ""
    }
  } else {
    logic=update_logic(logic)
    if (el_name != "taxonomy") {
      new_logic = paste(name, "++", logic, sep="")
    } else {
      new_logic = logic
    }
  } # provide for the case when "father" field is a single checkbox
  
  reason_line = paste("<textarea name= \"",
                      new_name, "\"",
                      " label=\"Explain Why Your Answer Above is Correct (Test Question Explanation):\"",
                      " default = \"A good explanation will tell users why the answer(s) selected is correct",
                      "AND why other answers are incorrect. Please type in complete sentences and use your best English.",
                      "Remember, the goal is to be educational. Do not just repeat the correct answer.\"",
                      " only-if = \"", new_logic, "\"",
                      " validates=\"required\"",
                      " instructions=\"", instructions, "\"",
                      "></textarea>", sep=""
  )
  return(reason_line)
}

multiples <- function(element_node, element_attributes, type) {
  node = element_node
  print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< In multiples")
  attributes = element_attributes
  # the label section
  label = attributes["label"]
  new_label=label
  if (is.na(label)) {
    new_label =""
  }
  # the name section
  name = attributes["name"]
  if (is.na(name)) {
    name = label # use label instead
  }
  name = gsub(pattern="[^[:alnum:][:space:]_]", replacement="",
              name) # drop all non alphanumeric characters
  name = gsub(tolower(name), pattern=" ", replacement="_")
  new_name = paste(name, "_testquestion", sep="")
  # the logic section
  logic = attributes["only-if"]
  if (is.na(logic) || logic=="") {
    new_logic = ""
  } else {
    new_logic=update_logic(logic)
  }
  # the validation section
  validates = attributes["validates"] # validates=NA is caught later
  new_validates = validates
  if (grepl(validates, pattern="ss-required")) {
    new_validates = gsub(validates, pattern="ss-required", replacement="")
    new_validates = str_trim(new_validates) # TODO: also remove duplicate whitespaces
  }
  
  # change name, label, logic, and validation
  xmlAttrs(node)["name"] = new_name
  xmlAttrs(node)["label"] = new_label
  xmlAttrs(node)["only-if"] = new_logic
  
  if (!is.na(new_validates)) {
    xmlAttrs(node)["validates"] = new_validates
  }
  
  print("<<<<<<<<<<<<<<<<< Here before type estimation")
  # now modify elements using text, depending on type
  if (type=="radios") {
    enable_multiples_radios(node)
  } else if (type=="checkboxes") {
    enable_multiples_checkboxes(node)
  } else if (type=="checkbox") {
    enable_multiples_checkboxes(node)
  } else if (type=="text") {
    enable_multiples_text(node)
  } else if (type=="textarea") {
    enable_multiples_textarea(node)
  } else if (type=="select") {
    enable_multiples_select(node)
  } else if (type=="taxonomy") {
    enable_multiples_taxonomy(node)
  } else if (type=="hours") {
    enable_multiples_hours(node)
  } else if (type=="ratings") {
    print("<<<<<<<<<<<< ratings triggered")
    enable_multiples_ratings(node)
  }
  
}

update_logic_in_groups <- function(group_elems) {
  attributes = xmlApply(group_elems,xmlAttrs)
  for (el_number in 1:length(group_elems)) {
    logic = attributes[[el_number]]["only-if"]
    if (is.na(logic) || logic=="") {
      new_logic = ""
    } else {
      new_logic = update_logic(logic)
      xmlAttrs(group_elems[[el_number]])["only-if"] = new_logic
    }
  }
}



prepend_with_newlines <- function(string) {
  new_string = string
  for (i in possible_elements) {
    new_string = gsub(new_string, pattern=paste("<", i, " ", sep=""), replacement=paste("\n<", i, " ", sep=""))
    new_string = gsub(new_string, pattern=paste("</", i, " ", sep=""), replacement=paste("\n</", i, " ", sep=""))
  }
  return(new_string)
}


substitute_cml_tags <- function(string) {
  new_string = string
  for (i in possible_elements) {
    new_string = gsub(new_string, pattern=paste("<", i, sep=""), replacement=paste("<cml:", i, sep=""))
    new_string = gsub(new_string, pattern=paste("</", i, sep=""), replacement=paste("</cml:", i, sep=""))
  }
  return(new_string)
}


correct_let_gts <- function(string) {
  new_string = string
  for (i in possible_elements) {
    new_string = gsub(new_string, pattern=paste("\\&gt;\\&lt;/textarea&gt;"), replacement=paste("></textarea>"))
    new_string = gsub(new_string, pattern=paste("\\&lt;textarea"), replacement=paste("<textarea"))
  }
  return(new_string)
}
