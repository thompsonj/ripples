#!/usr/bin/env python
"""
Define and save stimuli presentation order for ripple sum fMRI experiment.

8 training sounds (simple ripples 2f0 x 2Rt x 2Om) repeated 27 times each
    f0 = [132.5, 210]
    Rt = [2, 6]
    Om = [0.7, 1.7]
84 test sounds (weighted sums at 1:1, 1:2, 2:1 ratios) repeated 3 times each

6 testing runs containing 42 stimulus presentations each (252 testing trials)
    The complete set of 84 test sounds will be presented every 2 runs. The
    order of the 84 sounds will be shuffled randomly and divided evenly
    between each consequetive two runs.

6 training runs containing 36 stimulus presentations each (216 training trials)
    Approximatlely the same distribution of ripple parameters in each run,
    presentation shuffled randomly within runs.

Runs order will alternate between ABBA and BAAB with every subject. A
different random order of examples will be used for each subject.

6 silent/zero trials per run - indicated by label 0
6 catch trials per run - indicated by label 1

* NOTE: In the original formulation of our research question, we would only
train on simple ripples and predict responses to ripple combinations. However,
there may be some questionsthat would involvevthe opposite prediction. In
which case the "training" and "test" labels above would be inaccurate.

"""
import sys
from glob import glob
from random import shuffle
from os import path, mkdir
import numpy as np
cat = np.concatenate

__author__ = 'Jessica Thompson'


