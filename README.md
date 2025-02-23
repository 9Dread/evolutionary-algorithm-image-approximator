# evolutionary-algorithm-image-approximator
Evolutionary Algorithm (Each frame is the best-fit individual in the population after waiting some number of iterations)    |  Targeted Image ([Ghost and Soap from COD MW2](https://en.wikipedia.org/wiki/Call_of_Duty:_Modern_Warfare_2#Remastered_version))
:-------------------------:|:-------------------------:
<img src="https://github.com/9Dread/evolutionary-algorithm-image-approximator/blob/main/gifs/ghostsoap.gif" alt="Evolutionary algorithm gif" style="width:50%; height:auto;">  |  <img src="https://github.com/9Dread/evolutionary-algorithm-image-approximator/blob/main/ghostsoap.jpg" alt="Original image" style="width:50%; height:auto;">

This is a fun, if fairly useless, implementation of an evolutionary algorithm that initializes a population of random rgb images and aims to converge to the provided image. It also provides frames that can be used to produce an animation to visualize the convergence of the algorithm as shown above. I got the idea from the [wikipedia page on evolutionary computation](https://en.wikipedia.org/wiki/Evolutionary_computation), which shows a gif that implements something similar for a greyscale image of Charles Darwin.

## Background

[Evolutionary algorithms (EAs)](https://en.wikipedia.org/wiki/Evolutionary_algorithm) are metaheuristic algorithms that mimic biological evolution to come up with an approximately-optimal solution to a difficult problem. They are particularly effective when the solution space is large, but the set of satisfactory solutions is small (i.e. they are good at finding sparse optimal solutions in large search spaces). To start, one must initialize a perhaps-random "population" of individual solutions to the problem. Then, one must design a "fitness function" or at least have some way of ranking the solutions according to how well they solve the problem. There are many kinds of EAs, and they are usually designed around specific problems, but to work from the initial population towards a better solution, they all generally loop through these steps:
* Sort the population in order of fitness
* Impose "natural selection" e.g. drop x number of the worst-fit individuals
* Breed x amount of new individuals from the remaining individuals in the population (here is where there is a lot of variation in methods)
  * <ins>Crossover</ins> is a mechanism that combines characteristics (i.e. "genes") from two parent individuals
  * <ins>Mutation</ins> is a mechanism that adds some random change to a child after it is born
  * (Crossover and mutation are often implemented together, but the way they are implemented and conceptualized varies widely across applications)
* Calculate fitness for the new individuals
* Repeat

The way this converges to a better solution is fairly intuitive. We start with a random population, drop the worst individuals, randomly breed new individuals by combining the characteristics of the current best individuals (and hope they are better than their parents), and keep looping until we are satisfied.

[Memetic algorithms (MAs)](https://en.wikipedia.org/wiki/Memetic_algorithm) extend EAs by adding some local optimization method in each iteration (or consistently after some variable number of iterations). The idea is to speed up the convergence of the EA by having some individuals in the population go under some local learning process. <ins>Lamarckian</ins> learning allows these individuals to pass on these learned characteristics, while <ins>Baldwinian</ins> learning keeps the genes unchanged but allows the learning to affect the fitness value.

## Implementation and Usage

All implemented functions are located in [functions.R](https://github.com/9Dread/evolutionary-algorithm-image-approximator/tree/main/functions.R). The main interface is [main.R](https://github.com/9Dread/evolutionary-algorithm-image-approximator/tree/main/main.R). Put simply, one provides a target image and runs the algorithm on it using the functions (the example shown at the top of this page is provided in main.R). Note that the resolution of the original image often must be drastically reduced because of computational costs. For instance, the image used in the example is 70 x 59 pixels after resolution reduction. The resolution can be adjusted with the "resize" parameter of the readImage function. 

The design specifications behind the evolutionary algorithm are as follows:

### Solution Space and Initializing a Population
The algorithm is provided an array of dimension x * y * 3, since we have a 2d image (x * y) with each pixel assigned an r, g, and b value. Thus the space to be searched is the set of all possible rgb values for an image of size x * y. The user specifies a `pop_size` parameter that specifies how big the population should be. Each individual in the population is an image. When the algorithm first starts, it initializes the population of `pop_size` images by uniformly sampling a random value for the array of size x * y * 3. That is, for each pixel, it randomly samples an r, g, and b value.

### High-Level Description
After initializing the population, the algorithm begins the evolutionary process. The `n_retain` parameter dictates how many individuals should be retained in the population at each iteration. After the population is sorted by fitness, the algorithm retains the best `n_retain` individuals and drops the rest. Then, these remaining individuals undergo Lamarckian learning, and then children are produced using crossover *and then* mutation in that order until the population reaches `pop_size` individuals again. The fitness values are computed so that the individuals can be ranked again in the next iteration. This represents one iteration of the algorithm.

Frames for the animation are produced by rendering the best individual in the population:
* Every 20 iterations for first 240 iterations
* Then every 40 iterations until iteration 1000
* Then every 60 iterations thereafter

This is because convergence usually slows over time.

### Fitness Function
The fitness function is designed to reach an optimum when the proposed image and the reference (user-provided) image are exactly alike. There are many ways to do this, but this implementation uses the sum of the pixel-wise euclidean distances between the proposed and reference image. 

Note that each pixel is a 3d vector/point in rgb space. Thus we can quantify how similar each pixel is to its respective pixel in the reference image using the euclidean distance function. The pixel-wise distance is:\
$$d_{ij} = \sqrt{\left( r_{ij} - r^0_{ij} \right)^2 + \left( g^0_{ij} - g_0 \right)^2 + \left( b - b^0_{ij} \right)^2}$$
where $r_{ij}$, $g_{ij}$, $b_{ij}$ are the respective r, g, and b values of the pixel at position $i,j$ in the proposed image and $r^0_{ij}$, $g^0_{ij}$, $b^0_{ij}$ are the r, g, and b values of the matching pixel in the reference image. As the rgb values of the pixel between the proposed and reference image get closer, this distance decreases. The fitness function is the sum of this distance over all pixels, i.e.\
$$\text{fit}=\sum_{i}^x \sum_{j}^y d_{ij}$$

One small caveat is that the algorithm implemented here was designed to *maximize* the fitness value, not *minimize* it. Note that as it stands, this fitness function becomes smaller as the images become closer together (the distance will decrease for more similar images). Thus the algorithm implemented will rewards individuals for being further from the desired image. To fix this, the fitness function is simply multiplied by $-1$:\
$$\text{fit}=-\sum_{i}^x \sum_{j}^y d_{ij}$$

### Lamarckian Memetic Algorithm
At the start of each iteration, Lamarckian (individual) learning takes place, and this learning can then be passed on to the children of the individual images. Lamarckian learning was implemented after everything because, for some reason, the algorithm previously liked to converge to a greyscale of the provided image. This can be played around with if desired.

There are two related parameters: `lamarck_iters` and `lamarck_sigma`. The learning is an extra iterative process that takes place `lamarck_iters` times for each of the best `n_retain` individuals in the population. Essentially, in each lamarck learning iteration, a random value in the x * y * 3 array is selected. That is, a random rgb value in the image is selected. Then, this value is mutated in a similar fashion to that described in the **Mutation** section below. Basically, a random value is sampled from a gaussian with mean 0 and sigma `lamarck_sigma` and then added to the rgb value. Then, the rgb-wise distance between the current and reference image is tested. That is, we find the absolute distance between the mutated rgb value of the current image and the reference image *before* and *after* the mutation. If the rgb value is closer to the desired rgb value after the iteration, we keep the mutation; otherwise, we discard it. Note that this is equivalent to finding whether the fitness has improved, we just simply avoid calculating the entire fitness function here since that would require iterating through all pixels and is thus needlessly expensive.

The result is that each of the best `n_retain` images in the population become slightly closer to the reference image (albeit to varying degrees). The learned values are passed on to the children through crossover and mutation. This speeds up convergence by a lot.

### Crossover
Crossover aims to implement traits from two parent individuals (images). The associated parameters are `do_crossover` and `cross_rate`. The `do_crossover` parameter dictates whether or not crossover should take place, i.e. whether or not a child should have characteristics from two parents. The `cross_rate` parameter determines how extreme the resulting crossover will be.

Essentially, a random individual is selected from the best `n_retain` individuals in the population as the parent. Then, a *separate* (not identical) random individual in the remaining pool is selected as the spouse. The algorithm then iterates through each pixel in the parent's x * y image array. At each pixel, there is a `cross_rate` (decimal, not percent) chance to replace the pixel from the parent array with the corresponding pixel from the spouse's array. As a result, a child is produced that is a copy of the parent image with some of its pixels switched to that of the spouse.

### Mutation
This algorithm implements a gaussian mutation. There are four related parameters in the parent function: `do_mutate`, `pixel_wise`, `m_rate`, and `sigma`. The implementation is fairly simple. The `do_mutate` parameter dictates whether or not a child should be mutated when it is born. The `pixel_wise` parameter determines whether mutation should take place by pixel (`TRUE`) or by rgb value (`FALSE`). Generally, `FALSE` works better and is not *too* much more expensive. The `m_rate` parameter decides the rate at which a value is selected to be mutated. The `sigma` parameter is the standard deviation of the normal distribution from which the mutation is drawn.

* `pixel_wise = TRUE`: When a child is born, the algorithm iterates through each value in the x * y image array. At each value, there is a `m_rate` (decimal, not percent) chance to mutate the pixel. If we decide to mutate the pixel, for each rgb value in the pixel we draw from a normal distribution with mean 0 and sigma `sigma` and add it to the respective r, g, and b values.
* `pixel_wise = FALSE`: When a child is born, the algorithm iterates through each value in the x * y * 3 image array. At each value, there is a `m_rate` (decimal, not percent) chance to mutate the value. If we decide to mutate the value, we draw from a normal distribution with mean 0 and sigma `sigma` and add it to the respective value. This is essentially the same mechanism as `TRUE` but instead we decide whether to mutate each rgb value individually instead of the whole pixel.

### Tips
* For best performance, mutation and crossover should both be enabled, but you can disable one for fun.
* Lamarckian learning was implemented after everything because, for some reason, the algorithm previously liked to converge to a greyscale of the provided image. This can be played around with if desired.
* Generally, `pixel_wise = FALSE` works better than `TRUE` and is not *too* much more expensive.
* Note that each rgb value is provided on a scale from 0 to 1. This should help you decide the sigma values for mutations; you don't want the sigma to be too large, as it will prevent convergence. For an idea of scale simply look at the default value (or the value used in the example call).
* Gifs using image frames can be produced natively in R, but it is fairly computationally expensive. The gif produced as an example had around 100 frames at 4 fps and took a while to produce even through a virtual machine connected to a nvidia rig. One may want to find a better way to produce the gif. After the gif is produced, it will likely be large, so one may want to compress it using online compressors or other methods e.g. turning it into a video and speeding it up before turning it into a gif and compressing it.
