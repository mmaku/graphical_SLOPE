# Written by Micha� Makowski

# setwd("C:/Users/Martyna Strauchmann/Dropbox/04 Praca magisterska/gSLOPEtesting")

# library(doSNOW)
# library(foreach) 
library(dplyr)
source("fastSimulationsFunctions.R")

# Cluster structure 
clusters <- createSimulationMatrix(nVec = c(50, 100, 200, 400),
                                   pVec = 100, 
                                   graphTypeVec = c("cluster"),
                                   alphaVec = c(0.05, 0.2), 
                                   scaledVec = TRUE, 
                                   iterationsVec = 3000)

graphStructure_large_75 <- list(v = 0.7,
                                u = 0.3,
                                g = 10,
                                prob = 0.75)

results <- simulations(clusters,
                       saveAll = TRUE,
                       testLocalFDR = TRUE,
                       graphParameters = graphStructure_large_75,
                       fileName = "_Cl_scaled_FDR_Prob_TRES_07_0.75")

# cl<-makeCluster(4) #your number of CPU cores
# registerDoSNOW(cl)
# 
# doparList <-list(list(clusters[1:2,], graphStructure_large_75), 
#                  list(clusters[3:4,], graphStructure_large_75), 
#                  list(clusters[5:6,], graphStructure_large_75), 
#                  list(clusters[7:8,], graphStructure_large_75))
# results <- list() 
# results <- foreach(i = doparList) %dopar% {
#     source("fastSimulationsFunctions.R")
#     simulations(i[[1]],
#                 saveAll = TRUE,
#                 testLocalFDR = TRUE,
#                 graphParameters = i[[2]],
#                 fileName = paste0("_Cl_scaled_FDR_Prob_BIS_",i[[1]]$alpha,"_",i[[1]]$n))
# }
# 
# stopCluster(cl)

for(r in 1:length(results))
{
    graphParameters <- doparList[[r]][[2]]

    names(graphParameters) <- do.call(paste0, (expand.grid("graph.", names(graphParameters))))

    graphDF = data.frame(graphParameters)
    
    results[[r]] %>%
        merge(graphDF) -> results[[r]]
}


finalResults <- bind_rows(results)
filenameAll <- paste0("AllOneSimulations_Cl_both_FDR_Prob_BIS@", format(Sys.time(), '%y_%m_%d_%H_%M'), "#",nrow(finalResults))

save(finalResults, graphParameters,
     file = paste0("./!02 Data/01 Binded/", filenameAll, ".RData"))


