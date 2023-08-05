#!/usr/bin/env python3
# Copyright 2009-2017 BHG http://bw.org/

x = 'Testing python interpreter. Script running...'
print('x is {}'.format(x))
print(type(x))

import numpy as np

def MinMaxScaler(data):
    numerator = data - np.min(data, 0)
    denominator = np.max(data, 0) - np.min(data, 0)
    norm_data = numerator / (denominator + 1e-7)
    return norm_data



def  sine_data_generation(no, seq_len, dim):
    data = list()
    
    for i in range(no):
        temp = list()
        for k in range(dim):
            freq = np.random.uniform(0, 0.1)
            phase = np.random.uniform(0, 0.1)
            
            temp_data = [np.sin(freq * j + phase) for j in range(seq_len)]
            temp.append(temp_data)
            
        temp = np.transpose(np.asarray(temp))
        temp = (temp + 1)*0.5
        data.append(temp)
        
    return data

def real_data_loading(data_name, seq_len):
    assert data_name in ['stock', 'energy']
    
    if data_name == 'stock':
        ori_data = np.loadtxt('data/stock_data.csv', delimeter = ",", skiprows=1)
    elif data_name == 'energy':
        ori_data = np.loadtxt('data/energy_data.csv', delimeter = ",", skiprows=1)
        
    ori_data = ori_data[::-1]
    ori_data = MinMaxScaler(ori_data)
    
    temp_data = []
    for i in range(0, len(ori_data) - seq_len):
        _x = ori_data[i:i + seq_len]
        temp_data.append(_x)
        
    idx = np.random.permutation(len(temp_data))
    data = []
    for i in range(len(temp_data)):
        data.append(temp_data[idx[i]])
    
    return data







