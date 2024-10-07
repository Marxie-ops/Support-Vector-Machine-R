

# Importing libraries
install.packages("e1071")
library(e1071)
library(datasets) # Contains the Iris data set
library(caret)# Package for machine learning algorithms / CARET stands for Classification And REgression Training
library(dplyr)
# Importing the Iris data set
data(iris)

# Check to see if there are missing data?
sum(is.na(iris))

# To achieve reproducible model; set the random seed number
set.seed(100)

# Performs stratified random split of the data set
TrainingIndex <- createDataPartition(iris$Species, p=0.8, list = FALSE,times = 1)
TrainingSet <- iris[TrainingIndex,] # Training Set
TestingSet <- iris[-TrainingIndex,] # Test Set

# Compare scatter plot of the 80 and 20 data subsets
library(ggplot2)
ggplot(TrainingSet, aes(y=Sepal.Length, x= Petal.Length, col= Species))+geom_point()+labs(title="Scatter Plot of Training Subset 80%")+
  theme(
  plot.background = element_rect(fill = "green", color= "white"))+theme(
    plot.title = element_text(hjust = 0.5) # Center-align the title
  )
  

# Scatter plot for the testing subset
ggplot(TestingSet, aes(x = Petal.Length, y = Sepal.Length, col= Species)) +
  geom_point() +
  labs(title = "Scatter Plot of Testing Subset 20%")+
  theme(
    plot.background = element_rect(fill= "pink", color= "grey")
  )+theme(plot.title = element_text(hjust=0.5))
#Comparing the two subsets
# Add a new column to indicate the data subset
TrainingSet$Subset <- "Training"
TestingSet$Subset <- "Testing"
# Combine the training and testing subsets into one data frame
combined_data <- rbind(TrainingSet, TestingSet)

ggplot(combined_data, aes(x = Petal.Length, y = Sepal.Length, color = Species)) +
  geom_point() +
  labs(title = "Comparison of Training and Testing Subsets") +
  theme(panel.background = element_rect(fill ="grey", color="black"))+theme(
    plot.background = element_rect(fill= "green", color= "black"))+theme(plot.title = element_text(hjust=0.5))+
  facet_wrap(~ Subset)

# SVM model (polynomial kernel)

# Build Training model
factor_levels<-sapply(TrainingSet, function(x) if(is.factor(x)) levels(x))
print(factor_levels)
single_level_factors <- sapply(TrainingSet, function(x) !(is.factor(x) && length(nlevels(x)) == 1))
print(single_level_factors)
# Assuming you have a data frame called `TrainingSet` and a vector `single_level_factors`
# containing the names of single-level factors
single_level_factors <- as.numeric(single_level_factors)

print(single_level_factors)# Now you can proceed with your analysis using the cleaned TrainingSet


levels(TrainingSet$Species)

class(TrainingSet$Species)

table(TrainingSet$Species)
TrainingSet$Species <- as.factor(TrainingSet$Species)
nlevels(TrainingSet$Species) # counts the no. of levels in the Species column
# Check structure and levels
str(TrainingSet$Species)


# Build CV model
Model.cv <- train(Species ~., data = TrainingSet,
                  method = "svmPoly",
                  na.action = na.omit,
                  preProcess = c("scale", "center"),
                  trControl = trainControl(method = "cv", number = 10),
                  tuneGrid = data.frame(degree = 1, scale = 1, C = 1)
)

# Apply model for prediction
Model.training <-predict(Model, TrainingSet) # Apply model to make prediction on Training set
Model.testing <-predict(Model, TestingSet) # Apply model to make prediction on Testing set
Model.cv <-predict(Model.cv, TrainingSet) # Perform cross-validation

# Model performance (Displays confusion matrix and statistics)
Model.training.confusion <-confusionMatrix(Model.training, TrainingSet$Species)
Model.testing.confusion <-confusionMatrix(Model.testing, TestingSet$Species)
Model.cv.confusion <-confusionMatrix(Model.cv, TrainingSet$Species)

print(Model.training.confusion)
print(Model.testing.confusion)
print(Model.cv.confusion)

# Feature importance
Importance <- varImp(Model)
plot(Importance)
plot(Importance, col = "red")
