#!/usr/bin/env python2
"""
Determine the parameter range within which dynamic ripples are perceived as one auditory 
object using a transformed up-down adaptive staircase method. The purpose of this experiment
is to verify that our proposed stimuli for an upcoming fMRI experiment do not invoke
auditory streaming.

Summations of two 1-second dynamic ripples are presented. The parameters evaluated in this 
experiment are the difference in fundamental frequency (f0) and temporal modulation rate (Rt)
between the two summed ripples. We do not investigate the interaction between these parameters.
We first look at f0, a strong streaming cue, independent on Rt and spectral scale (Om). The 
first trials use f0 in the centre of our proposed stimuli range and the staircase procedure 
gradually increases f0 difference, while maintaining the mean/centre f0. A second staircase 
procedure is performed on the Rt difference, while keeping the f0 difference fixed to the 
average of the final 6 reversals in the previous f0 staircase. Om difference is not investigated since
it is not known to be a streaming cue. In both staircases, Om is set randomly within the 
proposed range. 

 
"""
import os
from psychopy import core, visual, sound, gui, data, event, logging, prefs
from psychopy.tools.filetools import fromFile, toFile
import time, numpy, random
from mvripfft import mvripfft
logging.console.setLevel(logging.DEBUG)#get messages about the sound lib as it loads
if prefs.general['audioLib'][0] == 'pyo':
    #if pyo is the first lib in the list of preferred libs then we could use small buffer
    #pygame sound is very bad with a small buffer though
    sound.init(16384,buffer=128)
print 'Using %s(with %s) for sounds' %(sound.audioLib, sound.audioDriver)

home = '..'
#if not os.path.isdir(home):
#    os.mkdir(home)
try:#try to get a previous parameters file
    expInfo = fromFile(os.path.join(home,'lastRipParams.pickle'))
except:#if not there then use a default set
    # STARTING RIPPLE PARAMETERS
    Am = .9         # Modulation depth
    Rt = 6          # Rate
    Om = 1.7        # Scale
    Ph = 0.         # Phase
    T0 = 1.         # Duration
    f0 = 171.25     # f0
    SF =16384       # Sample Frequency
    BW = 5.8        # Excitation band width (oct)
    RO = 0          # Roll-off
    df = 1./16      # freq spacing
    ph_c = None     # Component phase
    expInfo = {'subject':'jt', 
        'Am':Am, 
        'Rt':Rt, 
        'Om':Om, 
        'Ph':Ph, 
        'T0':T0,
        'f0':f0, 
        'SF':SF, 
        'BW':BW, 
        'RO':RO, 
        'df':df,
        'ph_c':ph_c,
        'f0Diff': None,
        'debug':True,
        'save_dir':home}
dateStr = time.strftime("%b_%d_%H%M", time.localtime())#add the current time

#present a dialogue to change params
dlg = gui.DlgFromDict(expInfo, title='Ripple listening test', fixed=['date'])
if dlg.OK:
    toFile(os.path.join(home,'lastRipParams.pickle'), expInfo)#save params to file for next time
else:
    core.quit()#the user hit cancel so exit
    
# Create log file
logfname = os.path.join(home, 'logs',expInfo['subject'] +'_'+ dateStr+'.log')
lastLog=logging.LogFile(logfname, level=logging.INFO, filemode='a')

#make text files to save data and training data
fileName = os.path.join(home, 'data',expInfo['subject'] +'_'+ dateStr)
dataFile = open(fileName+'.txt', 'w')
dataFile.write('f01	f02	Rt1	Rt2	Om1	Om2	f0diff	Objects\n')
trainfileName = os.path.join(home, 'data',expInfo['subject'] +'_training_'+ dateStr)
TrainingdataFile = open(trainfileName+'.txt', 'w')
TrainingdataFile.write('f01	f02	Rt1	Rt2	Om1	Om2	Objects\n')

#create window and initial stimuli
#globalClock = core.Clock()#to keep track of time
if expInfo['debug'] == True:
    win = visual.Window([1000,800],allowGUI=False, monitor='testMonitor', units='deg')
