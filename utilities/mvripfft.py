#!/usr/bin/env python2
"""
Convert matlab function for generating dynamic ripples to python to be used in psychoPy
adaptive staircase experiment

MVRIPFFT generate a single moving ripple via FFT
s = mvripfft(para)
[s, ph_c, fdx] = mvripfft(para, cond, ph_c)
para = [Am, Rt, Om, Ph]
    Am: modulation depth, 0 < Am < 1, DEFAULT = .9;
    Rt: rate (Hz), integer preferred, typically, 1 .. 128, DEFAULT = 6;
    Om: scale (cyc/oct), any real number, typically, .25 .. 4, DEFAULT = 2; 
    Ph: (optional) symmetry (Pi) at f0, -1 < Ph < 1, DEFAULT = 0.
cond = (optional) [T0, f0, SF, BW, RO, df]
    T0: duartion (sec), DEFAULT = 1.
    f0: center freq. (Hz), DEFAULT = 1000.
    SF: sample freq. (Hz), must be power of 2, DEFAULT = 16384
    BW: excitation band width (oct), DEFAULT = 5.8.
    RO: roll-off (dB/oct), 0 means log-spacing, DEFAULT = 0;
    df: freq. spacing, in oct (RO=0) or in Hz (RO>0), DEFAULT = 1/16.
    ph_c: component phase

Acknowledge: This program is available due to Jian Lin's creative idea and
his C program [rip.c]. Thank Jonathan Simon and Didier Dipereux for their
Matlab program [ripfft.m].

08-Jun-98, v1.00
Original MATLAB code downloaded here: http://www.isr.umd.edu/Labs/NSL/Software.htm

Converted to python by Jessica Thompson, January 2015
@author: Jessica Thompson

default parameters and conditions
para = [Am, Rt, Om, Ph]; cond = (optional) [T0, f0, SF, BW, RO, df];
"""
import numpy as np
from scipy.fftpack import ifft
import sys

def mvripfft(Am=.9, Rt=6., Om=2., Ph=0., T0=1., f0=1000, SF=16384, BW=5.8, RO=0, df=1./16, ph_c=None):

    T1 = np.ceil(T0)    # duration for generating purpose
    Ri = Rt*T1          # modulation lag, # of df

    # freq axis
    if RO:  #compute tones freqs
        R1 = np.round(2**(np.array(-1, 1)*BW/2)*f0/df) 
        fr = df*(np.arange(R1[1],R1[2])).conj().T
    else:   #compute log-spaced tones freqs
        R1 = np.round(BW/2/df) 
        fr = f0*2**(np.arange(-R1,R1+1)*df).conj().T
    M = len(fr) # of component
    S = 0j*np.zeros((T1*SF/2)+1)  # memory allocation
    # fprintf(2, 'Freq.: %d .. %d Hz\n', round(min(fr)), round(max(fr)));

    fdx = np.round(np.dot(fr,T1))#+1;   # freq. index MATLAB INDEXING???
    x = np.log2(fr/f0)  # tono. axis (oct)

    # roll-off and phase relation
    r = 10**(-x*RO/20)  # roll-off, -x*RO = 20log10(r)
    if ph_c is not None:
        th = ph_c;
    else:
        th = 2*np.pi*np.random.rand(M,1)    # component phase, theta
        # print('randomize component phase')
    ph_c = th
    ph = (2*Om*x+Ph)*np.pi  # ripple phase, phi, modulation phase

    # modulation
    maxidx = np.zeros((M,2))
    maxidx[:,0] = fdx-Ri
    S[np.max(maxidx,axis=1).astype(int)] = S[np.max(maxidx,axis=1).astype(int)]+np.dot(r,np.exp(1j*(th-ph))) # lower side
    minidx = np.ones((M,2))
    minidx[:,0] = fdx+Ri
    minidx[:,1] = minidx[:,1] * T1*SF/2
    S[np.min(minidx, axis=1).astype(int)] = S[np.min(minidx, axis=1).astype(int)] + np.dot(r,np.exp(1j*(th+ph)))    # upper side
    S = S * Am/2
    S[0] = 0 
    S = S[:T1*SF/2]

    # original stationary spectrum
    S[fdx.astype(int)] = S[fdx.astype(int)] + r*np.exp(1j*th)  # moved here to save computation

    # time waveform
    s = ifft(np.concatenate((S, [0], np.flipud(S[1:T1*SF/2]).conj()))) # make it double side
    s = s[:int(np.round(T0*SF))].real   # only real part is good. *2 was ignored

    return [s, ph_c, fdx]

#TODO: add command line interface with argparse 
# def main():

# if __name__ == '__main__':
#     main()


