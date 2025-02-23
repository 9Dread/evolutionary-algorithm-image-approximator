# evolutionary-algorithm-image-approximator
Evolutionary Algorithm (Each frame is the best-fit individual in a population)    |  Targeted Image ([Ghost and Soap from COD MW2](https://en.wikipedia.org/wiki/Call_of_Duty:_Modern_Warfare_2#Remastered_version))
:-------------------------:|:-------------------------:
<img src="https://github.com/9Dread/evolutionary-algorithm-image-approximator/blob/main/gifs/ghostsoap.gif" alt="Evolutionary algorithm gif" style="width:50%; height:auto;">  |  <img src="https://github.com/9Dread/evolutionary-algorithm-image-approximator/blob/main/ghostsoap.jpg" alt="Original image" style="width:50%; height:auto;">

This is a fun, if fairly useless, implementation of an evolutionary algorithm that initializes a population of random rgb images and aims to converge to the provided image. It also provides frames that can be used to produce an animation to visualize the convergence of the algorithm as shown above. I got the idea from the [wikipedia page on evolutionary computation](https://en.wikipedia.org/wiki/Evolutionary_computation), which implements something similar for a greyscale image of Charles Darwin:
![Charles Darwin Gif](https://upload.wikimedia.org/wikipedia/commons/f/fb/Darwin_image_evolution_from_random_patches.gif)

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

All implemented functions are located in [functions.R](https://github.com/9Dread/evolutionary-algorithm-image-approximator/tree/main/functions.R). The main interface is [main.R](https://github.com/9Dread/evolutionary-algorithm-image-approximator/tree/main/main.R). Put simply, one provides a target image and runs the algorithm on it using the functions (the example shown at the top of this page is provided in main.R). Note that the resolution of the original image often must be drastically reduced because of computational costs. For instance, the image used in the example is 70 x 59 pixels. The resolution can be adjusted with the "resize" parameter of the readImage function. 

The design specifications behind the evolutionary algorithm are as follows:

### Solution Space and Initializing a Population
The algorithm is provided an array of dimension x * y * 3, since we have a 2d image (x * y) with each pixel assigned an r, g, and b value. Thus the space to be searched is the set of all possible rgb values for an image of size x * y. The user specifies a `pop_size` parameter that specifies how big the population should be. Each individual in the population is an image. When the algorithm first starts, it initializes the population of `pop_size` images by uniformly sampling a random value for the array of size x * y * 3. That is, for each pixel, it randomly samples an r, g, and b value.

### Fitness Function
The fitness function is designed to reach an optimum when the proposed image and the reference (user-provided) image are exactly alike. There are many ways to do this, but this implementation uses the sum of the pixel-wise euclidean distances between the proposed and reference image. 

Note that each pixel is a 3d vector/point in rgb space. Thus we can quantify how similar each pixel is to its respective pixel in the reference image using the euclidean distance function. The pixel-wise distance is:\
$$d_{ij} = \sqrt{\left( r_{ij} - r^0_{ij} \right)^2 + \left( g^0_{ij} - g_0 \right)^2 + \left( b - b^0_{ij} \right)^2}$$
where $r_{ij}$, $g_{ij}$, $b_{ij}$ are the respective r, g, and b values of the pixel at position $i,j$ in the proposed image and $r^0_{ij}$, $g^0_{ij}$, $b^0_{ij}$ are the r, g, and b values of the matching pixel in the reference image. As the rgb values of the pixel between the proposed and reference image get closer, this distance decreases. The fitness function is the sum of this distance over all pixels, i.e.\
$$\text{fit}=\sum_{i}^x \sum_{j}^y d_{ij}$$

One small caveat is that the algorithm implemented here was designed to *maximize* the fitness value, not *minimize* it. Note that as it stands, this fitness function becomes smaller as the images become closer together (the distance will decrease for more similar images). Thus the algorithm implemented will rewards individuals for being further from the desired image. To fix this, the fitness function is simply multiplied by $-1$:\
$$\text{fit}=-\sum_{i}^x \sum_{j}^y d_{ij}$$

### Mutation

### Crossover

### Lamarckian Memetic Algorithm

### Saving Animation Frames