else:
    win = visual.Window(allowGUI=False, monitor='testMonitor', units='deg', fullscr=True)    
s1 = mvripfft(f0=expInfo['f0'],Rt = expInfo['Rt'], Om = expInfo['Om'])[0]
s2 = mvripfft(f0=expInfo['f0'],Rt = expInfo['Rt'], Om = expInfo['Om'])[0]
mix = (s1 + s2)/2 # avoid DC offset
# apply smooth onset and offset envelope
env =  numpy.ones(expInfo['T0'] * expInfo['SF'])
rampsamples = numpy.round((expInfo['SF']*.01)/2)
ham = numpy.hamming(rampsamples*2)
env[:rampsamples-1] = ham[:rampsamples-1]
env[-rampsamples:] = ham[-rampsamples:]
mix=mix*env
# normalize to all have peak amplitude of 1
mix = mix/(max(abs(mix))) 
#print '0max(abs(mix)): ', max(abs(mix))
ripMix = sound.Sound(mix,sampleRate=expInfo['SF'])
ripMix.setVolume(.9)

#create the staircase handler for f0 difference
f0DifferenceStaircase = data.StairHandler(startVal = 0,
                   stepType = 'lin', stepSizes=5., 
                   minVal=0, maxVal=(expInfo['f0']-40) *2, # Set max such that lowest f0 is never less than 40 Hz
                   nUp=1, nDown=3,  #will hone in on the 80% threshold
                   nTrials=100,
                   extraInfo = {'param':'f0'})
#create the staircase handler for Rt difference                
RtDifferenceStaircase = data.StairHandler(startVal = 0,
                   stepType = 'lin', stepSizes=.2, 
                   minVal=0, maxVal=(expInfo['Rt'] -1.5)*2,# Set max such that lowest Rt is never less than 1.5 Hz
                   nUp=1, nDown=3,  #will hone in on the 80% threshold
                   nTrials=100,
                   extraInfo = {'param':'Rt'})
Staircases = [f0DifferenceStaircase, RtDifferenceStaircase]

#display instructions and wait
fixation = visual.GratingStim(win, color='black', tex=None, mask='circle',size=0.2)
Instr0 = visual.TextStim(win, pos=[0,+3], text='Please read the following instructions carefully.')
tocontinue = visual.TextStim(win, pos=[0,-8], text='Press any key to continue.')

Instr1 = visual.TextStim(win, pos=[0,+3], text='This experiment is about automatic auditory streaming. An auditory stream is a sequence of sounds that are perceived as coming from the same source.')
Instr2 = visual.TextStim(win, pos=[0,+4], text='For example, in music, sequences of sounds from difference instruments form distinct auditory streams.')
musicStreaming = visual.ImageStim(win,pos=[0,-3],image=os.path.join(home,'musicstreaming.png'))
Instr3 = visual.TextStim(win, pos=[0,+3], text='You will be presented with several short sounds and asked to indicate whether you automatically (meaning without directing your attention) hear one or two streams.')
Instr4 = visual.TextStim(win, pos=[0,+3], text='The experiment will be split into 2 runs. For the first few sounds, you should hear only one stream. Eventually, the decision may become more difficult. Press 1 when you hear one sound and 2 when you hear two sounds. Only press 2 when you definitely hear two streams.')
Vol0 = visual.TextStim(win, pos=[0,+4], text='Volume test: A sound will now be played so that the experimenter can adjust the volume if necessary.')
Vol1 = visual.TextStim(win, pos=[0,+4], text='Volume test: Press any key when the volume level is set.')

Train0 = visual.TextStim(win, pos=[0,+5],text='Let\'s start with a few practice trials.')
Train1 = visual.TextStim(win, pos=[0,+7],text='Now we will begin with the main experiment. It should take approximately 20 minutes to complete.')