def set_stimuli_order(subject='jt',
                      exp_dir='..',
                      run_order='ABBA'):
    """ Sets the order of presentation and jitter value for each stimulus.

    Saves two files per run per subject. One indicating the order of stimuli
    presentation and one indicating the interstimulus interval for each trial.
    This files can then be read by run_ripple_fmri.py to execute a run of the
    experiment.


    Parameters
    ----------
    subject : str
        the subject code (initials) for the current subject
    exp_dir : str
        the experimental directory, assumed to contain subfolders 'code' and
        'stimuli'
    run_order : str
        specifies the order of simple and combination runs, either 'ABBA' or
        'BAAB'

    """
    # PARAMETERS
    n_sim_run = 6        # Runs of only simple ripples
    sim_run_len = 36     # Trials per simple run
    n_mix_run = 6        # Runs of only mixed ripple pairs
    mix_run_len = 42     # Trials per mixed runs
    n_sim = 8            # Number of unique simple ripples
    n_mix = 84           # Number of unique mixed ripples
    n_silent = 6         # Number of silent trials per run
    n_catch = 6          # Number of catch trials per run
    n_run = n_sim_run + n_mix_run               # Total number of runs
    n_sim_rep = (n_sim_run*sim_run_len)/n_sim   # Number of simple repetitions
    n_mix_rep = (n_mix_run*mix_run_len)/n_mix   # Number of mixed repetitions

    # SET ORDER FOR SIMPLE RIPPLE RUNS
    sim_order = np.array([[i]*n_sim_rep for i in range(n_sim)])
    # Increase order index by 2. 0 and 1 indicate silence and catch trials
    sim_order = sim_order.flatten() + 2
    # sim_jitter = np.array([2, 3, 4]*(len(sim_order)/3))
    sim_jitter = np.tile(np.array([2, 2, 2, 3, 3, 3, 4, 4, 4]),
                                 (1, (len(sim_order)/9)))

    # Reshape into runs, one run per row
    sim_order = np.reshape(sim_order, (n_sim_run, sim_run_len), order='F')
    sim_jitter = np.reshape(sim_jitter, (n_sim_run, sim_run_len), order='F')
    # At this point, each run has the right number of repetitions of each
    # stimulus with equal distribution of jitter values

    # Add five catch trials and 5 silent trials to each run, then shuffle the
    # order in each run
    catch_trials = np.ones((n_sim_run, n_catch))
    silent_trials = np.zeros((n_sim_run, n_silent))
    sim_order = cat((sim_order, catch_trials, silent_trials), axis=1)
    catch_jitter = np.tile(np.arange(2, 5), (n_sim_run, n_catch/3))
    silent_jitter = np.tile(np.arange(2, 5), (n_sim_run, n_silent/3))
    sim_jitter = cat((sim_jitter, catch_jitter, silent_jitter), axis=1)

    # Shuffle each row while ensuring that no run begins with a catch or silent
    # trial and that silent trials and catch trials are never back to back
    sim_order_rand, sim_jitter_rand = shuffle_trials(sim_order, sim_jitter)

    # SET ORDER FOR RIPPLE MIXTURE RUNS
    # The complete set of mixed sounds is repeated every 2 runs
    # The order of presentation is randomized within each runs
    # Each sound is repeated 3 times
    # Each repetition is presented once with each of 2, 3 or 4 TRs jitter
    mix_idxs = np.arange(n_mix)
    mix_order = np.tile(np.arange(n_mix), (n_mix_rep, 1)) + 2
    mix_jitter = np.vstack((np.tile([2, 3, 4], (n_mix/3)),
                            np.tile([3, 4, 2], (n_mix/3)),
                            np.tile([4, 2, 3], (n_mix/3))))

    # Split into runs, one run per row
    mix_order = np.reshape(mix_order, (n_mix_run, mix_run_len), order='C')
    mix_jitter = np.reshape(mix_jitter, (n_mix_run, mix_run_len), order='C')

    # Add five catch trials and 5 silent trials to each run
    catch_trials = np.ones((n_mix_run, n_catch))
    silent_trials = np.zeros((n_mix_run, n_silent))
    mix_order = cat((mix_order, catch_trials, silent_trials), axis=1)
    catch_jitter = np.tile(np.arange(2, 5), (n_sim_run, n_catch/3))
    silent_jitter = np.tile(np.arange(2, 5), (n_sim_run, n_silent/3))
    mix_jitter = cat((mix_jitter, catch_jitter, silent_jitter), axis=1)

    # Shuffle each row while ensuring that no run begins with a catch or silent
    # trial and that silent trials and catch trials are never back to back
    mix_order_rand, mix_jitter_rand = shuffle_trials(mix_order, mix_jitter)

    # Save order and jitter info to be be read by RippleCombosRun.py
    if not path.isdir(subject):
        mkdir(subject)
    if run_order == 'ABBA':
        A_order = sim_order_rand
        A_jitter = sim_jitter_rand
        B_order = mix_order_rand
        B_jitter = mix_jitter_rand
    elif run_order == 'BAAB':
        A_order = mix_order_rand
        A_jitter = mix_jitter_rand
        B_order = sim_order_rand
        B_jitter = sim_jitter_rand

    for r in np.arange(0, 6, 2):
        # A
        np.save(path.join(subject, "%s_run%s_order" % (subject, (r*2)+1)),
                A_order[r, :])
        np.savetxt(path.join(subject, "%s_run%s_order.txt" % (subject,
                                                              (r*2)+1)),
                   A_order[r, :], fmt='%.0f')
        np.save(path.join(subject, "%s_run%s_jitter" % (subject, (r*2)+1)),
                A_jitter[r, :])
        np.savetxt(path.join(subject, "%s_run%s_jitter.txt" % (subject,
                                                               (r*2)+1)),
                   A_jitter[r, :], fmt='%.0f')
        # B
        np.save(path.join(subject, "%s_run%s_order" % (subject, (r*2)+2)),
                B_order[r, :])
        np.savetxt(path.join(subject, "%s_run%s_order.txt" % (subject,
                                                              (r*2)+2)),
                   B_order[r, :], fmt='%.0f')
        np.save(path.join(subject, "%s_run%s_jitter" % (subject, (r*2)+2)),
                B_jitter[r, :])
        np.savetxt(path.join(subject, "%s_run%s_jitter.txt" % (subject,
                                                               (r*2)+2)),
                   B_jitter[r, :], fmt='%.0f')
        # B
        np.save(path.join(subject, "%s_run%s_order" % (subject, (r*2)+3)),
                B_order[r+1, :])
        np.savetxt(path.join(subject, "%s_run%s_order.txt" % (subject,
                                                              (r*2)+3)),
                   B_order[r+1, :], fmt='%.0f')
        np.save(path.join(subject, "%s_run%s_jitter" % (subject, (r*2)+3)),
                B_jitter[r+1, :])
        np.savetxt(path.join(subject, "%s_run%s_jitter.txt" % (subject,
                                                               (r*2)+3)),
                   B_jitter[r+1, :], fmt='%.0f')
        # A
        np.save(path.join(subject, "%s_run%s_order" % (subject, (r*2)+4)),
                A_order[r+1, :])
        np.savetxt(path.join(subject, "%s_run%s_order.txt" % (subject,
                                                              (r*2)+4)),
                   A_order[r+1, :], fmt='%.0f')
        np.save(path.join(subject, "%s_run%s_jitter" % (subject, (r*2)+4)),
                A_jitter[r+1, :])
        np.savetxt(path.join(subject, "%s_run%s_jitter.txt" % (subject,
                                                               (r*2)+4)),
                   A_jitter[r+1, :], fmt='%.0f')

    np.save(path.join(subject, subject+'_simple_order'), sim_order_rand)
    np.save(path.join(subject, subject+'_simple_jitter'), sim_jitter_rand)
    np.save(path.join(subject, subject+'_mix_order'), mix_order_rand)
    np.save(path.join(subject, subject+'_mix_jitter'), mix_jitter_rand)


