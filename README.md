# Projects 
## Derivative Free Optimization 
### Adaptive Sampling Trust Region Optimization-Derivative Free (ASTRO-DF) with diagonal Hessian Local Model
We consider unconstrained stochastic optimization problems in which the objective function value can only be observable by a Monte Carlo Simulation. We suppose that the derivative information is not directly available by a Monte Carlo Simulation. We present ASTRO-DF with a diagonal Hessian approximation, where a stochastic local model is iteratively constructed and optimized. The noticeable feature is that we can construct the stochastic underdetermined quadratic model as the stochastic local model with O(d) number of function evaluations.

## SimOpt Library
### Traffic Light Problem 
The goal is to study the urban traffic signal control problem as a discrete-event simulation.  We explore a network-based design and verify the sample-path behavior of the  average cycle time as the objectivefunction. We compare the performance of different Simulation Optimization solvers available on SimOptlibrary and discuss takeaways for traffic control structures. Here is [the paper](https://informs-sim.org/wsc20papers/363.pdf).

### Python Simopt
We are trying to develop the SimOpt library by Python. We have developed the framework and also the oracle for various problems. Here is [the link](https://github.com/simopt-admin/simopt).

## Quantum Amplitude Estimation
Quantum Amplitude Estimation (QAE) is a quantum algorithm that provides a quadratic speedup over classical Monte Carlo simulation, i.e., its estimation error scales as O(M^(-1)). Like Monte Carlo simulation, QAE can be applied to a large variety of problems. Recent research has already investigated the applicability of this algorithm to several tasks, for instance, risk analysis and option pricing. We can use the quantum computer for simulation part and the classical computer for optimization part. However, when the decison variables are not continuous, optimization problem is NP-hard problem and thus, we can get quantum advantage again. [The very recent paper](https://arxiv.org/pdf/2005.10780.pdf) suggested Quantum-enhanced simulation optmization. We are trying to improve Quantum Amplitude Estimation algorithm. 
