function makeSDMs(HRF, minus, dim, scaled, MC, subs, feat)
% makeSDMs - Make various design matrix files for running GLMs in BVQX
% Saves design matrices describing ripple stimuli in fMRI experiment
%
% Syntax:  makeSDMs(HRF, minus, dim, scaled, MC, subs)
%
% Inputs:
%    HRF - 1 to apply canonical hrf. 2 to deconvlve. 0 none
%    minus - 1 to use minus predictors (e.g. f01-f02), 0 for just f01
%    dim - Current options: 4, 5, 13, 15 (could add 3 maybe 6)
%          if 5: separate sdms will be made for each f0, Rt, Om
%    scaled - 1 if scaledd (default), 0 if flat
%    MC - 1 if add motion correction preds, 0 otherwise (default)
%    subs - Optional. Cell array of subject identifiers. Default all subs.
%    feat - If dim=5, feat specifies which feature to save: 1 (f0), 2(Rt),
%           3(Om)
%
% Outputs:
%    Nothing returned, saves .sdm files
%
% Example: 
%    makeSDMs(2, 1, 4, 1, 0, {'s01'})
%    makeSDMs(2, 1, 4, 1, 0, {'s01','s02', 's03', 's04', 's05', 's06'})
%    makeSDMs(1, 1, 4, 1, 1, {'s01','s02', 's03', 's04', 's05', 's06'})
%    makeSDMs(1, 0, 15, 1, 0, {'s02'})
%    makeSDMs(1, 0, 5, 1, 0, {'s02'}, 2)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: 

% Author: Jessica Thompson

% Summer 2015; Last revision: 

%------------- BEGIN CODE --------------

% Process input arguments
if nargin < 7 && dim == 5
    feat = 1;
end
if nargin < 6
    subs = {'s01', 's02', 's03', 's04', 's05', 's06'};
end
if nargin < 5
    MC=0;
end
if nargin < 4
    scaled = 1;
end
nstick = 8;
nfeatures = dim + (HRF==2)*dim*(nstick-1);
os = getenv('OS');
if strfind(os, 'Windows')
    datadir = 'D:\ripples\';
else 
    datadir = '/Users/jthompson/Dropbox/ripples/';
end
MC_pred_names = {'Trans-X', 'Trans-Y', 'Trans-Z', ...
                    'Rot-X', 'Rot-Y', 'Rot-Z'};
feats = {'f0', 'Rt', 'Om'};
for s=1:length(subs)
    sub = subs{s};
    display(sub);
    if strcmp(sub, 's01')
        order = 'ABBA';
        comboruns = [2, 3, 6, 7];
        nruns=8;
    elseif strcmp(sub, 's02') || strcmp(sub, 's03')
        order = 'ABBA';
        comboruns = [2, 3, 6, 7, 10, 11];
        nruns=12;
    elseif strcmp(sub, 's04') || strcmp(sub, 's05') || strcmp(sub, 's06')
        order = 'BAAB';
        comboruns = [1, 4, 5, 8, 9, 12];
        nruns=12;
    end
    subjdir = [datadir sub filesep];
    sounddir = [datadir 'StimuliEncoding' filesep];
    logdir = [subjdir  'logs' filesep];
