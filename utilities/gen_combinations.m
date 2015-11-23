% Generate linear combinations of perceptually distinct dynamic ripples
clear
% para
% Modulation depth
%Am = [.9 .9];
Am = .9;
% Rate
% Rt = [2 4 6 8];
Rt = [2 6];

% Scale
% Om = [.17 .7 1.7 2.7];
Om = [0.7 1.7];

% Phase
%Ph = [0 0]; 
Ph = 0;

%cond
% Duration
T0 = 1;

% f0
% f0 = [132.5 171 210 249];
f0 = [132.5 210];

% Sample Frequency
% SF =16384;
SF =44100;
SF = 16000;

% Excitation band width (oct)
BW = 5.8;

% Roll-off
RO = 0;

% freq spacing
df = 1/16;

% Component phase
ph_c = [];

% Envelope
env = ones(SF,1);
tenms = round(SF/100);
env(1:tenms+1) = 0:1/tenms:1;
env(end-tenms:end) = 1:-1/tenms:0;

% Total counts
n_simple = length(f0) * length(Om) * length(Rt);
n_mix = 3*(n_simple^2 -n_simple)/2;
n_total = n_simple + n_mix;

% Create matrix to hold the 6D description of each stimulus where each
% column indicates the presence of f01, f02, Rt1, Rt2, Om1, Om2
feature = zeros(n_total,6);

% Directory name
% dir_name = '../stimuli-Jan-2015';
dir_name = 'D:\ripples\stimuliEncoding';

%% Make simple dynamic ripples
i=1;
fileID = fopen('filenames.txt','w');
for freq=1:length(f0)
    for rate= 1:length(Rt)
        for scale = 1:length(Om)
            para = [Am, Rt(rate), Om(scale), Ph];
            cond = [T0, f0(freq), SF, BW, RO, df];
            [s, ph_c, fdx] = mvripfft(para, cond, ph_c);
            s = env.*((s/max(abs(s))));
            ripples(i).freq = f0(freq);
            ripples(i).rate = Rt(rate);
            ripples(i).scale = Om(scale);
            ripples(i).s = s;
            basename = sprintf('f0%g_Rt%d_Om%g.wav', f0(freq),Rt(rate),Om(scale))
            fname = sprintf('%s/%s',dir_name, basename)
            fprintf(fileID, '%s\n', basename);
            
            wavwrite(s, SF, fname);
            
            features(i,freq) = 1;
            features(i,rate+2) = 1;
            features(i,scale+4) = 1;
            i = i+1;
        end
    end
end

%%
% Weighted sum of symmetric pairs of ripples
for j = 1:8%length(ripples)
    for k = 1:8%length(ripples)
        
        if k >= j
            break
        else
            %1:1 ratio
            mix = (ripples(j).s + ripples(k).s);
            mix = mix/max(abs(mix));
            basename = sprintf('MIX1to1-f0%g_Rt%d_Om%g-f0%g_Rt%d_Om%g.wav',ripples(j).freq,ripples(j).rate,ripples(j).scale,ripples(k).freq,ripples(k).rate,ripples(k).scale);
            fname = sprintf('%s/%s',dir_name,basename)
            fprintf(fileID, '%s\n', basename);
            wavwrite(mix, SF, fname);
            features(i,:) = (features(j,:) + features(k,:))/2;
            
            %1:2 ratio
            mix = (.5*ripples(j).s + ripples(k).s);
            mix = mix/max(abs(mix));
            basename = sprintf('MIX1to2-f0%g_Rt%d_Om%g-f0%g_Rt%d_Om%g.wav',ripples(j).freq,ripples(j).rate,ripples(j).scale,ripples(k).freq,ripples(k).rate,ripples(k).scale);
            fname = sprintf('%s/%s',dir_name,basename)
            fprintf(fileID, '%s\n', basename);
            wavwrite(mix, SF, fname);
            features(i+1,:) = (.5*features(j,:) + features(k,:))/2;
            features(i+1,features(i+1,:)==.75) = 1;
            features(i+1,features(i+1,:)==.25) = 1/3;
            features(i+1,features(i+1,:)==.5) = 2/3;
            
            %2:1 ratio
            mix = (ripples(j).s + .5*ripples(k).s);
            mix = mix/max(abs(mix));
            basename = sprintf('MIX2to1-f0%g_Rt%d_Om%g-f0%g_Rt%d_Om%g.wav',ripples(j).freq,ripples(j).rate,ripples(j).scale,ripples(k).freq,ripples(k).rate,ripples(k).scale);
            fname = sprintf('%s/%s',dir_name,basename)
            fprintf(fileID, '%s\n', basename);
            wavwrite(mix, SF, fname);
            features(i+2,:) = (features(j,:) + .5*features(k,:))/2;
            features(i+2,features(i+2,:)==.75) = 1;
            features(i+2,features(i+2,:)==.25) = 1/3;
            features(i+2,features(i+2,:)==.5) = 2/3;
            
            i = i+3;
        end
    end
