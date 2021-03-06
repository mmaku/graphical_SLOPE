# Written by Micha� Makowski

# install.packages("glasso")
# install.packages("huge")

require(glasso)
require(huge)
require(tictoc)

source("measures.R")

createSimulationMatrix <- function(nVec = 150, 
                                   pVec = 200, 
                                   graphTypeVec = "cluster",
                                   alphaVec = 0.05,
                                   penalizeDiagonalVec = FALSE, 
                                   iterationsVec = 1000)
{
    output <- expand.grid(nVec, pVec, graphTypeVec, alphaVec, penalizeDiagonalVec, iterationsVec,
                          KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
    colnames(output) <- c("n", "p", "graphType", "alpha", "penalizeDiagonal", "iterations")
    
    return(output)
}

simulations <- function(simulationMatrix, 
                        graphParameters = NULL, 
                        additionalMethods = NULL, 
                        verbose = TRUE,
                        saveEach = FALSE,
                        saveAll = FALSE,
                        fileName = "")
{
    tic("All")
    ticFile <- paste0("./!02 Data/01 Binded/tic", fileName, ".txt")
    
    specificDoCall <- function(x) 
        doCall("measures", 
               graphParameters = graphParameters, additionalMethods = additionalMethods, verbose = FALSE, 
               args = x)
    
    if(verbose) 
    {
        cat("Starting simulations\nnumber of setups = ", NROW(simulationMatrix), 
            "\nnumber of simulations = ", sum(simulationMatrix$iterations), ".\n")
        
        progressBar <- txtProgressBar(min = 0, max = sum(simulationMatrix$iterations), style = 3)
        setTxtProgressBar(progressBar, 0)
    }
    if(saveAll)
    {
        filenameAll <- paste0("AllSimulations", fileName, "@", format(Sys.time(), '%y_%m_%d@%H_%M'), "#",
                              NROW(simulationMatrix)*(3+NROW(additionalMethods)))
    }
    
    output <- list()
    
    for(r in seq_len(NROW(simulationMatrix))) 
    {
        ticName <- paste(simulationMatrix[r,], collapse = '_')
        tic(ticName)
        
        simResults <- specificDoCall(simulationMatrix[r,])
        output[[r]] <- cbind(simResults, simulationMatrix[r,], row.names = NULL)
        
        if(saveEach)
        {
            filename <- paste0("OneSimulation_", 
                               # format(Sys.time(), '%y_%m_%d_%H_%M'), 
                               paste(simulationMatrix[r,], collapse = '_'))
            
            setup <- simulationMatrix[r,]
            
            save(simResults, setup, additionalMethods, graphParameters, 
                 file = paste0("./!02 Data/", filename, ".RData"))
        }
        if(saveAll)
        {
            tempOutput <- do.call("rbind", output)
            save(tempOutput, additionalMethods, graphParameters, 
                 file = paste0("./!02 Data/01 Binded/", filenameAll, ".RData"))
        }
        
        if(verbose)
            setTxtProgressBar(progressBar, sum(simulationMatrix$iterations[1:r]))
        
        toc(quiet = TRUE, log = TRUE)
        write(tic.log()[[1]], file = ticFile, append = TRUE)
        tic.clearlog()
    }
    
    if(verbose)
        close(progressBar)
    
    output <- do.call("rbind", output)
    
    if(saveAll)
    {
        save(output, additionalMethods, graphParameters, 
             file = paste0("./!02 Data/01 Binded/", filenameAll, ".RData"))
    }
    
    toc(quiet = TRUE, log = TRUE)
    write(tic.log()[[1]], file = ticFile, append = TRUE)
    tic.clearlog()
    
    return(output)
}