%     prtdir = [subjdir filesep 'prts' filesep];
    sdmdir = [subjdir  'sdms' filesep];

    % Load ripple indicator features (3D) in variable 'features'
    % Order of features is f01, f02, Rt1, Rt2, Om1, Om2
    % Feature values indicate relative presence from 0 to 1
    load([sounddir 'ripple_features_6d.mat']);

    % Load order of sound Decomp
    load([datadir 'SoundOrderIdxintoMixMat.mat'])

    for run=1:nruns
        % Load SDM
        sdm = xff(sprintf('%s%s_run%d_1cond_ceil.sdm', sdmdir, sub, run));
        % Load order of presentation
        fname = dir([logdir '*run' num2str(run) '_data4prts_*']);
        load([logdir fname(end).name]);
        silent = find(stimuliinfo(:,2)==0);
        stimuliinfo(silent,:) = []; % Remove silent trials
        stimuliinfo(:,1) = stimuliinfo(:,1) + 1; % ceil instead of floor
        ccatch = find(stimuliinfo(:,2)==1);
        stimuliinfo(ccatch,:) = []; % Remove catch trials
        if ismember(run, comboruns)
            stimuliinfo(:,2) = stimuliinfo(:,2)+8;
            nvols = 168;
            runtype='combo';
        else
            nvols = 150;
            runtype='simple';
        end
        stiminfo_decomp = stimuliinfo;
        % -1 becauase 0 and 1 in stimuliinfo refer to silent / catch trials
        stiminfo_decomp(:,2) = stiminfo_decomp(:,2)-1; 
        % reorder to match indices used in presentation
        stiminfo_decomp(:,2) = idx(stiminfo_decomp(:,2));
        % Initialize basic 6D features and unchanging properties
        RI_6D = zeros(nvols,6);
        RI_6D(stiminfo_decomp(:,1),:) = features(stiminfo_decomp(:,2),:);
        npredictors = nfeatures +1 + MC*6 ;
        sdm.SDMMatrix = zeros(nvols,npredictors);
        sdm.NrOfPredictors = npredictors;
        sdm.IncludesConstant = 1;
        sdm.FirstConfoundPredictor = nfeatures + 1;
        fname = '';
        colors = [[255 175 0]; [0 175 65]; [255 0 65]];
        black = [255 255 255];
        switch dim
            case 4
                sdm.PredictorColors = cat(1, colors, black);
                if minus 
                    fname = [fname '_minus'];
                    sdm.SDMMatrix(:,1) = RI_6D(:,1)-RI_6D(:,2);
                    sdm.SDMMatrix(:,2) = RI_6D(:,3)-RI_6D(:,4);
                    sdm.SDMMatrix(:,3) = RI_6D(:,5)-RI_6D(:,6);
                    sdm.SDMMatrix(:,4) = RI_6D(:,1)+RI_6D(:,2);
                    
                    if scaled
                        fname = [fname '_scaled'];
                        sdm.PredictorNames = {'f01-f02_scaled', ...
                            'Rt1-Rt2_scaled', 'Om1-Om2_scaled', 'SoundOn'};
                    else
                        fname = [fname '_flat'];
                        sdm.PredictorNames = {'f01-f02_flat', ...
                            'Rt1-Rt2_flat', 'Om1-Om2_flat', 'SoundOn'};
                        sdm.SDMMatrix = (abs(sdm.SDMMatrix)>0)*1;
                    end
                else
                    sdm.SDMMatrix(:,1:3) = RI_6D(:,[1,3,5]);
                    sdm.SDMMatrix(:,4) = RI_6D(:,1)+RI_6D(:,2);
                    if scaled
                        fname = [fname '_scaled'];
                        sdm.PredictorNames = {'f01_scaled', 'Rt1_scaled', ...
                            'Om1_scaled', 'SoundOn'};
                    else
                        fname = [fname '_flat'];
                        sdm.PredictorNames = {'f01_flat', 'Rt1_flat', ...
                            'Om1_flat', 'SoundOn'};
                        sdm.SDMMatrix = (sdm.SDMMatrix>0)*1;
                    end
                end
            case 5
                sdm.PredictorColors = repmat(colors, 5, 1);
                %sdm.PredictorColors = cat(1, sdm.PredictorColors, black);
                if minus
                    fname = [fname '_minus'];
                    sdm.PredictorNames = {'f01-f01=-1', 'Rt1-Rt2=-1', ...
                        'Om1-Om2=-1', ...
                        'f01-f01=-33', 'Rt1-Rt2=-33', 'Om1-Om2=-33', ...
                        'f01-f01=0', 'Rt1-Rt2=0', 'Om1-Om2=0', ...
                        'f01-f01=33', 'Rt1-Rt2=33','Om1-Om2=33', ...
                        'f01-f01=1', 'Rt1-Rt2=1', 'Om1-Om2=1'};
