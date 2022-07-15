### Solve word searcher
### Roemer J. Janse - 14/07/2022
pacman::p_load("dplyr", "tidyverse", "shiny")

### Load word searcher
# Number of columns
ncols <- 8

# Text of puzzle
puzzle <- strsplit("SPREEUWKSNAGLYNHSUMGNIRPTUUFVEUGGENDMTUSFIUDTUOHOOIEVAARGDREZIUB", split = "")
puzzle <- t(matrix(puzzle[[1]], nrow = ncols)) # ncols is supplied to nrow because transpose 't()' is used

# Words to be found
terms <- c("BUIZERD", "FUUT", "GOUDVINK", "HOUTDUIF", "NYLGANS", "OOIEVAAR", "PUTTER", "RINGMUS", "SPREEUW")

puzzle.solved <- puzzle

# Select word
for(i in terms){
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
        
        # If there is only 1 row left, we know where the words starts, so we can skip any further loop iterations
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
                