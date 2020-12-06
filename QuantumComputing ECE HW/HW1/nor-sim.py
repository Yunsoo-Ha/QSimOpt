#!/usr/bin/env python
# coding: utf-8

# In[6]:


from dimod import ExactSolver
sampler = ExactSolver() 

Q = {('x', 'x'): -1, ('y', 'y'): -1, ('z', 'z'): -1, ('x', 'y'): 1, ('x', 'z'): 2, ('y', 'z'): 2}

response = sampler.sample_qubo(Q)
for datum in response.data(['sample', 'energy']):   
  print(datum.sample, "Energy: ", datum.energy)


# In[ ]:




