
% read in stimuli paths
clear
stimuli = loadtxt('stimuli_unfiltered.txt');
chLabel={'L','R'};

for stim = 1:size(stimuli,1)
    % read wav file
    [s,fs,bits]=wavread(stimuli{stim});
    for indCh=1:size(chLabel,2) % loop for channels
        [h,Fs]=load_filter(['EQF_219',chLabel{indCh},'.bin']);
        if Fs~=fs
            disp('Need to resample signal!'); 
            % resample to 44100 for filtering
            % Annoying that the sensimetrics function doesn't allow for variable
            % sample rates...
            s = resample(s,44100,fs);
        end;
        s_filt(:,indCh)=conv(h,s);
        s_filt(:,indCh) = s_filt(:,indCh)/(max(abs(s_filt(:,indCh))));
        sound(s_filt)
    end % loop for channels
    % save s_filt to fmri_exp directory
    [pathstr,base,ext] = fileparts(stimuli{stim});
    wavwrite(s_filt, Fs, ['../stimuli/' base '_filtered.wav'])
    clear s_filt
end