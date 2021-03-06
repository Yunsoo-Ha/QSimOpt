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

from dwave.system.samplers import DWaveSampler
from dwave.system.composites import FixedEmbeddingComposite   

# I used the QMI (presentation page 48: More complex example: 3-bit Adder)
embedding = {'a': {0}, 'nor1': {4,12},
		     'b': {1,5}, 'c': {9,13},
             'z': {8}}

sampler_embedded = FixedEmbeddingComposite(DWaveSampler(),embedding)

#Based on BQM, we can get the QUBO. We can do this automatically but, here I did it manually.
#Q = dimod.BinaryQuadraticModel.to_qubo(bqm)

Q = ({('a', 'b'): 2, ('a', 'nor1'): 4, ('b', 'nor1'): 4, ('nor1', 'c'): 2, ('nor1', 'z'): 4, \
      ('c', 'z'): 4, ('a', 'a'): -2, ('b', 'b'): -2, ('nor1', 'nor1'): -4, ('c', 'c'): -2, \
      ('z', 'z'): -2})

#response = sampler_embedded.sample_qubo(Q)
#for datum in response.data(['sample', 'energy']):   
#  print(datum.sample, "Energy: ", datum.energy)

response = sampler_embedded.sample_qubo(Q, num_reads=5000)
for datum in response.data(['sample', 'energy', 'num_occurrences']):   
  print(datum.sample, "Energy: ", datum.energy, "Occurrences: ", datum.num_occurrences)