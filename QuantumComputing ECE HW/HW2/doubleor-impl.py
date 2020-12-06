# -*- coding: utf-8 -*-
"""
Created on Wed Sep 16 00:43:13 2020

@author: Yunsoo Ha, 200269142
"""
import dimod
import dwavebinarycsp
from dimod import ExactSolver
sampler = ExactSolver() 

csp = dwavebinarycsp.ConstraintSatisfactionProblem(dwavebinarycsp.BINARY)

n = 2;

def nor_1(v, u):
    return not (v or u)

def logic_circuit1(a, b, z):
    nor1 = nor_1(a,b)
    return (z == nor1)


csp.add_constraint(logic_circuit1, ['a', 'b', 'nor1'])
csp.add_constraint(logic_circuit1, ['nor1', 'c', 'z'])

# Convert the binary constraint satisfaction problem to a binary quadratic model
bqm = dwavebinarycsp.stitch(csp)

#Based on BQM, we can get the QUBO. We can do this automatically but, here I did it manually.
#Q = dimod.BinaryQuadraticModel.to_qubo(bqm)

Q = ({('a', 'b'): 2, ('a', 'nor1'): 4, ('b', 'nor1'): 4, ('nor1', 'c'): 2, ('nor1', 'z'): 4, \
      ('c', 'z'): 4, ('a', 'a'): -2, ('b', 'b'): -2, ('nor1', 'nor1'): -4, ('c', 'c'): -2, \
      ('z', 'z'): -2})

response = sampler.sample_qubo(Q)
for datum in response.data(['sample', 'energy']): 
    print(datum.sample, "Energy: ", datum.energy)
