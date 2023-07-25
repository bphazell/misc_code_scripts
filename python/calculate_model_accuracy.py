import csv
import numpy

not_beauty_df = pd.read_csv("not_beauty_test/not_beauty_test.csv")
beauty_df = pd.read_csv("beauty_test/beauty_test.csv")
df = not_beauty_df.append(beauty_df, ignore_index=True)

def create_model_labels(threshold, df) :
    df["ml_class_with_threshold"] = ""
    df.loc[df["model_confidence"] > threshold, "ml_class_with_threshold"] = "Beauty"
    df.loc[df["model_confidence"] < threshold, "ml_class_with_threshold"] = "Not Beauty"
    # replaces not class with inverse confidence 
    print("update accuracy")
    df.loc[(1 - df["model_confidence"]) > df["model_confidence"], "model_confidence"] = (1 - df["model_confidence"])
# df.loc[(1 - df["model_confidence"]) > df["model_confidence"], "ml_conf_test2"] = (1 - df["model_confidence"])
    return(df)
    
def calculate_accuracy(confidence , df) :
    df_sub = df.loc[df["model_confidence"] > confidence]
    if (len(df_sub) > 1) :
        match = float(len(df_sub.loc[df_sub["ml_class_with_threshold"] == df_sub["gold_classification"]]))
        total = float(len(df_sub))
        percent_total = round(total/float(len(df)),2)
        accuracy = round(match/total,2)
    else :
        accuracy = "na"
        total = 0
        percent_total = 0
    print("Threshold: "+ str(confidence) +" Accuracy: " + str(accuracy) + " Total Rows: " + str(int(total))
            + " Percent Annotated: " + str(percent_total))
        
    
def calculate_accuracy_per_confidence(df) :
    confidences = np.linspace(0.50,1,10, endpoint=False)
    for confidence in confidences:
        calculate_accuracy(confidence, df)
        
df_w_labels = create_model_labels(0.50, df)
calculate_accuracy_per_confidence(df_w_labels)
calculate_accuracy(.80, df_w_labels )

df_w_labels.to_csv("ta_beauty_test_results.csv")

## for mutli class ###

# For multiclass model

df_fitness = pd.read_csv("fitness_cv/fitness_cv_test_output.csv")

def create_model_labels_multi(df) :
    # replaces not class with inverse confidence 
    df.loc[(1 - df["model_confidence"]) > df["model_confidence"], "model_confidence"] = (1 - df["model_confidence"])
    return(df)

def calculate_accuracy_multi(confidence , df) :
    df_sub = df.loc[df["model_confidence"] > confidence]
    if (len(df_sub) > 1) :
        match = float(len(df_sub.loc[df_sub["ml_class_with_threshold"] == df_sub["gold_classification"]]))
        total = float(len(df_sub))
        percent_total = round(total/float(len(df)),2)
        accuracy = round(match/total,2)
    else :
        accuracy = "na"
        total = 0
        percent_total = 0
    print("Threshold: "+ str(confidence) +" Accuracy: " + str(accuracy) + " Total Rows: " + str(int(total))
            + " Percent Annotated: " + str(percent_total))
            
def calculate_accuracy_per_confidence_multi(df) :
    confidences = np.linspace(0.50,1,10, endpoint=False)
    for confidence in confidences:
        calculate_accuracy_multi(confidence, df)

fitness = create_model_labels_multi(df_fitness)
calculate_accuracy_per_confidence_multi(fitness)

