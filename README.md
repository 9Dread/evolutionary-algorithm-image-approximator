# evolutionary-algorithm-image-approximator
Evolutionary Algorithm     |  Targeted Image
:-------------------------:|:-------------------------:
<img src="https://github.com/9Dread/evolutionary-algorithm-image-approximator/blob/main/gifs/ghostsoap.gif" alt="Evolutionary algorithm gif" style="width:50%; height:auto;">  |  <img src="https://github.com/9Dread/evolutionary-algorithm-image-approximator/blob/main/ghostsoap.jpg" alt="Original image" style="width:50%; height:auto;">

[Evolutionary algorithms (EAs)](https://en.wikipedia.org/wiki/Evolutionary_algorithm) are metaheuristic algorithms that mimic biological evolution to come up with an approximately-optimal solution to a difficult problem. To start, one must initialize a perhaps-random "population" of individual solutions to the problem. Then, one must design a "fitness function" or at least have some way of ranking the solutions according to how well they solve the problem. There are many kinds of EAs, and they are usually designed around specific problems, but to work from the initial population towards a better solution, they all generally loop through these steps:
* Sort the population in order of fitness
* Impose "natural selection" e.g. drop x number of the worst-fit individuals
* Breed x amount of new individuals from the remaining individuals in the population (here is where there is a lot of variation in methods)
  * <ins>Crossover</ins> is a mechanism that combines characteristics (i.e. "genes") from two parent individuals
  * <ins>Mutation</ins> is a mechanism that adds some random change to a child after it is born
* Calculate fitness for the new individuals
* Repeat
