# Word search solver
This repository contains the code to solve a (rectangular) word searcher and the code to create the corresponding app, which can be found at [shinyapps.io](https://rjjanse.shinyapps.io/word_searcher_solver/). 

The code was written in R version 4.1.3 and the app last updated on the 15th of July 2022.

## Explanation of code
### Step 1. Generate word search
In step 1, the text string that is entered is split per character and transformed into a matrix. Due to how the ```matrix()``` function works in R, it needs to be transposed. Therefore, the number of columns is supplied to the ```nrow``` argument of ```matrix()```, instead of to ```ncol```. The arguments are added and seperated by semicolon. Any spaces are removed.

### Step 2. Start loop for each word that has to be found.
#### Step 2a.
To be added
