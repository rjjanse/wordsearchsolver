library("dplyr")
library("shiny")
library("bslib")
library("thematic")

thematic::thematic_shiny()

# Define UI ---
ui <- fluidPage(
    titlePanel(
        title = h1("Word search solver"),
        windowTitle = "Word search solver"
    ),
    
    headerPanel(h3("Roemer J. Janse - 14/07/2022")),
    headerPanel(h6(uiOutput("git"))),
    
    theme = bslib::bs_theme(
        bg = "#222222", fg = "white", primary = "#cc80c3", secondary = "#f6b4ee",
        base_font = font_google("Space Mono"),
        code_font = font_google("Space Mono")
    ),
    
    sidebarLayout(
       # Sidebar panel for inputs
       sidebarPanel(
           # Select amount of columns
           numericInput("nc", "Number of columns:", 0),
           
           # Add text to explain how to enter data
           helpText("Below, you can enter the word search. Start from the upper left and moving right towards the lower right corner of your word search, add each character, without spaces. Any characters that consist of multiple characters (e.g., ij in Dutch) should be replaced with a single-character alternative (e.g., y for ij). Take note that the alternative should not be used elsewhere in the word search. You can check if you entered the word search correctly using the button 'Check layout' below."),
           
           # Text box to enter word searcher
           textInput("mat", "Enter word search:", placeholder = "JJDSLEIAODPAPES"),
           
           # Allow to check puzzle layout
           actionButton("check", "Check layout", class = "btn btn-secondary"),
           
           # Add text to explain how to enter word_list
           helpText("Below, you can enter the words that need to be found. Seperate words with a semicolon (;)."),
           
           # Text box to enter arguments
           textInput("word_list", "Enter word list:", placeholder = "Word1; Word2;..."),
           
           # Text box for solve button
           helpText("Press the 'Solve' button to sovle the word search. Note that this may take a few seconds."),
           
           # Button to solve
           actionButton("solve", "Solve", class = "btn btn-primary"),
           
           # Add text for reset puzzle
           helpText("Press 'Reset' button before entering a new puzzle."),
           
           # Button to reset puzzle
           actionButton("reset", "Reset", class = "btn btn-primary")
           
       ),
       
       # Main panel for displaying outputs ----
       mainPanel(
           h2("Puzzle layout"),
           tableOutput("puzzle.dis"),
           h2("Puzzle solution"),
           tableOutput("puzzle.sol"),
           h3("Remaining text:"),
           textOutput("solution")
       )
    )
)
            

