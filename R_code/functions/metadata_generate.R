####################### List of functions
# Author : Chloé Dalleau, Geomatic Engineer (IRD)
# Supervisor : Julien Barde (IRD)
# Date : 15/02/2018 
# 
# Summary
# 1. metadata_by_var 
# 2. metadata_generate

metadata_by_var <- function(vars_label_list,metadata_model,metadata_id, add_metadata){
  #' @name metadata_by_var
  #' @title Generate metadata by variable
  #' @description Generate metadata of a dataframe with several variables
  #' 
  #' @param vars_label_list list of variable in the dataframe, type=character;
  #' @param metadata_model dataframe with user metadata model (minimal column : "id", rows can contain several metadata model), type=dataframe
  #' @param metadata_id identifier to select the row containing the rigth metadata model in the metadata_model, type = integer;
  #' @param add_metadata list of metadata containing the metadata to add in the metadata model, type = list;
  #' 
  #' @return dataframe with metadata based on metadata model
  #' 
  #' @author Chloé Dalleau, \email{chloe.dalleau@ird.fr}
  #' 
  #' @keywords metadata, metadata model
  #'
  #' @usage
  #'     metadata <- metadata_by_var(vars_label_list=c("distance_value","surface_value"),metadata_model,"catch_database_grid",add_metadata)
  
  
  metadata <- NULL

  
  for (i in 1:length(vars_label_list)){
    
    my_var_label <- vars_label_list[i]
    var_identifier <- paste(add_metadata$identifier,my_var_label,sep="_")
    metadata_var <- metadata_generate(metadata_model=metadata_model,metadata_id[i],dataset_id=var_identifier,add_metadata=add_metadata)

    metadata <- rbind(metadata,metadata_var)
  }
  
  metadata <- cbind(file_id=add_metadata$identifier,metadata)
  
  return(metadata)
}

metadata_generate <- function(metadata_model,metadata_id,dataset_id,add_metadata){
  
  #' @name metadata_generate
  #' @title Generate metadata from a metadata file
  #' @description Take a dataframe with user metadata and add the metadata generated by the treatment function 
  #' @details This function is based on Paul Taconet work available at https://github.com/ptaconet/rtunaatlas/blob/master/R/generate_metadata.R.
  #' 
  #' @param metadata_model dataframe with user metadata model (minimal column : "id", rows can contain several metadata model), type=dataframe
  #' @param metadata_id identifier to select the row containing the rigth metadata model in the metadata_model, type = integer;
  #' @param dataset_id dataset identifier (can be used for file name), type=character;
  #' @param add_metadata list of metadata containing the metadata to add in the metadata model, type = list;
  #' 
  #' @return dataframe with metadata based on metadata model
  #' 
  #' @author Paul Toconet, \email{paul.taconet@ird.fr}
  #' @author Chloé Dalleau, \email{chloe.dalleau@ird.fr}
  #' 
  #' @keywords metadata, metadata model
  #'
  #' @usage
  #'     metadata <- metadata_generate(metadata_model,metadata_id="catch_database_grid",dataset_id="catch_data_from_20130121_to_20170430_indian",add_metadata)
  

  metadata_model <- metadata_input[which(metadata_input$id %in% metadata_id),]
  
  if (dim(metadata_model)[1]==0 ){
    error <- paste0(metadata_id, " is not in the metadata file.")
    stop(error)
  } else {
    # Complete metadata with any other parameter that might have been generated through the R script of dataset generation. It will be pasted to the appropriate column
    metadata_columns_input<-colnames(metadata_model)
    
    for (i in 1:length(metadata_columns_input)){
      content_metadata<-add_metadata[[metadata_columns_input[i]]][[1]]
      if (!(is.null(content_metadata))){
        metadata_model[,metadata_columns_input[i]]<-gsub("@@automatically generated@@","",metadata_model[,metadata_columns_input[i]])
        metadata_model[,metadata_columns_input[i]]<-paste(metadata_model[,metadata_columns_input[i]],content_metadata,sep=" ")
      }
    }
    
    ### Replace holes with metadata elements from other columns of the file
    for (i in 1:length(metadata_columns_input)){
      this_metadata_element<-metadata_model[metadata_columns_input[i]][[1]]
      words_to_replace<-gsub("[\\%\\%]", "", regmatches(this_metadata_element, gregexpr("\\%.*?\\%", this_metadata_element))[[1]])
      if (length(words_to_replace>0)){
        for (j in 1:length(words_to_replace)){
          if (words_to_replace[j] %in% names(add_metadata)){ # modifier metadata_model par add_metadata dans colnames(add_metadata) et add_metadata[words_to_replace[j]][[1]]
            metadata_model[metadata_columns_input[i]]<-gsub(paste0("%",words_to_replace[j],"%"),add_metadata[words_to_replace[j]][[1]],metadata_model[metadata_columns_input[i]][[1]])
          }
        }
      }
    }
    

    
    metadata <- data.table(identifier=dataset_id,metadata_model[!(names(metadata_model) %in% "id")])
    

  }
  
  return(metadata)
  
}

