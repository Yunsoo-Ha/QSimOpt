#!/usr/bin/env python
# coding: utf-8

# In[4]:


from dwave.system.samplers import DWaveSampler
from dwave.system.composites import FixedEmbeddingComposite

embedding = {'x': {1}, 'y': {5}, 'z': {4}, 'zz': {0}}

sampler = DWaveSampler()
sampler_embedded = FixedEmbeddingComposite(sampler, embedding)
Q = {('x','x'):-1, ('y','y'):-1, ('z','z'):0.5, ('zz','zz'):0.5, ('x','y'):1, ('x','z'):2, ('y','zz'):2, ('z','zz'):-2}
response = sampler_embedded.sample_qubo(Q, num_reads=5000)
for datum in response.data(['sample', 'energy', 'num_occurrences']):   
  print(datum.sample, "Energy: ", datum.energy, "Occurrences: ", datum.num_occurrences)


# In[ ]:




