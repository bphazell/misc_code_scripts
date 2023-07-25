  source("parse_xml_helpers.R")
  
  # the variable gets reused: set of all cml: elements that require contributor response
  possible_elements = c("textarea", "text",
                        "checkbox", "checkboxes",
                        "radios", "radio",
                        "select", "option", "group", "html",
                        "taxonomy",
                        "hours",
                        "ratings")
  
  possible_elements_parent = c("textarea", "text", 
                               "checkbox", "checkboxes",
                               "radios",
                               "select",
                               "taxonomy",
                               "hours",
                               "ratings")
  
  
  change_cml_R <- function(old_cml, spotcheck) {
    if (is.null(old_cml) || is.na(old_cml) || old_cml=="") {
      return("")
    } else {
      cml = old_cml
      doc <- tryCatch(xmlTreeParse(cml, useInternalNodes = T,
                                   fullNamespaceInfo=F, isHTML=T),
                      error = function(e) {
        if (grepl(e, pattern = "XML content does not seem to be XML")) {
          stop("There was a liquid element that wasn't inside any HTML elements. XML cannot parse that. This is most likely {% capture %} or {% assign %}, possibly {% if %}.
           Wrap your {% capture %} or {% assign %} statements in a 'div', save the job, refresh the page, try again.")
        } else {
          stop(e)
        }
      })
      # "possible_elements" is defined on line 5
      element_vector = list()
      type_vector = list()
      ind =1 
      #find all elements
      for (el_name in possible_elements_parent) {
        radios_all = NULL # clear radios all
        if (el_name == "checkbox") {
          # get elements that are single checkbox
          radios_all = getNodeSet(doc, paste("//", el_name, sep=""), addFinalizer=T)
          # drop elements who are children of "checkboxes"
          if (length(radios_all) > 0) {
            for (ch_index in length(radios_all):1) {
              parent = xmlName(xmlParent(radios_all[[ch_index]]))
              if (parent == "checkboxes") {
                radios_all[[ch_index]] = NULL
              }
            }
          }
        } else {
          radios_all = getNodeSet(doc, paste("//", el_name, sep=""), addFinalizer=T)
        }
        if (length(radios_all)>0) {
          print(paste("There was a", el_name))
          element_vector[[ind]] = radios_all
          type_vector[[ind]] = el_name
          ind = ind+1
        }
      }
      
      multiples_vector = list()
      reasons_vector = list()
      ind =1 
      #transform all elements
      if (length(element_vector) >0) {
        # first, update the elements and make reasons
        for (i in 1:length(element_vector)) {
          radios_all = element_vector[[i]]
          el_name = type_vector[[i]]
          print(paste("Found some", el_name))
          radios_attributes = xmlApply(radios_all,xmlAttrs)
          ## transform radios to make them into checkboxes
          print("transforming: multiply")
          sapply(1:length(radios_all), function(i) {
            print("About to hit multiples")
            multiples(element_node= radios_all[[i]], element_attributes= radios_attributes[[i]], type=el_name)
          })
          radios_reasons = sapply(radios_attributes, function(x) make_reason_for_element(x, el_name))
          #substitute old elements with new elements and reasons in doc_string
          reasons_vector[[ind]] = radios_reasons
          ind = ind + 1
        }
        # second, add reasons to their nodes
        if (spotcheck) {
          print("SPOTCHECK: do not add reasons")
        } else {
          for (j in 1:length(element_vector)) {
            radios_all = element_vector[[j]]
            radios_reasons = reasons_vector[[j]]
            for (p in 1:length(radios_all)) {
              reason_node = newXMLTextNode(radios_reasons[[p]])
              break_node = newXMLNode("br")
              # add reason node behind the current node
              addSibling(radios_all[[p]], kids = list(break_node,reason_node,break_node), after=TRUE)
            }
          }
        }
      } else {
        print("No elements found")
      }
      # update logic done in groups
      group_elements = getNodeSet(doc, paste("//", "group", sep=""), addFinalizer=T)
      if (length(group_elements)>0) {
        update_logic_in_groups(group_elements)
      }
      doc_string = as(doc, "character") 
      # XML text butchers the <>, replace them back
      doc_string = str_split(doc_string, pattern="\n", n=2)[[1]][2] # drop the "<?xml version=\"1.0\"?>" line
      # drop the <html><body> and </body></html> tags
      doc_string = gsub(doc_string, pattern="^<html><body>", replacement="")
      doc_string = gsub(doc_string, pattern="</body></html>", replacement="")
      # replace the faulty multiplez
      doc_string = gsub(doc_string, pattern="multiplez=", replacement="multiple=")
      # correct lts and gts
      doc_string = correct_let_gts(doc_string)
      # replace %7B and %7D with { and }
      doc_string = gsub(doc_string, pattern="%7B", replacement="{")
      doc_string = gsub(doc_string, pattern="%7D", replacement="}")
      doc_string = prepend_with_newlines(doc_string)
      output_string = substitute_cml_tags(doc_string)
      # if job is meant to be a spotcheck,  there is no skipping
      if (spotcheck) {
        # add a non-required reason at the end of the job
        textarea = paste0("\n<cml:textarea name=\"spotcheck_comment\"",
                          " label=\"Let us know if you have comments about this unit:\"",
                          " aggregation=\"all\"></cml:textarea>")
        output_string = paste(output_string, textarea, sep="\n")
        
      } else {
        # add skip wrapper
        prepend = paste0("<cml:checkbox label=\"This is not a good Gold unit, I'd like to skip it.\" name='skip'></cml:checkbox>",
                         "\n","<cml:textarea only-if=\"!skip:unchecked\" name=\"skip_reason\"",
                         " label=\"Why is this not a good test question?\"  validates=\"required\"></cml:textarea>",
                         "\n","<cml:group name='gold_group' label='' only-if='skip:unchecked'>","\n")
        append = paste0("\n","</cml:group>")
        output_string = paste(prepend, output_string, append, sep="\n")
      }
      return(output_string)
    }
    
  }