%                     RI4D_minus(:,1) = RI_6D(:,1)-RI_6D(:,2);
%                     RI4D_minus(:,2) = RI_6D(:,3)-RI_6D(:,4);
%                     RI4D_minus(:,3) = RI_6D(:,5)-RI_6D(:,6);
%                     SoundOn = RI_6D(:,1)+RI_6D(:,2);
%                     sdmMatm1 = RI4D_minus==-1;
%                     sdmMatm33 = RI4D_minus==-1/3;
%                     sdmMat33 = RI4D_minus==1/3;
%                     sdmMat1 = RI4D_minus==1;
% 
%                     % Concatenate matrices to give 4*3 = 12 predictors
%                     sdm.SDMMatrix = cat(2, sdmMatm1, sdmMatm33, ...
%                         sdmMat33, sdmMat1, SoundOn);
                else
                    sdm.PredictorNames = {'f01=0', 'Rt1=0', 'Om1=0', ...
                        'f01=33', 'Rt1=33', 'Om1=33', ...
                        'f01=05', 'Rt1=05', 'Om1=05', ...
                        'f01=66', 'Rt1=66', 'Om1=66', ...
                        'f01=1', 'Rt1=1', 'Om1=1'};
                    % f01, Rt1 and Om1 are 0 when f02, Rt2 and Om2 are 1
                    sdmMat00 = RI_6D(:,[2,4,6])==1; 
                    sdmMat33 = RI_6D(:,[1,3,5])==1/3;
                    sdmMat05 = RI_6D(:,[1,3,5])==1/2;
                    sdmMat66 = RI_6D(:,[1,3,5])==2/3;
                    sdmMat1 = RI_6D(:,[1,3,5])==1;
                    sdm.SDMMatrix = cat(2, sdmMat00, sdmMat33, ...
                        sdmMat05, sdmMat66, sdmMat1)*1; % to make doubles
                end
                % Reorder to help with visual inspection
                % f01(0 to 1), Rt1 (0 to 1), Om (0 to 1)
                reorder = [1 4 7 10 13 2 5 8 11 14 3 6 9 12 15];
                sdm.SDMMatrix = sdm.SDMMatrix(:,reorder);
                sdm.PredictorNames = sdm.PredictorNames(reorder);
                sdm.PredictorColors = sdm.PredictorColors(reorder,:);
                % take only 5 predictors for specified feature
                featidx = 1+(5*(feat-1));
                fname = [fname '_' feats{feat}];
                sdm.SDMMatrix = sdm.SDMMatrix(:,featidx:featidx+4);
                sdm.PredictorNames = sdm.PredictorNames(featidx:featidx+4);
                sdm.PredictorColors = sdm.PredictorColors(featidx:featidx+4, :);
            case 13
                sdm.PredictorColors = repmat(colors, 4, 1);
                sdm.PredictorColors = cat(1, sdm.PredictorColors, black);
                if minus
                    fname = [fname '_minus'];
                    sdm.PredictorNames = {'f01-f01=-1', 'Rt1-Rt2=-1', ...
                        'Om1-Om2=-1', 'f01-f01=-33', 'Rt1-Rt2=-33', ...
                        'Om1-Om2=-33', 'f01-f01=33', 'Rt1-Rt2=33', ...
                        'Om1-Om2=33', 'f01-f01=1', 'Rt1-Rt2=1', 'Om1-Om2=1', ...
                        'SoundOn'};
                    RI4D_minus(:,1) = RI_6D(:,1)-RI_6D(:,2);
                    RI4D_minus(:,2) = RI_6D(:,3)-RI_6D(:,4);
                    RI4D_minus(:,3) = RI_6D(:,5)-RI_6D(:,6);
                    SoundOn = RI_6D(:,1)+RI_6D(:,2);
                    sdmMatm1 = RI4D_minus==-1;
                    sdmMatm33 = RI4D_minus==-1/3;
                    sdmMat33 = RI4D_minus==1/3;
                    sdmMat1 = RI4D_minus==1;

                    % Concatenate matrices to give 4*3 = 12 predictors
                    sdm.SDMMatrix = cat(2, sdmMatm1, sdmMatm33, ...
                        sdmMat33, sdmMat1, SoundOn);
                else
                    sdm.PredictorNames = {'f01=33', 'Rt1=33', 'Om1=33', ...
                        'f01=05', 'Rt1=05', 'Om1=05', 'f01=66', 'Rt1=66', ...
                        'Om1=66', 'f01=1', 'Rt1=1', 'Om1=1', 'SoundOn'}
                    sdmMat33 = RI_6D(:,[1,3,5])==1/3;
                    sdmMat05 = RI_6D(:,[1,3,5])==1/2;
                    sdmMat66 = RI_6D(:,[1,3,5])==2/3;
                    sdmMat1 = RI_6D(:,[1,3,5])==1;
                    SoundOn = RI_6D(:,1)+RI_6D(:,2);
                    sdm.SDMMatrix = cat(2, sdmMat33, sdmMat05, sdmMat66, ...
                        sdmMat1, SoundOn);
                end
                % Reorder to help with visual inspection
                reorder = [1 4 7 10 2 5 8 11 3 6 9 12 13];
                sdm.SDMMatrix = sdm.SDMMatrix(:,reorder);
                sdm.PredictorNames = sdm.PredictorNames(reorder);
                sdm.PredictorColors = sdm.PredictorColors(reorder, :);
            case 15
                sdm.PredictorColors = repmat(colors, 5, 1);
                %sdm.PredictorColors = cat(1, sdm.PredictorColors, black);
                if minus
                    fname = [fname '_minus'];
                    sdm.PredictorNames = {'f01-f01=-1', 'Rt1-Rt2=-1', ...
                        'Om1-Om2=-1', ...
                        'f01-f01=-33', 'Rt1-Rt2=-33', 'Om1-Om2=-33', ...
                        'f01-f01=0', 'Rt1-Rt2=0', 'Om1-Om2=0', ...
                        'f01-f01=33', 'Rt1-Rt2=33','Om1-Om2=33', ...
                        'f01-f01=1', 'Rt1-Rt2=1', 'Om1-Om2=1'};