def shuffle_trials(order, jitter):
    """
    Shuffle each row while ensuring that:
    - no run begins or ends with a catch or silent trial,
    - silent trials and catch trials are never back to back,
    - silent trials never immediately follow a catch trial or vice versa
    """
    n_run = jitter.shape[0]
    idx = np.arange(jitter.shape[1])
    order_rand = np.zeros(order.shape)
    jitter_rand = np.zeros(jitter.shape)
    for r in range(n_run):
        shuffle(idx)
        order_rand[r, :] = order[r, idx]
        # inter_c = np.diff(np.where(order_rand[r, :] == 1))
        # inter_s = np.diff(np.where(order_rand[r, :] == 0))
        inter_cs = np.diff(np.where(order_rand[r, :] <= 1))
        while ((order_rand[r, 0] <= 1) or (order_rand[r, -1] <= 1) 
               or (1 in inter_cs)):
            shuffle(idx)
            order_rand[r, :] = order[r, idx]
            # inter_c = np.diff(np.where(order_rand[r, :] == 1))
            # inter_s = np.diff(np.where(order_rand[r, :] == 0))
            inter_cs = np.diff(np.where(order_rand[r, :] <= 1))
        jitter_rand[r, :] = jitter[r, idx]
    return order_rand, jitter_rand


def save_stimuli_info(exp_dir='..'):
    """ Write the file names of all stimuli to text and npy files. """

    # Get file names for all simple ripples described above
    simple_ripples = glob(path.join(exp_dir, 'stimuli',
                          'f0[12][31][20]*_Rt[26]_Om[01].7_filtered.wav'))
    simple_ripples = np.array([path.basename(s) for s in simple_ripples])
    # Get file names for all mixtures
    match = 'MIX[12]to[12]-f0[12][31][20]*_Rt[26]_Om[01].7_filtered.wav'
    mixtures = glob(path.join(exp_dir, 'stimuli', match))
    mixtures = np.array([path.basename(m) for m in mixtures])

    # Write file names to text files
    write_wav_names('SimpleWavFileNames.txt', simple_ripples, exp_dir)
    write_wav_names('MixWavFileNames.txt', mixtures, exp_dir)
    np.save('MixWavFileNames.npy', mixtures)
    np.save('SimpleWavFileNames.npy', simple_ripples)


def save_feature_vectors():
    """ Save matrix of 6D feature vectors for each trial of the experiment """
    # Get and save parameters of ripples mixtures
    # fnames = np.load('All92_fnames_in_same_order_as_prt.npy')
    # mixes = np.load('MixWavFileNames.npy')
    # simples = np.load('SimpleWavFileNames.npy')

    # for f in fnames:
    #   ratio1 = f.split('to')[0][-1]
    #   ratio2 = f.split('to')[1][0]
    #   rips = f.split('-f0')
    #   f01 = rips[1].split('_')[0]
    #   f01 = rips[2].split('_')[0]
    #   Rt1 = rips[1].split('_')[1][-1]
    #   Rt2 = rips[2].split('_')[1][-1]
    #   Om1 = rips[1].split('_')[2][-3:]
    #   Om2 = rips[2].split('_')[2][-3:]
    #   feature_vectors =

    # # Get and save parameters of simple ripples
    # for ripple in simple_ripples:

    # Transform parameters into 6-D feature vector?
#     match = 'MIX[12]:[12]-f0[12][31][20]*_Rt[26]_Om[01].7_filtered.wav'
#     mixtures = glob(path.join(exp_dir, 'stimuli', match))

# for mix in mixtures:
#     os.rename(mix, mix.replace(':','to'))


def write_wav_names(fname, wavs, exp_dir):
    f = open(fname, 'w')
    f.writelines('silence.wav\n')
    f.writelines('catch.wav\n')
    f.writelines("%s\n" % item for item in wavs)
    f.close()


def save_txt_4matlab():
    simfnames = np.load('SimpleWavFileNames.npy')
    mixfnames = np.load('MixWavFileNames.npy')
    fnames = np.concatenate((simfnames, mixfnames))
    fnames = np.array([path.basename(f) for f in fnames])
    np.savetxt('All92_fnames_in_same_order_as_prt.txt', fnames, '%s')
    np.save('All92_fnames_in_same_order_as_prt.npy', fnames)


def main():
    argv = sys.argv
    try:
        subject = argv[1]
    except:
        subject = 's03'
    try: 
        run_order=argv[2]
    except:
        run_order ='ABBA'
    set_stimuli_order(subject=subject,run_order=run_order)
    save_stimuli_info()
    print 'done'

if __name__ == '__main__':
    main()
