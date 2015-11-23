import numpy as np
import scipy.io as sio

logpath = 'D:\ripples\s02\logs'
ordpath = 'D:\ripples\s02\code\s02'
TR = 2.6

onset = {'1':'\s02_run1_stimuli_onsets_Jun_04_1006.npy',
         '2' :'\s02_run2_stimuli_onsets_Jun_04_1014.npy',
         '3' : '\s02_run3_stimuli_onsets_Jun_04_1023.npy'}
# onset{4} = '\s02_run4_stimuli_onsets_Jun_04_1030.npy'
# onset{5} = '\s02_run5_stimuli_onsets_Jun_04_1038.npy'
# onset{6} = '\s02_run6_stimuli_onsets_Jun_04_1047.npy'
# onset{7} = '\s02_run7_stimuli_onsets_Jun_04_1055.npy'
# onset{8} = '\s02_run8_stimuli_onsets_Jun_04_1103.npy'
# onset{9} = '\s02_run9_stimuli_onsets_Jun_04_1111.npy'
# onset{10} = '\s02_run10_stimuli_onsets_Jun_04_1119.npy'
# onset{11} = '\s02_run11_stimuli_onsets_Jun_04_1128.npy'
# onset{12} = '\s02_run12_stimuli_onsets_Jun_04_1135.npy'

order = {'1':'\s02_run1_order_Jun_04_1006.npy',
         '2' =:'\s02_run2_order_Jun_04_1014.npy',
         '3' : '\s02_run3_order_Jun_04_1023.npy'}
# order{4} = '\s02_run4_order_Jun_04_1030.npy'
# order{5} = '\s02_run5_order_Jun_04_1038.npy'
# order{6} = '\s02_run6_order_Jun_04_1047.npy'
# order{7} = '\s02_run7_order_Jun_04_1055.npy'
# order{8} = '\s02_run8_order_Jun_04_1103.npy'
# order{9} = '\s02_run9_order_Jun_04_1111.npy'
# order{10} = '\s02_run10_order_Jun_04_1119.npy'
# order{11} = '\s02_run11_order_Jun_04_1128.npy'
# order{12} = '\s02_run12_order_Jun_04_1135.npy'


for run in range(1,13):
    onsets = np.load('logs'+ onset[str(run)])
    onsets = np.floor(onset/TR)
    stim = np.load('code\s02' + order[str(run)])
    mat =  np.concatenate((np.matrix(onset), np.matrix(stim)), 0)
    name = 'stiminfo_run%d' % run
    savedict = {name : mat}
    sio.savemat(name, savedict)