%                     RI4D_minus(:,1) = RI_6D(:,1)-RI_6D(:,2);
%                     RI4D_minus(:,2) = RI_6D(:,3)-RI_6D(:,4);
%                     RI4D_minus(:,3) = RI_6D(:,5)-RI_6D(:,6);
%                     SoundOn = RI_6D(:,1)+RI_6D(:,2);
%                     sdmMatm1 = RI4D_minus==-1;
%                     sdmMatm33 = RI4D_minus==-1/3;
%                     sdmMat33 = RI4D_minus==1/3;
%                     sdmMat1 = RI4D_minus==1;
% 
%                     % Concatenate matrices to give 4*3 = 12 predictors
%                     sdm.SDMMatrix = cat(2, sdmMatm1, sdmMatm33, ...
%                         sdmMat33, sdmMat1, SoundOn);
                else
                    sdm.PredictorNames = {'f01=0', 'Rt1=0', 'Om1=0', ...
                        'f01=33', 'Rt1=33', 'Om1=33', ...
                        'f01=05', 'Rt1=05', 'Om1=05', ...
                        'f01=66', 'Rt1=66', 'Om1=66', ...
                        'f01=1', 'Rt1=1', 'Om1=1'};
                    % f01, Rt1 and Om1 are 0 when f02, Rt2 and Om2 are 1
                    sdmMat00 = RI_6D(:,[2,4,6])==1; 
                    sdmMat33 = RI_6D(:,[1,3,5])==1/3;
                    sdmMat05 = RI_6D(:,[1,3,5])==1/2;
                    sdmMat66 = RI_6D(:,[1,3,5])==2/3;
                    sdmMat1 = RI_6D(:,[1,3,5])==1;
                    sdm.SDMMatrix = cat(2, sdmMat00, sdmMat33, ...
                        sdmMat05, sdmMat66, sdmMat1)*1; % to make doubles
                end
                % Reorder to help with visual inspection
                % f01(0 to 1), Rt1 (0 to 1), Om (0 to 1)
                reorder = [1 4 7 13 10 2 5 8 14 11 3 6 9 12 15];
                sdm.SDMMatrix = sdm.SDMMatrix(:,reorder);
                sdm.PredictorNames = sdm.PredictorNames(reorder);
                sdm.PredictorColors = sdm.PredictorColors(reorder, :);
        end
                
        switch HRF
            case 1 % Apply canonical HRF
                fname = [fname '_cHRF'];
                sdm.SDMMatrix(:,1:nfeatures) = canonicalHRF(sdm.SDMMatrix(:,1:nfeatures));
            case 2 % Add stick predictors for deconvolution
                fname = [fname '_deconv'];
                [sdm.SDMMatrix(:,1:nfeatures), sdm.PredictorNames] = ...
                    deconvolveHRF(sdm.SDMMatrix(:,1:nfeatures), ...
                    sdm.PredictorNames, nstick);
                % todo: colors
                
        end
        % Add constant predictor
        sdm.SDMMatrix(:,nfeatures + 1) = ones; % Constant
        sdm.PredictorNames = cat(2, sdm.PredictorNames, {'Constant'});
        % Add motion correction predictors
        if MC
            fname = [fname '+MC'];
            sdm.PredictorNames = cat(2, sdm.PredictorNames, MC_pred_names);
            % Load MC sdm
            if strcmp(sub, 's01')
                mcfname = [subjdir 'images' filesep ...
                    sprintf('ripples_%s_run%d_%s_3DMC.sdm', sub, run, ...
                    runtype)];
            else
                mcfname = [subjdir 'images' filesep ...
                    sprintf('ripples_%s_run%d_%s_SCSTBL_3DMC.sdm', sub, run, ...
                    runtype)];
            end
            sdmMC = xff(mcfname);
            sdm.SDMMatrix(:,nfeatures+2:end) = sdmMC.SDMMatrix;
        end
        sdm.RTCMatrix = sdm.SDMMatrix;
        
        sdm.SaveAs(sprintf('%s%s_run%d_%s_RippleIndicator%dD%s.sdm',sdmdir, ...
            sub, run, runtype, nfeatures, fname));
        clear sdm
    end
end

function outmat = canonicalHRF(inmat)
% Define hemodynamic response function
[h,t] = hrf('twogamma', 2.6);
[nvols,nfeatures] = size(inmat);
outmat = zeros(size(inmat));
for f=1:nfeatures
    convolved = conv(inmat(:,f), h);
    outmat(1:nvols,f) = convolved(1:nvols);
end

function [outmat, outnames] = deconvolveHRF(inmat, prednames, nstick)
if nargin < 3
    nstick=8;
end
nvols = size(inmat,1);
npreds = length(prednames);
convmat = cat(1,eye(nstick),zeros(nvols-nstick,nstick));
outmat = zeros(nvols, npreds*nstick);
outnames = {};
for p = 1:npreds
    for s=1:nstick
        outnames = cat(2,outnames, [prednames{p} '_D' num2str(s-1)]);
    end
    deconved = conv2(inmat(:,p),convmat);
    outmat(:,p*nstick-nstick+1:p*nstick) = deconved(1:nvols, :); 
end




        
%------------- END CODE --------------     
    