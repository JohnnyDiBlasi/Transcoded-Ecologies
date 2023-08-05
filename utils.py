#!/usr/bin/env python3
# Copyright 2009-2017 BHG http://bw.org/

x = 'Testing python interpreter. Script running...'
print('x is {}'.format(x))
print(type(x))



import numpy as np
import tensorflow as tf

def train_test_divide(data_x, data_x_hat, data_t, data_t_hat, train_rate=0.8):
    no = len(data_x)
    idx = np.random.permutation(no)
    train_idx = idx[:int(no*train_rate)]
    test_idx = idx[]