# Define server logic ----
server <- function(input, output){
    # GitHub link
    url <- a("GitHub", href = "https://github.com/rjjanse/wordsearchsolver.git")
    output$git <- renderUI({
        tagList("Code can be found on my ", url)
    })
    
    # Reset button
    observeEvent(input$reset, {
        output$puzzle.dis <- renderTable({
            ""
        }, 
        colnames = FALSE)
        
        output$puzzle.sol <- renderTable({
            ""
        },
        colnames = FALSE)
        
        # Create solved text for output
        output$solution <- renderText({""})
    })
    
    # Check layout
    observeEvent(input$check, {
        puzzle <- strsplit(input$mat, split = "")
        puzzle <- t(matrix(puzzle[[1]], nrow = input$nc))
        
        puzzle.display <- as.data.frame(puzzle)
        
        output$puzzle.dis <- renderTable({
            puzzle.display
        }, 
        colnames = FALSE)
    }
    )
    
    # Solve puzzle
    observeEvent(input$solve, {
        puzzle <- strsplit(input$mat, split = "")
        puzzle <- t(matrix(puzzle[[1]], nrow = input$nc))
        
        puzzle.display <- as.data.frame(puzzle)
        
        output$puzzle.dis <- renderTable({
            puzzle.display
        }, 
        colnames = FALSE)
        
        word_list <- gsub(" ", "", strsplit(input$word_list, split = ";")[[1]])

        puzzle.solved <- puzzle

        # Select word
        for(i in word_list){
            # Select first character
            char <- strsplit(i, "")[[1]][[1]]

            coords <- data.frame(crd.r = as.numeric(),
                                 crd.c = as.numeric())

            # Search puzzle for first character
            for(r in 1:nrow(puzzle)){
                for(c in 1:ncol(puzzle)){
                    # Save locations of relevant characters
                    if(puzzle[r, c] == char){
                        coords <- rbind(coords, cbind(r, c))
                    }
                }
            }

            ### For each position of a first character, check characters around if they are the second character
            char <- strsplit(i, "")[[1]][[2]]

            # Make dataset to store all new coords
            coords.new <- data.frame(new.r = as.numeric(),
                                     new.c = as.numeric(),
                                     delta.r = as.numeric(),
                                     delta.c = as.numeric())

            # Determine characters around
            for(loc in 1:nrow(coords)){
                # Select location
                location <- coords[loc, ]

                # Make dataset to store all new locations
                locs <- data.frame(new.r = as.numeric(),
                                   new.c = as.numeric(),
                                   delta.r = as.numeric(),
                                   delta.c = as.numeric())

                # Select all locations around
                for(delta.r in -1:1){
                    for(delta.c in -1:1){
                        locs <- rbind(locs, cbind(location[1, 1] + delta.r, location[1, 2] + delta.c, delta.r, delta.c))
                    }
                }

                # Remove any non-existent locations
                locs <- locs %>% filter(V1 >= 1 & V1 <= nrow(puzzle) &
                                            V2 >= 1 & V2 <= ncol(puzzle))

                # Save dataset to save locations of next loop
                locs.new <- data.frame(new.r = as.numeric(),
                                       new.c = as.numeric(),
                                       delta.r = as.numeric(),
                                       delta.c = as.numeric())

                # Check what characters are in these locations
                for(new.loc in 1:nrow(locs)){
                    r <- locs[new.loc, 1]
                    c <- locs[new.loc, 2]
                    delta.r <- locs[new.loc, 3]
                    delta.c <- locs[new.loc, 4]

                    if(puzzle[r, c] == char){
                        locs.new <- rbind(locs.new, cbind(r, c, delta.r, delta.c))
                    }
                }

                # Save new locations
                coords.new <- rbind(coords.new, locs.new)
                coords.new <- distinct(coords.new)
            }

            # Now that we know where the second character occurs, we also know the direction we need to check if the word continues
            # First safe the original coord (calculate the delta's backward from the second location)
            coords.new <- coords.new %>% mutate(r.start = r - delta.r, c.start = c - delta.c) 

            # Loop to check the 3rd character and forwards until end of word
            for(n in 3:nchar(i)){
                char <- strsplit(i, "")[[1]][[n]]

                # Calculate next location
                coords.new <- coords.new %>% mutate(r = r + delta.r, c = c + delta.c, chr = NA) %>%
                    filter(r >= 1 & r <= nrow(puzzle) & c >= 1 & c <= ncol(puzzle))

                # Determine with loop what the character of each new location is
                for(new.loc in 1:nrow(coords.new)){
                    r <- coords.new[new.loc, 1]
                    c <- coords.new[new.loc, 2]

                    coords.new[new.loc, "chr"] <- puzzle[r, c]
                }

                # Keep only locations where next location has the correct character
                coords.new <- coords.new %>% filter(chr == char)

                # If there is only 1 row left, we know where the word_list starts, so we can skip any further loop iterations
                if(nrow(coords.new) == 1){
                    # Check length word
                    max <- nchar(i)

                    # Calculate end coordinates (max - 1 because r.start is the first character already)
                    coords.new <- coords.new %>% mutate(r.end = r.start + (max - 1) * delta.r,
                                                        c.end = c.start + (max - 1) * delta.c)

                    # Calculate all coordinates
                    r <- coords.new[["r.start"]]:coords.new[["r.end"]]
                    c <- coords.new[["c.start"]]:coords.new[["c.end"]]

                    # Save in dataframe
                    final.coords <- data.frame(r = r,
                                               c = c,
                                               chr = NA)

                    # Set boxes in solved puzzle to empty
                    for(x in 1:nrow(final.coords)){
                        r <- final.coords[x, 1]
                        c <- final.coords[x, 2]

                        puzzle.solved[r, c] <- "."

                        # For any interim checks, here the corresponding letters are also added, but this step is not necessary
                        final.coords[x, "chr"] <- puzzle[r, c]
                    }

                    next
                }
            }
        }

        solution <- gsub("\\.", "", paste0(t(puzzle.solved), collapse = ""))

        # Create solved table for output
        output$puzzle.sol <- renderTable({
            puzzle.solved
        },
        colnames = FALSE)
        
        # Create solved text for output
        output$solution <- renderText({solution})
    })
}

shinyApp(ui, server)
