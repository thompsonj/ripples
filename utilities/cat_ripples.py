#/bin/python

from glob import glob
import numpy as np
from random import shuffle
from scikits.audiolab import Format, Sndfile

home = '/Users/jthompson/Dropbox/ripples/stimuli-Jan-2015/'

fs = 16384

# load filenames of all ripple combinations with 1:1 ratio
path = '/Users/jthompson/Dropbox/ripples/stimuli-Jan-2015/mixtures/proposed_ratios/*.wav'
filelist = glob(path)

nfiles = len(filelist)
idx = np.arange(nfiles)
shuffle(idx)
ripples = np.zeros(fs*nfiles)

# Create a Sndfile instance for writing wav files @ 48000 Hz
format = Format('wav')
outname = home + 'proposedRippleCombos.wav'
cat_ripples = Sndfile(outname, 'w', format, 1, fs)

for i in idx:
	ripple = Sndfile(filelist[i], 'r')
	data = ripple.read_frames(fs)
	cat_ripples.write_frames(data)
	ripple.close()

cat_ripples.close()






