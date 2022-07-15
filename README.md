# Word search solver
This repository contains the code to solve a (rectangular) word searcher and the code to create the corresponding app, which can be found at [shinyapps.io](https://rjjanse.shinyapps.io/word_searcher_solver/). 

The code was written in R version 4.1.3 and the app last updated on the 15th of July 2022.

## Explanation of code
### Step 1. Generate word search
In step 1, the text string that is entered is split per character and transformed into a matrix. Due to how the ```matrix()``` function works in R, it needs to be transposed. Therefore, the number of columns is supplied to the ```nrow``` argument of ```matrix()```, instead of to ```ncol```. The arguments are added and seperated by semicolon. Any spaces are removed. The matrix is duplicated to one in which the words are sought and one in which the found words are blanked out.

### Step 2. Start loop for each word that has to be found
#### Step 2a. Finding starting characters.
The loop starts by taking the first word that has to be found and taking the first character of this word. Take for example a Dutch word search about birds. Below you can find the word search and words that have to be found.

|   |   |   |   |   |   |   |   |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| s | p | r | e | e | u | w | k | 
| s | n | a | g | l | y | n | h | 
| s | u | m | g | n | i | r | p |
| t | u | u | f | v | e | u | g |
| g | e | n | d | m | t | u | s |
| f | i | u | d | t | u | o | h |
| o | o | i | e | v | a | a | r |
| g | d | r | e | z | i | u | b |

Words: ringmus, buizerd, fuut, goudvink, houtduif, nylgans, ooievaar, putter, spreeuw

So for the first word of the word search, ringmus, the code first identifies all locations of the letter 'r':

|   |   |   |   |   |   |   |   |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| s | p | **R** | e | e | u | w | k | 
| s | n | a | g | l | y | n | h | 
| s | u | m | g | n | i | **R** | p |
| t | u | u | f | v | e | u | g |
| g | e | n | d | m | t | u | s |
| f | i | u | d | t | u | o | h |
| o | o | i | e | v | a | a | **R** |
| g | d | **R** | e | z | i | u | b |

#### Step 2b. Finding adjacent second characters
The second step in the loop is that all adjacent boxes for each first character are checked on whether they contain the second character, in this case 'i'.

|   |   |   |   |   |   |   |   |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| s | *p* | **R** | *e* | e | u | w | k | 
| s | *n* | *a* | *g* | l | *y* | *n* | *h* | 
| s | u | m | g | n | *i* | **R** | *p* |
| t | u | u | f | v | *e* | *u* | *g* |
| g | e | n | d | m | t | u | s |
| f | i | u | d | t | u | *o* | *h* |
| o | *o* | *i* | *e* | v | a | *a* | **R** |
| g | *d* | **R** | *e* | z | i | *u* | *b* |

Any character that then matches the second character has its location saved, including the direction from the first character (e.g., one box up, one box left). Any first character location which does not have a second character adjacent to it is dropped.

|   |   |   |   |   |   |   |   |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| s | p | r | e | e | u | w | k | 
| s | n | a | g | l | y | n | h | 
| s | u | m | g | n | **I** | **R** | p |
| t | u | u | f | v | e | u | g |
| g | e | n | d | m | t | u | s |
| f | i | u | d | t | u | o | h |
| o | o | **I** | e | v | a | a | r |
| g | d | **R** | e | z | i | u | b |

#### Step 2c. Continuing with the remaining characters
We now now the direction in which to check for the remaining characters of the word. When there is only one possible location for the word remaining, the loop is stopped. The length of the word is determined, from which the end coordinate is calculated. All locations in between are then also calculated.

|   |   |   |   |   |   |   |   |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| s | p | r | e | e | u | w | k | 
| s | n | a | g | l | y | n | h | 
| **S** | **U** | **M** | **G** | **N** | **I** | **R** | p |
| t | u | u | f | v | e | u | g |
| g | e | n | d | m | t | u | s |
| f | i | u | d | t | u | o | h |
| o | o | i | e | v | a | a | r |
| g | d | r | e | z | i | u | b |

In the matrix in which the words are blanked out, the locations then have their character changed to a dot. Then the next word is started.

|   |   |   |   |   |   |   |   |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| s | p | r | e | e | u | w | k | 
| s | n | a | g | l | y | n | h | 
| . | . | . | . | . | . | . | p |
| t | u | u | f | v | e | u | g |
| g | e | n | d | m | t | u | s |
| f | i | u | d | t | u | o | h |
| o | o | i | e | v | a | a | r |
| g | d | r | e | z | i | u | b |

### Step 3. When this process has been completed, the solved matrix only has characters that were not part of the words that had to be found.

|   |   |   |   |   |   |   |   |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| . | . | . | . | . | . | . | . | 
| . | . | . | . | . | . | . | h | 
| . | . | . | . | . | . | . | . |
| . | . | . | . | . | e | . | g |
| g | e | n | . | m | . | u | s |
| . | . | . | . | . | . | . | . |
| . | . | . | . | . | . | . | . |
| . | . | . | . | . | . | . | . |

These words are then combined into a single string, which in some word search puzzles may form a solution. In the case of the example puzzle, this would be heggenmus (or [dunnock](https://en.wikipedia.org/wiki/Dunnock) in English).
