#!/usr/bin/env python
"""
Executes one full run of the Ripples Combinations fMRI experiment.

Stimuli for this experiment consist of 8 1-sec dynamic ripples (simple
ripples) and pairwise sums of those ripples (ripple combos). Stimuli have been
equalized using the filter provided with the Sensimetrics 219 earphones system.
Stimuli were generated using gen_combinations.m which can be found in the
utilities directory. Stimuli order and run order is fixed before hand using
set_stim_order.py

The experiment uses a fast event-related design with the following
configuration:

    6 Simple runs containing 36 stimulus presentations each
        Each simple ripple repeated 27 times (8*27 = 216 Simple trials)
    6 Combo runs containing 42 stimulus presentations each
        Each ripple combo repeated 3 times (84*3 = 252 Combo trials)

    + 6 catch trials in each run (identify short sound)
    + 6 silent trials in each run

    Jittered inter-stimuli-interval of 2, 3 or 4 TRs
    Average ISI of 7.8 s

    No additional jitter in the placement of the sound within the silent gap
    Stimulus is always presented 300 ms after the end of scanner noise.

    TR = 2.6s
    Silent gap = 1.4 s

    These parameters are motivated by the fact that we want at least 3
    repetitions of each stimulus, while keeping the total number of trials per
    condition as equal as possible. Additionally, it is convenient if the
    number of repetitions is a multiple of the size of the ISI jitter set (in
    our case 3) to easily assign jitter values to each stimulus without
    introducing bias.

A different random order of stimulus presentation is used for each subject.
Half of the subjects will have an ABBA run order and half will use BAAB.

"""

from os import path, mkdir
from psychopy import core, visual, sound, gui, data, event, logging, prefs
from psychopy.tools.filetools import fromFile, toFile
from psychopy.hardware.emulator import launchScan
import time
import numpy as np
import scipy.io as sio

__author__ = "Jessica Thompson"


def run():
    """ Execute one experimental run of the experiment """
    settings = initialize_run()
    stimuli, order, jitter, settings = load_stimuli(settings)
    present_stimuli(stimuli, order, jitter, settings)


def initialize_run():
    """
    Initalizes settings and log file for this run of the experiment.

    Returns
    -------
    settings : dict
        Contains various experimental settings such as MR imaging parameters

        subject : Subject code use for loading/saving data
        run : int from 1-12
        order : Order of runs, either ABBA or BAAB
        debug : If true, print extra info
        home_dir : Parent directory, assumed to contain a directory 'code'
                   containing one directory per subject
        TA : Time to acquire one volume
        onset_delay : Wait this long after beginning of silent gap before
                      starting stimulus
        TR : Time between acquisitions
        volumes : Number of whole-brain 3D volumes / frames
        sync : Character to use as the sync timing event; assumed to come at
               start of a volume
        resp : Key code for catch trials
        skip : Number of volumes lacking a sync pulse at start of scan (for T1
               stabilization)
        end_vols : How many volumes to collect after the last stimulus has
                   played
        scan_sound : In test mode only, play a tone as a reminder of scanner
                     noise
    """

    logging.console.setLevel(logging.DEBUG)
    if prefs.general['audioLib'][0] == 'pyo':
        # if pyo is the first lib in the list of preferred libs then we could
        # use small buffer
        # pygame sound is very bad with a small buffer though
        sound.init(16384, buffer=128)
    print 'Using %s(with %s) for sounds' % (sound.audioLib, sound.audioDriver)

    # settings for launchScan:
    try:
        settings = fromFile('settings.pickle')
    except:
        settings = {
            'subject': 'jt',  # Subject code use for loading/saving data
            'run': 1,  # int from 1-12
            'order': 'ABBA',  # Order of runs, either ABBA or BAAB
            'debug': True,  # If true, print extra info
            'home_dir': '..',  # Parent directory, assumed to contain a
            # directory 'code' containing one directory
            # per subject
            'TA': 1.200,  # Time to acquire one volume
            'onset_delay': .301,  # Wait 300 ms after beginning of silent gap
            # before starting stimulus
            'TR': 2.6,  # Time between acquisitions
            'volumes': 168,  # Number of whole-brain 3D volumes / frames
            # this will be updated when known
            'sync': '5',  # Character to use as the sync timing event;
            # assumed to come at start of a volume
            'resp': '1',  # Button response for catch trials
            'skip': 0,  # Number of volumes lacking a sync pulse at
            # start of scan (for T1 stabilization)
            'end_vols': 6,  # How many volumes to collect after the last
            # stimulus has played
            'sound': True  # In test mode only, play a tone as a
            # reminder of scanner noise
        }
    info_dlg = gui.DlgFromDict(settings, title='settings',
                               order=['subject', 'run', 'order', 'debug'])

    if info_dlg.OK:
        next_settings = settings.copy()
        if settings['run'] == 12:
            next_settings['run'] = 1  # Reset run when experiment is over
        else:
            next_settings['run'] += 1  # Increment for the next run
        toFile('settings.pickle', next_settings)
    else:
        core.quit()
    if not path.isdir(settings['home_dir']):
        mkdir(settings['home_dir'])

    # Create dated log file
    date_str = time.strftime("%b_%d_%H%M", time.localtime())
    logfname = path.join(settings['home_dir'], 'logs',
                         "%s_run%s_log_%s.log" %
                         (settings['subject'], settings['run'], date_str))
    log = logging.LogFile(logfname, level=logging.INFO, filemode='a')

    return settings


