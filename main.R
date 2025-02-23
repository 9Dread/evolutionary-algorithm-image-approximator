library(magick)
library(tidyverse)
library(cowplot)
library(recolorize)
library(foreach)
library(doParallel)
library(knitr) #for image cropping

theme_set(theme_cowplot())
#path <- "PATH TO IMAGE"
path <- "ghostsoap.jpg"
ref <- readImage(path, resize=0.07)

#load functions
source("functions.R")

#Parallel cluster (10 cores; adjust if needed)
cl <- makeCluster(10)
clusterExport(cl, c("createChild", "gaussMutate", "crossover", "fitness", "pixelDistance", "lamarckLearn", "singleMutate", "singleFitness"))
registerDoParallel(cl)

#start algorithm!
result <- evol_img_approx(ref, 200, 50, n_iterations = 5000, pixel_wise = FALSE, m_rate = 0.05, sigma = 0.005, cross_rate = 0.05, lamarck_iters = 200)
ggdraw() +
  draw_image(as.raster(result[[1]]$data))
#the diff in fitness vals between best and 1st non-retained individual are lower in low pop count; less diverse pop

#can be used to continue iterating from a population object (NOT run for the sample example, the below line is provided as a simple example)
result2 <- evol_img_approx(ref, result, 200, 50, n_iterations = 5000, iters_done=5000, pixel_wise = FALSE, m_rate = 0.05, sigma = 0.005, cross_rate = 0.05, lamarck_iters = 200)


#can combine images to make a gif, but pretty computationally expensive
#imgs <- list.files("frames", full.names = TRUE)
#img_list <- lapply(imgs, image_read)
#img_joined <- image_join(img_list)
#animation <- image_animate(img_joined, fps=4)
#image_write(image = animation, path = "gifs/animation.gif")
