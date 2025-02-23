genRandomRGB <- function(n_x, n_y) {
  #Generate random rgb array of dimension n_x by n_y (basically generate random image)
  vec <- vector(mode="double", length = n_x * n_y * 3)
  for (i in seq_along(vec)) {
    vec[i] <- runif(1, 0, 1)
  }
  out <- array(vec, c(n_x, n_y, 3))
  rm(vec)
  return(out)
}

initPopulation <- function(n, dim_x, dim_y) {
  #initialize a population of n images; n must be even
  #we want to maintain fitness values with each image so we can sort them
  out <- list()
  for (i in seq_len(n)) {
    img <- genRandomRGB(dim_x, dim_y)
    out <- append(out, list(list(data = img, fit = fitness(img, ref))))
  }
  return(out)
}

sortPopulation <- function(pop) {
  n <- length(pop)
  current_list <- c()
  for (i in seq_len(n)) {
    current_list[i] <- pop[[i]]$fit
  }
  pop <- pop[order(current_list, decreasing = TRUE)]
  return(pop)
}

gaussMutate <- function(img, m_rate, sigma, pixel_wise) {
  #pixel-wise mutation means that we decide to mutate by pixels, not by specific rgb values.
  #That is, we iterate through each pixel and decide whether or not to mutate it; if
  #we do, then we mutate all three (rgb) values.
  #If pixel_wise is false, then we iterate through each rgb value to decide whether to
  #mutate; this is more expensive, but somewhat better in later iterations.
  
  #Also prevent values from going out of limits (0,1)
  if(pixel_wise) {
    for (i in seq_len(dim(img)[1])) {
      for(j in seq_len(dim(img)[2])) {
        #if mutate procs, mutate r, g, and b
        if(runif(1,0,1) < m_rate) {
          img[i, j, 1] <- img[i, j, 1] + rnorm(1, 0, sigma)
          if(img[i, j, 1] > 1) {img[i, j, 1] <- 1}
          if(img[i, j, 1] < 0) {img[i, j, 1] <- 0}
          
          img[i, j, 2] <- img[i, j, 1] + rnorm(1, 0, sigma)
          if(img[i, j, 2] > 1) {img[i, j, 2] <- 1}
          if(img[i, j, 2] < 0) {img[i, j, 2] <- 0}
          
          img[i, j, 3] <- img[i, j, 1] + rnorm(1, 0, sigma)
          if(img[i, j, 3] > 1) {img[i, j, 3] <- 1}
          if(img[i, j, 3] < 0) {img[i, j, 3] <- 0}
          
        }
      }
    }
  } else {
    for (i in seq_len(dim(img)[1])) {
      for(j in seq_len(dim(img)[2])) {
        for(k in 1:3) {
          #if mutate procs according to mutate rate, mutate the pixel's respective r, g, or b value
          if(runif(1,0,1) < m_rate) {
            img[i, j, k] <- img[i, j, k] + rnorm(1, 0, sigma)
            if(img[i, j, k] > 1) {img[i, j, k] <- 1}
            if(img[i, j, k] < 0) {img[i, j, k] <- 0}
          }
        }
      }
    }
  }
  return(img)
}

#fitness <- function(img, ref) {
  #the input image must be of same dimension as the reference image
  #compute the abs difference between each pixel's rgb values and subtract from a reference value
  #the reference value is dim_x * dim_y * 3
  #the most extreme case is an all-white and all-black image; fitness is 0 in this case
  #But if the images are close together, the fitness is closer to dimx * dimy * 3
  #Divide by ref val to normalize
#  ref_val <- dim(img)[1] * dim(img)[2] * 3
#  for(i in seq_len(dim(img)[1])) {
#    for(j in seq_len(dim(img)[2])) {
#      for(k in 1:3) {
#        ref_val <- ref_val - abs(img[i,j,k] - ref[i, j, k])
#      }
#    }
#  }
#  return(ref_val/(dim(img)[1] * dim(img)[2] * 3))
#}