end
fclose(fileID);
% Equalize features
% features(:,1:2) = 1-sum(features(:,1:2),2) 
% dlmwrite('ripple_features.tab', features)

%% Make wavs for silent and catch trials

% Make dynamic ripple 500ms long 
T0 = .5;
para = [Am, Rt(1), Om(1), Ph];
cond = [T0, f0(2), SF, BW, RO, df];
[s, ph_c, fdx] = mvripfft(para, cond, ph_c);

% Envelope
env = ones(SF/2,1);
tenms = round(SF/2/100);
env(1:tenms+1) = 0:1/tenms:1;
env(end-tenms:end) = 1:-1/tenms:0;

s = env.*((s/max(abs(s))));
fname = sprintf('%s/catch.wav',dir_name)
wavwrite(s, SF, fname);

% Make silent wave
silence = zeros(SF,1);
fname = sprintf('%s/silence.wav',dir_name)
wavwrite(silence, SF, fname);

% %% Make extreme ripples
% clear
% % para
% % Modulation depth
% %Am = [.9 .9];
% Am = .9;
% % Rate
% % Rt = [2 4 6 8];
% Rt = [2 26];
% 
% % Scale
% % Om = [.17 .7 1.7 2.7];
% Om = [.16 2.7];
% 
% % Phase
% %Ph = [0 0]; 
% Ph = 0;
% 
% %cond
% % Duration
% T0 = 1;
% 
% % f0
% % f0 = [132.5 171 210 249];
% f0 = [100 400];
% 
% % Sample Frequency
% SF =16384;
% 
% % Excitation band width (oct)
% BW = 5.8;
% 
% % Roll-off
% RO = 0;
% 
% % freq spacing
% df = 1/16;
% 
% % Component phase
% ph_c = [];
% 
% % Envelope
% env = ones(SF,1);
% env(1:11) = 0:1/10:1;
% env(end-10:end) = 1:-1/10:0;
% 
% % Directory name
% dir_name = 'stimuli-Jan-2015/extreme';
% 
% % Make simple dynamic ripples
% i=1;
% for freq=1:length(f0)
%     for rate= 1:length(Rt)
%         for scale = 1:length(Om)
%             para = [Am, Rt(rate), Om(scale), Ph];
%             cond = [T0, f0(freq), SF, BW, RO, df];
%             [s, ph_c, fdx] = mvripfft(para, cond, ph_c);
%             s = env.*((s/max(abs(s))));
%             ripples(i).freq = f0(freq);
%             ripples(i).rate = Rt(rate);
%             ripples(i).scale = Om(scale);
%             ripples(i).s = s;
%             fname = sprintf('%s/f0%g_Rt%d_Om%g.wav',dir_name, f0(freq),Rt(rate),Om(scale))
%             wavwrite(s, SF, fname);
%             i = i+1;
%         end
%     end
% end
% 
% %%
% % Weighted sum of symmetric pairs of extreme ripples
% for j = 1:length(ripples)
%     for k = 1:length(ripples)
%         
%         if k >= j
%             break
%         else
%             %1:1 ratio
%             mix = (ripples(j).s + ripples(k).s);
%             mix = mix/max(abs(mix));
%             fname = sprintf('%s/mixtures/MIX-f0%g_Rt%d_Om%g-f0%g_Rt%d_Om%g.wav',dir_name,ripples(j).freq,ripples(j).rate,ripples(j).scale,ripples(k).freq,ripples(k).rate,ripples(k).scale)
%             wavwrite(mix, SF, fname);
%             
%         end
%     end
% end