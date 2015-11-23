__author__ = 'jthompson'

from glob import glob
import numpy as np
from os import path
import time
import scipy.io as sio

sub='s02'
logsdir = '/Users/jthompson/data/ripples/'+sub+'/logs/'
date_str = time.strftime("%b_%d_%H%M", time.localtime())
tr = 2.6
for run in range(1,13):
    # Load log files of which stimuli were played at which time
    onset_fname = glob(logsdir+sub+'_run'+str(run)+'_stimuli_onsets_*.npy')
    stim_onsets = np.load(onset_fname[-1])
    order_fname = glob(logsdir+sub+'_run'+str(run)+'_order_*.npy')
    stim_order = np.load(order_fname[-1])
    data4prts = np.concatenate((np.matrix(np.floor(stim_onsets / tr)),
                            np.matrix(stim_order))).T
    savedict = {'stimuliinfo': data4prts}
    fname = path.join(logsdir,"%s_run%d_data4prts_%s" % (sub, run, date_str))
    sio.savemat(fname, savedict)