fitness <- function(img, ref) {
  #test fitness fxn
  #minimize sum of pixelwise euclidean distances
  totalDist <- 0
  for(i in seq_len(dim(img)[1])) {
    for(j in seq_len(dim(img)[2])) {
      totalDist <- totalDist + pixelDistance(img, ref, i, j)
    }
  }
  #negative cuz yeah
  return(-totalDist)
}
pixelDistance <- function(img, ref, i, j) {
  #euclidean distance between the pixel vectors
  return(sqrt((img[i,j,1]-ref[i,j,1])^2 + (img[i,j,2]-ref[i,j,2])^2 + (img[i,j,3]-ref[i,j,3])^2))
}
crossover <- function(parent, spouse, cross_rate = 0.5) {
  #given a main parent image and a spouse image, create a child image by swapping the
  #parent image's pixels with the spouse image's pixels at rate (default 0.5)
  for(i in seq_len(dim(parent)[1])) {
    for(j in seq_len(dim(parent)[2])) {
      if(runif(1,0,1) < cross_rate) {
        parent[i, j, 1] <- spouse[i, j, 1]
        parent[i, j, 2] <- spouse[i, j, 2]
        parent[i, j, 3] <- spouse[i, j, 3]
      }
    }
  }
  return(parent)
}


createChild <- function(parent, ref, pixel_wise, do_mutate, do_crossover, sigma, m_rate, cross_rate, spouse = NULL) {
  #Create child with either mutate, crossover, or both
  #Do mutate after crossover
  #also add fitness to the new child
  if(do_crossover) {
    parent <- crossover(parent, spouse, cross_rate)
  }
  if(do_mutate) {
    parent <- gaussMutate(parent, sigma, m_rate, pixel_wise)
  }
  #calculate fitness and return list of new child and its fitness
  return(list(data=parent, fit=fitness(parent, ref)))
}

#selectImage <- function(pop) {
  #given a group of images, select one randomly but weighted by fitness
  #return id of the image
#  fits <- c()
#  for (i in seq_len(length(pop))) {
#    fits[i] <- pop[[i]]$fit
#  }
#  prob_vec <- fits/sum(fits)
#  return(sample(seq_len(length(pop)), 1, prob=prob_vec))
#}
selectImage <- function(pop) {
#given a group of images, select one randomly
#return id of the image
  return(sample(seq_len(length(pop)), 1))
}

lamarckLearn <- function(ref, img, lamarck_iters, lamarck_sigma) {
  #given an image, iterate lamarck_iters times:
  #pick a pixel r/g/b value at random. try to mutate it. if it improves fitness, keep the change;
  #otherwise, unlearn it.
  
  #dont use entire fitness function to evaluate fitness; thats expensive. instead evaluate the pre- and post-mutation
  #distances between the specific r/g/b val on the specific pixel between the current and reference image
  dim_x <- dim(img)[1]
  dim_y <- dim(img)[2]
  for(a in seq_len(lamarck_iters)) {
    xval <- sample(seq_len(dim_x), 1)
    yval <- sample(seq_len(dim_y), 1)
    zval <- sample(c(1,2,3), 1)
    new_img <- singleMutate(img, xval, yval, zval, lamarck_sigma)
    #if abs rgb distance is smaller for the new img, replace old img
    if(singleFitness(img, ref, xval, yval, zval) >= singleFitness(new_img, ref, xval, yval, zval)) {
      img <- new_img
    }
  }
  return(list(data = img, fit = fitness(img, ref)))
}
singleMutate <- function(img, x, y, z, lamarck_sigma) {
  #single-pixel mutation function for lamarckLearn
  out <- img
  out[x,y,z] <- out[x,y,z] + rnorm(1, 0, lamarck_sigma)
  if(out[x,y,z] <= 0) {out[x,y,z] <- 0}
  if(out[x,y,z] >= 1) {out[x,y,z] <- 1}
  
  return(out)
}
singleFitness <- function(img, ref, x, y, z) {
  #distance between individual pixels
  return(abs(img[x,y,z] - ref[x,y,z]))
}