def load_stimuli(settings):
    """
    Load wav files, order and jitter values for given run and subject.

    All stimuli are loaded at the beginning of the run to avoid long
    computations during the presentation of the stimuli.

    Assumes the following files are in the current directory:
        SimpleWavFileNames.npy
        MixWavFileNames.npy
    Which should list the stimuli base file names (no path).
    All stimuli are assumed to be located in the directory 'stimuli' in
    the parent directory.

    Assumes that the following files are in a directory named [subject]:
        [subject]_run[run]_order.npy
        [subject]_run[run]_jitter.npy

    Parameters
    ----------
    settings : dict
        Contains various experimental settings such as MR imaging parameters

    Returns
    -------
    stimuli :  ndarray of psychopy.sound.SoundPyo objects
        Sounds to be presented in this run in the order in which they were
        listed in either SimpleWavFileNames.txt or MixWavFileNames.txt
    order : ndarray
        Specifies order of presentation as indices into the stimuli array
    jitter : ndarray
        Inter-stimuli-intervals in multiples of TRs (2, 3 or 4)
    """
    if settings['order'] == 'ABBA':
        simple_runs = [1, 4, 5, 8, 9, 12]
        mix_runs = [2, 3, 6, 7, 10, 11]
    elif settings['order'] == 'BAAB':
        mix_runs = [1, 4, 5, 8, 9, 12]
        simple_runs = [2, 3, 6, 7, 10, 11]
    # Load stimuli
    if settings['run'] in simple_runs:
        # Load simple ripples for odd runs
        fnames = np.loadtxt('SimpleWavFileNames.txt', dtype=str)
    elif settings['run'] in mix_runs:
        # Load mix ripples for even runs
        fnames = np.loadtxt('MixWavFileNames.txt', dtype=str)
    stimuli = np.array(
        [sound.SoundPyo(path.join('..', 'stimuli', f)) for f in fnames])
    order = np.load(path.join(settings['subject'],
                              "%s_run%s_order.npy" % (settings['subject'],
                                                      settings['run'])))
    jitter = np.load(path.join(settings['subject'],
                               "%s_run%s_jitter.npy" % (settings['subject'],
                                                        settings['run'])))
    extra_vols = settings['end_vols'] + settings['skip']
    settings['volumes'] = np.sum(jitter) + extra_vols

    return stimuli, order, jitter, settings


