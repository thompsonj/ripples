
% D:\ripples\s02\logs\
% s02_run1_stimuli_timing_Jun_04_1006.txt
% D:\ripples\s01\prts\ripples_im_run1_1cond.prt
% D:\ripples\s01\prts\ripples_im_run1_allconds.prt
sub = 's06      '
if strcmp(sub, 's01')
    order = 'ABBA';
    comboruns = [2, 3, 6, 7];
    simpleruns = [1, 4, 5, 8];
    nruns=8;
elseif strcmp(sub, 's02') || strcmp(sub, 's03')
    order = 'ABBA';
    comboruns = [2, 3, 6, 7, 10, 11];
    simpleruns = [1, 4, 5, 8, 9, 12];
    nruns=12;
elseif strcmp(sub, 's04') || strcmp(sub, 's05') || strcmp(sub, 's06')
    order = 'BAAB';
    comboruns = [1, 4, 5, 8, 9, 12];
    simpleruns = [2, 3, 6, 7, 10, 11];
    nruns=12;
else
    error('Incorrect subject identifier');
end

% order = 'BAAB';
logdir = ['/Users/jthompson/data/ripples/' sub '/logs/'];
prtdir = ['/Users/jthompson/data/ripples/' sub '/prts/'];
% logdir = ['D:\ripples\' sub '\logs\'];
% prtdir = ['D:\ripples\' sub '\prts\'];

% logs = {'s03_run1_data4prts_Jun_24_1229.mat',
% 's03_run2_data4prts_Jun_24_1237.mat',
% 's03_run3_data4prts_Jun_24_1246.mat',
% 's03_run4_data4prts_Jun_24_1254.mat',
% 's03_run5_data4prts_Jun_24_1301.mat',
% 's03_run6_data4prts_Jun_24_1310.mat',
% 's03_run7_data4prts_Jun_24_1318.mat',
% 's03_run8_data4prts_Jun_24_1326.mat',
% 's03_run9_data4prts_Jun_24_1334.mat',
% 's03_run10_data4prts_Jun_24_1343.mat',
% 's03_run11_data4prts_Jun_24_1352.mat',
% 's03_run12_data4prts_Jun_24_1359.mat'};

for run=1:nruns
%     load([logdir 'stiminfo_run' int2str(run) '.mat']);
    logs = dir([logdir '*run' num2str(run) '_data4prts*']);
    load([logdir logs(end).name])
    silent = find(stimuliinfo(:,2)==0);
    stimuliinfo(silent,:) = [];
    stimuliinfo(:,1) = stimuliinfo(:,1) + 1; % to correct for apparent off by one error
    stiminfo_nosil = stimuliinfo;
    ccatch = find(stimuliinfo(:,2)==1);
    stimuliinfo(ccatch,:) = [];
    if ismember(run, comboruns)
        stimuliinfo(:,2) = stimuliinfo(:,2)+8;
        stiminfo_nosil(:,2) = stiminfo_nosil(:,2)+8;
        ccatch = find(stiminfo_nosil(:,2) == 9);
        stiminfo_nosil(ccatch,2) = 1;
        nvols = 168;
    else
        nvols = 150;
    end
    
    % Load template for 1cond
%     prt = xff('D:\ripples\s01\prts\ripples_im_run1_1cond.prt');
%     prt = xff('/Users/jthompson/data/ripples/s01/prts/ripples_s01_run1_1cond.prt');
%     % Save 1cond ceil
%     prt.Cond.OnOffsets = [stimuliinfo(:,1) stimuliinfo(:,1)];
%     prt.Cond.NrOfOnOffsets = size(stimuliinfo, 1);
%     prt.SaveAs(sprintf('%s%s_run%d_1cond_ceil.prt',prtdir, sub, run));
% %     
% %     % Make SDM file
%     sdmfile = prt.CreateSDM(struct('nvol',nvols,'prtr',2600,'rcond',[]));
%     sdmfile.SaveAs(sprintf('%s%s_run%d_1cond_ceil.sdm',prtdir, sub, run));
    
    % Save 1cond floor
%     stimuliinfo_floor = stimuliinfo;
%     stimuliinfo_floor(:,1) = stimuliinfo_floor(:,1)-1;
%     prt.Cond.OnOffsets = [stimuliinfo_floor(:,1) stimuliinfo_floor(:,1)];
%     prt.Cond.NrOfOnOffsets = size(stimuliinfo_floor, 1);
%     prt.SaveAs(sprintf('%s%s_run%d_1cond_floor.prt',prtdir, sub, run));
%     
%     % Make SDM file
%     sdmfile = prt.CreateSDM(struct('nvol',nvols,'prtr',2600,'rcond',[]));
%     sdmfile.SaveAs(sprintf('%s%s_run%d_1cond_floor.sdm',prtdir, sub, run));
    
%     % Save 1cond with catch trials
%     prt.Cond.OnOffsets = [stiminfo_nosil(:,1) stiminfo_nosil(:,1)];
%     prt.Cond.NrOfOnOffsets = size(stiminfo_nosil, 1);
%     prt.SaveAs(sprintf('%s%s_run%d_1cond_catch_ceil.prt',prtdir,sub,run));

%     clear prt
    
    % allconds prt
    % Load template for allconds
%     prt = xff('D:\ripples\s01\prts\ripples_s01_run1_allconds.prt');
%     prt = xff('/Users/jthompson/data/ripples/s01/prts/ripples_s01_run1_allconds.prt');
%     % Set on/offsets for each of the 92 unique stimuli
%     for c=1:92
%         inds = find(stimuliinfo(:,2)==c+1);
%         prt.Cond(c).NrOfOnOffsets = length(inds);
%         prt.Cond(c).OnOffsets = [stimuliinfo(inds, 1) stimuliinfo(inds, 1)];
%     end
    %     prt.SaveAs(sprintf('%s%s_run%d_allconds_ceil.prt',prtdir,sub,run));
    
    prt = xff('/Users/jthompson/data/ripples/s01/prts/allconds_simple_per_run.prt');
    % Set on/offsets for each of the 92 unique stimuli
    j=1;
    for c=1:8
        for r=1:length(simpleruns)
            prt.Cond(j).ConditionName = {sprintf('sound%d_%d',c,r)};
            prt.Cond(j).Weights = [];
            if simpleruns(r)==run
                inds = find(stimuliinfo(:,2)==c+1);
                prt.Cond(j).NrOfOnOffsets = length(inds);
                prt.Cond(j).OnOffsets = [stimuliinfo(inds, 1) stimuliinfo(inds, 1)];
            else
                prt.Cond(j).NrOfOnOffsets = 0;
                
                prt.Cond(j).OnOffsets = zeros(0,2);
            end
            j=j+1;
        end
    end
    for c=9:92
        prt.Cond(40+c).ConditionName = {sprintf('sound%d',c)};
        prt.Cond(40+c).Weights = [];
        inds = find(stimuliinfo(:,2)==c+1);
        prt.Cond(40+c).NrOfOnOffsets = length(inds);
        prt.Cond(40+c).OnOffsets = [stimuliinfo(inds, 1) stimuliinfo(inds, 1)];
    end
    
    prt.SaveAs(sprintf('%s%s_run%d_allconds_simple_per_run.prt',prtdir,sub,run));
    clear prt
end


%     mdm = xff('new:mdm');
%     prts = dir('prts\\*1cond.prt');
%     vtcs = dir('*.vtc');
%     mdm.XTC_RTC = [vtcs(:), prts(:)];
%     mdm.SaveAs('s02_1cond.mdm');
%     glm = mdm.ComputeGLM(struct('tfilter', 100,'tfilttype', 'fourier','ndcreg',12));

display('done')