iterate <- function(ref, pop, pop_size, n_retain, iteration, pixel_wise, do_mutate, do_crossover, m_rate, sigma, cross_rate) {
  #one iteration: sort population by fitness, save image of best fit individual, drop bottom half of population, 
  #create children from top half, return new population
  
  #sort the input population by fitness
  population <- sortPopulation(pop)
  
  #save image every 10 populations
  if(iteration %% 10 == 0) {
    fig <- ggdraw() +
      draw_image(as.raster(population[[1]]$data))
    ggsave(paste0("frames/pop_", iteration, ".jpg"), plot=fig)
  }
  
  #drop children
  population <- population[c(1:n_retain)]
  
  #list of new images
  new_pops <- list()
  
  #create new children to maintain pop size
  for(i in seq_len(pop_size - n_retain)) {
    #select parent weighted relatively by fitness
    parent_id <- selectImage(population)
    parent <- population[[parent_id]]$data
    spouse <- NULL
    #if crossover, select spouse from the remaining pop weighted relatively by fitness
    #if spouse id is same, sample a new one
    #maybe another way to deal with it is just don't do crossover if identical parents
    #but idk that might be bad for low pop sizes
    if(do_crossover){
      spouse_id <- selectImage(population)
      while(parent_id == spouse_id){spouse_id <- selectImage(population)}
      spouse <- population[[spouse_id]]$data
    }
    
    #create new child and append them to the new pops list
    child <- createChild(parent, ref, pixel_wise, do_mutate, do_crossover, sigma, m_rate, cross_rate, spouse)
    new_pops <- append(new_pops, list(child))
  }
  out <- append(population, new_pops)
  return(out)
}


iteratePar <- function(ref, pop, pop_size, n_retain, iteration, pixel_wise, do_mutate, do_crossover, m_rate, sigma, cross_rate, lamarck_iters, lamarck_sigma) {
  #parallel ver of iterate
  #one iteration: save image of best fit individual, drop bottom half of population, 
  #create children from top half, return new population
  
  #save image every 20 populations for first 240 iterations; then every 40 until 1000; then every 40
  if(iteration <= 260) {
    if(iteration %% 20 == 0) {
      fig <- ggdraw() +
        draw_image(as.raster(pop[[1]]$data))
      ggsave(paste0("frames/pop_", iteration, ".jpg"), plot=fig)
      plot_crop(paste0("frames/pop_", iteration, ".jpg"))
    }
  } else if(iteration <= 1000) {
    if(iteration %% 40 == 0) {
      fig <- ggdraw() +
        draw_image(as.raster(pop[[1]]$data))
      ggsave(paste0("frames/pop_", iteration, ".jpg"), plot=fig)
      plot_crop(paste0("frames/pop_", iteration, ".jpg"))
    }
  } else {
    if(iteration %% 60 == 0) {
      fig <- ggdraw() +
        draw_image(as.raster(pop[[1]]$data))
      ggsave(paste0("frames/pop_", iteration, ".jpg"), plot=fig)
      plot_crop(paste0("frames/pop_", iteration, ".jpg"))
    }
  }
  
  
  #drop children
  pop <- pop[c(1:n_retain)]
  
  #memetic algorithm (lamarckian learning) in parallel
  pop <- foreach(i = seq_len(n_retain)) %dopar% {
     lamarckLearn(ref, pop[[i]]$data, lamarck_iters, lamarck_sigma)
  }
  
  #create new children to maintain pop size
  #generate parent and spouse ids first
  id_list <- list()
  for(i in seq_len(pop_size - n_retain)) {
    parent_id <- selectImage(pop)
    spouse_id <- NULL
    if(do_crossover) {
      spouse_id <- selectImage(pop)
      while(parent_id == spouse_id){spouse_id <- selectImage(pop)}
    }
    id_list <- append(id_list, list(list(par = parent_id, spou = spouse_id)))
  }
  new_pops <- foreach(i = seq_len(pop_size-n_retain)) %dopar% {
    createChild(parent=pop[[id_list[[i]]$par]]$data, ref=ref, pixel_wise=pixel_wise, do_mutate=do_mutate, do_crossover=do_crossover, m_rate=m_rate, sigma=sigma, cross_rate=cross_rate, spouse=pop[[id_list[[i]]$spou[1]]]$data)
  }
  out <- append(pop, new_pops)
  return(out)
}



