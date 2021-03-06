# Written by Micha� Makowski

setwd("C:/Users/Martyna Strauchmann/Dropbox/04 Praca magisterska/gSLOPEtesting")

library(doSNOW)
library(foreach)
library(dplyr)
source("fastSimulationsFunctions.R")

# Cluster structure 
iters40960 <- createSimulationMatrix(nVec = 100, 
                                    pVec = 100, 
                                    graphTypeVec = "cluster",
                                    alphaVec = 0.05,
                                    penalizeDiagonalVec = FALSE, 
                                    iterationsVec = 40960)

iters20480 <- createSimulationMatrix(nVec = 100, 
                                    pVec = 100, 
                                    graphTypeVec = "cluster",
                                    alphaVec = 0.05,
                                    penalizeDiagonalVec = FALSE, 
                                    iterationsVec = c(10,20,40,80,160,320,640,1280,2560, 5120, 10240, 20480))

graphStructure_02_08 <- list(v = 0.3,
                             u = 0.7,
                             g = 10,
                             prob = 0.5)
graphStructure_08_02 <- list(v = 0.7,
                             u = 0.3,
                             g = 10,
                             prob = 1)


cl<-makeCluster(2) #your number of CPU cores
registerDoSNOW(cl)

doparList <-list(list(iters20480, graphStructure_02_08, "_Iter20480_"), 
                 list(iters20480, graphStructure_08_02, "_Iter20480_"), 
                 list(iters40960, graphStructure_02_08, "_Iter40960_"), 
                 list(iters40960, graphStructure_08_02, "_Iter40960_"))
                 
results <- list() 
results <- foreach(i = doparList) %dopar% {
    source("simulationsFunctions.R")
    simulations(i[[1]],
                saveAll = TRUE,
                graphParameters = i[[2]],
                testLocalFDR = FALSE, 
                fileName = paste0(i[[3]], i[[2]]$v,"_",i[[2]]$u))
}

stopCluster(cl)

for(r in 1:length(results))
{
    graphParameters <- doparList[[r]][[2]]

    names(graphParameters) <- do.call(paste0, (expand.grid("graph.", names(graphParameters))))

    graphDF = data.frame(graphParameters)
    
    results[[r]] %>%
        merge(graphDF) -> results[[r]]
}


finalResults <- bind_rows(results)
filenameAll <- paste0("AllOneSimulations_Iter@", format(Sys.time(), '%y_%m_%d_%H_%M'), "#",nrow(finalResults))

save(finalResults, graphParameters,
     file = paste0("./!02 Data/01 Binded/", filenameAll, ".RData"))