message1 = visual.TextStim(win, pos=[0,+3],text='Hit any key when ready.')
message2 = visual.TextStim(win, pos=[0,-3], text="Then press 1 if you hear one sound and 2 if you hear two sounds.")
message3 = visual.TextStim(win, pos=[0,+4],text='Run 1')
message4 = visual.TextStim(win, pos=[0,+5],text='Run 2')

Instr0.draw()
tocontinue.draw()
win.flip()
event.waitKeys() #check for a keypress

Instr1.draw()
tocontinue.draw()
win.flip()
event.waitKeys()

Instr2.draw()
musicStreaming.draw()# image describing auditory streaming example
tocontinue.draw()
win.flip()
event.waitKeys()

Instr3.draw()
tocontinue.draw()
win.flip()
event.waitKeys()

Instr4.draw()
tocontinue.draw()
win.flip()
event.waitKeys()

Vol0.draw()
tocontinue.draw()
win.flip()
s = mvripfft(f0=171.25, Rt=6, Om=1.7)[0]
s = s/(max(abs(s)))
testsound = sound.Sound(s,sampleRate=expInfo['SF'], loops=-1)
testsound.setVolume(.9)
event.waitKeys()

Vol1.draw()
win.flip()
# loop sound
testsound.play()
event.waitKeys()
testsound.stop()
# stop sound

Train0.draw()
message1.draw()
message2.draw()
fixation.draw()
win.flip()
event.waitKeys() #check for a keypress

def getResp():
    thisResp=None
    thisObjects=None
    while thisResp is None:
        allKeys=event.waitKeys()
        for thisKey in allKeys:
            if thisKey=='1':
                thisResp = 0    # one object
                thisObjects = 1
            elif thisKey=='2':
                thisResp = 1    #two objects
                thisObjects = 2
            elif thisKey in ['q', 'escape']:
                core.quit()#abort experiment
    event.clearEvents('mouse')#only really needed for pygame windows
    return thisResp,thisObjects
    
# Run training phase    
trainf01 = [171.25, 171.25, 180, 175, 300, 250, 100,80]  
trainf02 = [171.25, 171.25, 171.25, 170, 70,90, 310,270]
trainRt1 = [6, 6.5, 6, 6, 8, 16, 4, 2,3] 
trainRt2 = [6, 5.5, 5, 4, 2, 4, 16,8,15]
trainOm1 = [1.7, 1.7, 1.7, 1.7, 1.7, 1.7,1.7,1.7] 
trainOm2 = [1.7, 1.6, 1.6, 1.5, 0.7, 0.7,1.,2.7]
for t in range(len(trainf01)):
    f01 = trainf01[t]
    f02 = trainf02[t]
    Rt1 = trainRt1[t]
    Rt2 = trainRt2[t]
    Om1 = trainOm1[t]
    Om2 = trainOm2[t]
    # generate new sound mixture
    s1 = mvripfft(f0=f01, Rt=Rt1, Om=Om1)[0]
    s2 = mvripfft(f0=f02, Rt=Rt2, Om=Om2)[0]
    mix = (s1 + s2)/2 # avoid DC offset
    mix=mix*env # apply smooth onset and offset envelope
    mix = mix/(max(abs(mix))) # normalize to all have peak amplitude of 1
    ripMix = sound.Sound(mix,sampleRate=expInfo['SF'])
    ripMix.setVolume(.9)

    # Play stimuli
    core.wait(1.)
    ripMix.play()
    win.flip()

    core.wait(1.)#wait 1000ms (use a loop of x frames for more accurate timing)

    #blank screen
    fixation.draw()
    win.flip()

    #get response
    thisResp,thisObjects = getResp()

    # Record the data in the training data file
    TrainingdataFile.write('%.3f	%.3f	%.3f	%.3f	%.3f	%.3f	%i\n' %(f01, f02, Rt1, Rt2, Om1, Om2, thisObjects))
TrainingdataFile.close()

Train1.draw() # Tell the subject that the main experiment will start now
message3.draw()
message1.draw()
message2.draw()
fixation.draw()
win.flip()
event.waitKeys() #check for a keypress