evol_img_approx <- function(ref, pop_size, n_retain, n_iterations, pixel_wise = TRUE, do_mutate = TRUE, do_crossover = TRUE, m_rate = 0.1, sigma = 0.01, cross_rate = 0.1, lamarck_iters = 50, lamarck_sigma = 0.01) {
  #function call: take ref, do_mutate, do_crossover, m_rate, sigma, cross_rate, pop_size, n_iterations
  #make dim_x and dim_y
  #init population
  #run n_iterations iterations
  #make gif
  
  dim_x <- dim(ref)[1]
  dim_y <- dim(ref)[2]
  pop <- initPopulation(pop_size, dim_x, dim_y)
  pop <- sortPopulation(pop)
  fig <- ggdraw() +
    draw_image(as.raster(pop[[1]]$data))
  ggsave(paste0("frames/pop_", 1, ".jpg"), plot=fig)
  plot_crop(paste0("frames/pop_", 1, ".jpg"))
  for(iter in seq_len(n_iterations)) {
    pop <- iteratePar(ref, pop, pop_size, n_retain, iter, pixel_wise, do_mutate, do_crossover, m_rate, sigma, cross_rate, lamarck_iters, lamarck_sigma)
    #sort the input population by fitness
    pop <- sortPopulation(pop)
    print(paste0("iteration ", iter, " complete; best fitness = ", pop[[1]]$fit, "; ", n_retain+1, " individual's fitness = ", pop[[n_retain+1]]$fit))
  }
  pop <- sortPopulation(pop)
  fig <- ggdraw() +
    draw_image(as.raster(pop[[1]]$data))
  ggsave(paste0("frames/pop_", n_iterations+1, ".jpg"), plot=fig)
  plot_crop(paste0("frames/pop_", n_iterations+1, ".jpg"))
  return(pop)
}

continue_iters <- function(ref, pop, pop_size, n_retain, n_iterations, iters_done, pixel_wise = TRUE, do_mutate = TRUE, do_crossover = TRUE, m_rate = 0.1, sigma = 0.01, cross_rate = 0.1, lamarck_iters = 50, lamarck_sigma = 0.01) {
  #For continuing iterations from an already-initialized pop; iters_done is number of iterations
  #taken to produce the input pop (mostly for counting purposes and correctly saving frames)
  #pop is the population object
  #you can also adjust the pop size if u want
  
  dim_x <- dim(ref)[1]
  dim_y <- dim(ref)[2]
  for(iter in seq_len(n_iterations)) {
    pop <- iteratePar(ref, pop, pop_size, n_retain, iter+iters_done, pixel_wise = TRUE, do_mutate, do_crossover, m_rate, sigma, cross_rate, lamarck_iters, lamarck_sigma)
    pop <- sortPopulation(pop)
    print(paste0("iteration ", iter+iters_done, " complete; best fitness = ", pop[[1]]$fit, "; ", n_retain+1, " individual's fitness = ", pop[[n_retain+1]]$fit))
  }
  pop <- sortPopulation(pop)
  fig <- ggdraw() +
    draw_image(as.raster(pop[[1]]$data))
  ggsave(paste0("frames/pop_", iters_done+n_iterations+1, ".jpg"), plot=fig)
  plot_crop(paste0("frames/pop_", iters_done+n_iterations+1, ".jpg"))
  return(pop)
}

