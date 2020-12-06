# -*- coding: utf-8 -*-
"""
Created on Wed Sep 16 00:43:13 2020

@author: Yunsoo Ha, 200269142
"""

import dwavebinarycsp
import dimod
from dimod import ExactSolver
sampler = ExactSolver() 

csp = dwavebinarycsp.ConstraintSatisfactionProblem(dwavebinarycsp.BINARY)

def nor_1(v, u):
    return not (v or u)

def logic_circuit(a, b, z):
    nor1 = nor_1(a,b)
    nor2 = nor_1(nor1,a)
    nor3 = nor_1(nor1,b)
    nor4 = nor_1(nor2,nor3)
    nor5 = nor_1(nor4,nor4)
    return (z == nor5)

csp.add_constraint(logic_circuit, ['a', 'b', 'z'])


# Convert the binary constraint satisfaction problem to a binary quadratic model
bqm = dwavebinarycsp.stitch(csp)
Q = dimod.BinaryQuadraticModel.to_qubo(bqm)
print(Q)

response = sampler.sample(bqm)
for datum in response.data(['sample', 'energy']):   
    # I checked the lowest energy value is 0
    if datum.energy == 0:
        print(datum.sample, "Energy: ", datum.energy)