# Run main experiment
for staircase in Staircases:
    if staircase.extraInfo['param'] == 'Rt':
        expInfo['f0Diff'] = numpy.average(f0DifferenceStaircase.reversalIntensities[-6:])
        message4.draw()
        message2.draw()
        fixation.draw()
        win.flip()
        event.waitKeys() #check for a keypress
    for thisdifference in staircase: #will step through the staircase
        print 'thisdifference: ', thisdifference
        # update f0
        if staircase.extraInfo['param'] == 'f0':
            f01 = expInfo['f0'] - (thisdifference/2)
            f02 = expInfo['f0'] + (thisdifference/2)
        else: # sfix f0 to values to be within range determined in first staircase
           f01 = expInfo['f0'] - ((expInfo['f0Diff']/2)-5)
           f02 = expInfo['f0'] + ((expInfo['f0Diff']/2)-5)
        if staircase.extraInfo['param'] == 'Rt':
            # randomly assign low and high rates to low and high f0
            if numpy.round(random.random()):
                Rt1 = expInfo['Rt'] - (thisdifference/2)
                Rt2 = expInfo['Rt'] + (thisdifference/2)
            else:
                Rt1 = expInfo['Rt'] + (thisdifference/2)
                Rt2 = expInfo['Rt'] - (thisdifference/2)
        else:        
            # set temporal modulation rate randomly within range [1.5 10.5]
            Rt1 = (random.random()*9)+1.5
            Rt2 = (random.random()*9)+1.5
    
        # set spectral scale randomly within range [.7 1.7]
        Om1 = (random.random())+.7
        Om2 = (random.random())+.7
        
        print 'f01, f02: ', f01, f02
        print 'Rt1, Rt2: ', Rt1, Rt2
        print 'Om1, Om2: ', Om1, Om2
        
        # generate new sound mixture
        s1 = mvripfft(f0=f01,Rt = Rt1, Om = Om1)[0]
        s2 = mvripfft(f0=f02,Rt = Rt2, Om = Om2)[0]
        mix = (s1 + s2)/2 # avoid DC offset
        mix=mix*env # apply smooth onset and offset envelope
        mix = mix/(max(abs(mix))) # normalize to all have peak amplitude of 1
        print 'max(abs(mix)): ', max(abs(mix))
        ripMix = sound.Sound(mix,sampleRate=expInfo['SF'])
        ripMix.setVolume(.9)
    
        # Play stimuli
        core.wait(1.)
        ripMix.play()
        win.flip()
    
        core.wait(1.)#wait 1000ms (use a loop of x frames for more accurate timing)
    
        #blank screen
        fixation.draw()
        win.flip()
    
        #get response
        thisResp,thisObjects = getResp()
    
        #add the data to the staircase so it can calculate the next level
        staircase.addResponse(thisResp)
        dataFile.write('%.3f	%.3f	%.3f	%.3f	%.3f	%.3f	%.3f	%i\n' %(f01, f02, Rt1, Rt2, Om1, Om2, thisdifference, thisObjects))

#staircases have ended
dataFile.close()

f0DifferenceStaircase.saveAsPickle(fileName)#special python binary file to save all the info
RtDifferenceStaircase.saveAsPickle(fileName)

#give some output to user
print 'f0 reversals:'
print f0DifferenceStaircase.reversalIntensities
print 'mean f0 difference of final 6 reversals = %.3f' %(numpy.average(f0DifferenceStaircase.reversalIntensities[-6:]))
print 'variance f0 difference of final 6 reversals = %.3f' %(numpy.var(f0DifferenceStaircase.reversalIntensities[-6:]))
print 'Rt reversals:'
print RtDifferenceStaircase.reversalIntensities
print 'mean Rt difference of final 6 reversals = %.3f' %(numpy.average(RtDifferenceStaircase.reversalIntensities[-6:]))
print 'variance Rt difference of final 6 reversals = %.3f' %(numpy.var(RtDifferenceStaircase.reversalIntensities[-6:]))

core.quit()