def present_stimuli(stimuli, order, jitter, settings):
    """
    Presents stimuli in the specified order with the specified inter-stimuli-
    interval based on triggers from the scanner.

    Uses psychopy's launchScan module to add a test/scan switch on the main
    window. If in test mode, launchScan immitates the scanner by sending
    triggers (key press '5') and playing scanner noise when the scanner would
    be acquiring a volume.

    Saves the following log files to the subject's folder in a directory called
    'data' in the parent directory.
        [subject]_run[run]_key_presses_[date].txt
        [subject]_run[run]_catch_trials_[date].txt
        [subject]_run[run]_stimuli_timing_[date].txt
        [subject]_run[run]_stimuli_onsets_[date].npy
        [subject]_run[run]_volumes_onsets_[date].npy

    Saves the following date stamped copies of the order and jitter used for
    this run in the subject directory in the current directory:
        [subject]_run[run]_order_[date].npy
        [subject]_run[run]_jitter_[date].npy

    Parameters
    ----------
    stimuli :  ndarray of psychopy.sound.SoundPyo objects
        Sounds to be presented in this run in the order in which they were
        listed in either SimpleWavFileNames.txt or MixWavFileNames.txt
    order : ndarray
        Specifies order of presentation as indices into the stimuli array
    jitter : ndarray
        Inter-stimuli-intervals in multiples of TRs (2, 3 or 4)
    settings : dict
        Contains various experimental settings such as MR imaging parameters

    """
    if settings['debug']:
        win = visual.Window(fullscr=False)
    else:
        win = visual.Window(allowGUI=False, monitor='testMonitor',
                            fullscr=True)
    fixation = visual.ShapeStim(win,
                                vertices=((0, -0.015), (0, 0.015), (0, 0),
                                          (-0.01, 0), (0.01, 0)),
                                lineWidth=2,
                                closeShape=False,
                                lineColor='white')
    global_clock = core.Clock()

    # summary of run timing, for each key press:
    output = u'vol    onset key\n'
    for i in range(-1 * settings['skip'], 0):
        output += u'%d prescan skip (no sync)\n' % i
    volume_onsets = np.zeros(settings['volumes'] - settings['skip'])

    # Stimulus log
    stim_log = u'onset  stimulus_idx\n'
    stim_onsets = np.zeros(len(order))

    # Response log
    catch_log = u'catch_onset   hit/miss \n'

    # Key press log
    key_code = settings['sync']
    counter = visual.TextStim(win, height=.05, pos=(0, 0), color=win.rgb + 0.5)
    output += u"  0    0.000 %s  [Start of scanning run, vol 0]\n" % key_code

    # Best if your script timing works without this, but this might be useful
    # sometimes
    infer_missed_sync = False

    # How long to allow before treating a "slow" sync as missed. Any slippage
    # is almost certainly due to timing issues with your script or PC, and not
    # MR scanner
    max_slippage = 0.02

    sync_now = False
    catch = False
    play = True
    n_tr_seen = 0
    stim_idx = 0
    # wait 5 TRs after the last stimulus
    duration = settings['volumes'] * settings['TR']
    # launch: operator selects Scan or Test (emulate); see API documentation
    vol = launchScan(win, settings, globalClock=global_clock)
    # note: globalClock has been reset to 0.0 by launchScan()
    if not settings['debug']:
        fixation.draw()
        win.flip()
    while global_clock.getTime() < duration and vol <= settings['volumes']:
        all_keys = event.getKeys()
        for key in all_keys:
            if key != settings['sync']:
                output += u"%3d  %7.3f %s\n" % (vol - 1, global_clock.getTime(),
                                                unicode(key))
        if 'escape' in all_keys:
            output += u'user cancel, '
            break
        # Detect sync or infer it should have happened:
        if settings['sync'] in all_keys:
            sync_now = key_code
            onset = global_clock.getTime()
        if infer_missed_sync:
            expected_onset = vol * settings['TR']
            now = global_clock.getTime()
            if now > expected_onset + max_slippage:
                sync_now = u'(inferred onset)'
                onset = expected_onset
        # Detect button press from subject, record performance on catch trials
        if settings['resp'] in all_keys:
            output += (u"%3d  %7.3f %s\n" % (vol - 1, global_clock.getTime(),
                                             unicode(settings['resp'])))
            if catch:
                catch_log += u' hit\n'
                catch = False

        if catch and (global_clock.getTime() - catch_onset) > 3:
            catch_log += u' miss\n'
            catch = False
        if sync_now:
            output += u"%3d  %7.3f %s\n" % (vol, onset, sync_now)
            volume_onsets[vol - 1] = onset
            # Count tiggers to know when to present stimuli
            n_tr_seen += 1
            if settings['debug']:
                counter.setText(u"%d volumes\n%.3f seconds" % (vol, onset))
                counter.draw()
                win.flip()
            if play and n_tr_seen == jitter[stim_idx]:
            # Play sound 100 ms after end of acquisition
            # Log onset time of stimulus presentation
                print order[stim_idx]
                now = global_clock.getTime()
                while now < onset + settings['TA'] + settings['onset_delay']:
                    now = global_clock.getTime()
                print 'stim:', now
                stimuli[order[stim_idx]].play()
                stim_log += u"%7.3f  %s\n" % (now, order[stim_idx])
                stim_onsets[stim_idx] = now

                if order[stim_idx] == 1:
                    catch = True
                    catch_onset = now
                    catch_log += "%s" % str(catch_onset)
                stim_idx += 1
                if stim_idx == len(order):
                    play = False
                n_tr_seen = 0

            vol += 1
            sync_now = False

    # Save copy of order and jitter used
    date_str = time.strftime("%b_%d_%H%M", time.localtime())
    np.save(path.join(settings['subject'],
                      "%s_run%s_order_%s" %
                      (settings['subject'], settings['run'], date_str)),
            order)
    np.save(path.join(settings['subject'], "%s_run%s_jitter_%s" %
                      (settings['subject'], settings['run'], date_str)), jitter)

    output += (u"End of scan (vol 0..%d = %d of %s).\n" %
               (vol - 1, vol, settings['volumes']))
    total_dur = global_clock.getTime()
    date_str = time.strftime("%b_%d_%H%M", time.localtime())
    output += u"Total duration = %7.3f sec (%7.3f min)" % (total_dur,
                                                           total_dur / 60)
    print "Total duration = %7.3f sec (%7.3f min)" % (total_dur, total_dur / 60)

    # Save data and log files
    datapath = path.join(settings['home_dir'], 'data', settings['subject'])
    if not path.isdir(datapath):
        mkdir(datapath)

    # Write log of key presses/volumes
    fname = path.join(datapath,
                      "%s_run%s_all_keys_%s" %
                      (settings['subject'], settings['run'], date_str))

    data_file = open(fname + '.txt', 'w')
    data_file.write(output)
    data_file.close()

    # Wite log of catch trials
    fname = path.join(datapath,
                      "%s_run%s_catch_trials_%s" %
                      (settings['subject'], settings['run'], date_str))

    data_file = open(fname + '.txt', 'w')
    data_file.write(catch_log)
    data_file.close()

    # Write log of stimulus presentations
    fname = path.join(datapath,
                      "%s_run%s_stimuli_timing_%s" %
                      (settings['subject'], settings['run'], date_str))

    data_file = open(fname + '.txt', 'w')
    data_file.write(stim_log)
    data_file.close()

    # Save numpy arrays of onset timing for easy analysis
    fname = path.join(datapath,
                      "%s_run%s_stimuli_onsets_%s" %
                      (settings['subject'], settings['run'], date_str))
    np.save(fname, stim_onsets)

    data4prts = np.concatenate(
        (np.matrix(np.floor(stim_onsets / settings['TR'])),
         np.matrix(order))).T
    savedict = {'stimuliinfo': data4prts}
    fname = path.join(datapath,
                      "%s_run%02d_data4prts_%s" %
                      (settings['subject'], int(settings['run']), date_str))
    sio.savemat(fname, savedict)

    fname = path.join(datapath,
                      "%s_run%s_volume_onsets_%s" %
                      (settings['subject'], settings['run'], date_str))
    np.save(fname, volume_onsets)

    # Save settings for this run
    fname = path.join(datapath,
                      "%s_run%s_settings_%s" %
                      (settings['subject'], settings['run'], date_str))
    np.save(fname, settings)
    core.quit()


def main():
    run()
    print('Done')


if __name__ == '__main__':
    main()
