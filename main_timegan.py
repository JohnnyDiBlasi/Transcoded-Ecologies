#!/usr/bin/env python3
# Copyright 2009-2017 BHG http://bw.org/

x = 'Testing python interpreter. Script running...'
print('x is {}'.format(x))
print(type(x))


"""Time-series Generative Adversarial Networks (TimeGAN) Codebase.
Reference: Jinsung Yoon, Daniel Jarrett, Mihaela van der Schaar, 
"Time-series Generative Adversarial Networks," 
Neural Information Processing Systems (NeurIPS), 2019.
Paper link: https://papers.nips.cc/paper/8789-time-series-generative-adversarial-networks
Last updated Date: April 24th 2020
Code author: Jinsung Yoon (jsyoon0823@gmail.com)
-----------------------------
main_timegan.py
(1) Import data
(2) Generate synthetic data
(3) Evaluate the performances in three ways
  - Visualization (t-SNE, PCA)
  - Discriminative score
  - Predictive score
"""

## Necessary packages
from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import argparse
import numpy as np
import warnings

warnings.filterwarnings("ignore")

# 1. TimeGAN model
from timegan import timegan
# 2. Data loading
from data_loading import real_data_loading, sine_data_generation
# 3. Metrics
from metrics.discriminative_metrics import discriminative_score_metrics
from metrics.predictive_metrics import predictive_score_metrics
from metrics.visualization_metrics import visualization


def main(args):
    if args.data_name in ['stock', 'energy']:
        ori_data = real_data_loading(args.data_name, args.seq_len)
    elif args.data_name == 'sine':
        no, dim = 10000, 5
        ori_data = sine_data_generation(no, args.seq_len, dim)
        
    print(args.data_name + ' dataset is ready.')
    
    ## Synthetic data generation by TimeGAN
    # Set newtork parameters
    parameters = dict()  
    parameters['module'] = args.module
    parameters['hidden_dim'] = args.hidden_dim
    parameters['num_layer'] = args.num_layer
    parameters['iterations'] = args.iteration
    parameters['batch_size'] = args.batch_size
    
    generated_data = timegan(ori_data, parameters)
    print('Finish Synthetic Data Generation')
    
    metric_results = dict()
    
    # 1. Discriminative Score
    discriminative_score = list()
    for _ in range(args.metric_iteration):
        temp_disc = discriminative_score_metrics(ori_data, generated_data)
        discriminative_score.append(temp_disc)
    
    metric_results['discriminative'] = np.mean(discriminative_score)
    
    predictive_score = list()
    for tt in range(args.metric_iteration):
        temp_pred = predictive_score_metrics(ori_data, generated_data)
        predictive_score.append(temp_pred)
        
    metric_results['predictive'] = np.mean(discriminative_score)

    # 2. Predictive Score
    predictive_score = list()
    for tt in range(args.metric_iteration):
        temp_pred = predictive_score_metrics(ori_data, generated_data)
        predictive_score.append(temp_pred)

    metric_results['predictive'] = np.mean(predictive_score)

    # 3. Visualization (PCA and tSNE)
    visualization(ori_data, generated_data, 'pca')
    visualization(ori_data, generated_data, 'tsne')

    # Print Discriminative and Predictive Scores
    print(metric_results)

    return ori_data, generated_data, metric_results


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--data_name', 
        choices=['sine', 'stock', 'energy']
        default='stock', 
        type=str
    )
    parser.add_argument()
