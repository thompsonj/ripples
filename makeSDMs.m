% makeSDMs.m
%
% Make various design matrix files for running GLMs in Brain Voyager for
% the dynamic ripples fMRI project.
% 
% Jessica Thompson
% Summer 2015
% 

clear all

subs = {'s01', 's02', 's03', 's04', 's05', 's06'};
for s=1:length(subs)
    sub = subs{s};
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

    subjdir = ['/Users/jthompson/data/ripples/' sub];
    logdir = [subjdir '/logs/'];
    prtdir = [subjdir '/prts/'];
    stimdir = '/Users/jthompson/data/ripples/';

    % Load ripple indicator features (3D)
    % load('/Users/jthompson/data/ripples/StimuliEncoding/ripple_features_3d.mat')
    load('/Users/jthompson/data/ripples/StimuliEncoding/ripple_features_6d.mat')
    nfeatures = size(features,2);

    % Load order of sound Decomp
    load('/Users/jthompson/data/ripples/SoundOrderIdxintoMixMat.mat')

    % Define hemodynamic response function
    [h,s] = hrf('twogamma', 2.6);

    for run=1:nruns
        % Load SDM
        sdm = xff(sprintf('%s%s_run%d_1cond_ceil.sdm', prtdir, sub, run));
        % Load order of presentation
        fname = dir([logdir '*run' num2str(run) '_data4prts_*']);
        load([logdir fname(end).name]);
        silent = find(stimuliinfo(:,2)==0);
        stimuliinfo(silent,:) = []; % Remove silent trials
        stimuliinfo(:,1) = stimuliinfo(:,1) + 1; % to correct for apparent off by one error
        ccatch = find(stimuliinfo(:,2)==1);
        stimuliinfo(ccatch,:) = []; % Remove catch trials
        if ismember(run, comboruns)
            stimuliinfo(:,2) = stimuliinfo(:,2)+8;
            nvols = 168;
        else
            nvols = 150;
        end
        stimuliinfo_decomp = stimuliinfo;
        stimuliinfo_decomp(:,2) = stimuliinfo_decomp(:,2)-1; % -1 becauase 0 and 1 in stimuliinfo refer to silent and catch trials
        stimuliinfo_decomp(:,2) = idx(stimuliinfo_decomp(:,2)); % reorder to match order of 

        % fname = dir([logdir '*run' num2str(run) '_stimuli_timing_*']);
        % stiminfo = dlmread([logdir fname(end).name], ' ', 2,1);

        sdm.SDMMatrix = zeros(nvols,nfeatures+1);
        sdm.NrOfPredictors = nfeatures + 1;
        sdm.IncludesConstant = 1;
        orig_colors = sdm.PredictorColors;
        sdm.PredictorColors = cat(1,orig_colors, [255 175 65], [0 175 65], [255 0 65], [255 175 255], [134 24 90]);
    %     sdm.PredictorNames = {'f0', 'Rt', 'Om', 'Constant'};
        sdm.PredictorNames = {'f01', 'f02', 'Rt1', 'Rt2', 'Om1', 'Om2', 'Constant'};
        sdm.FirstConfoundPredictor = nfeatures + 1;

        % Fill sdm with ripple indicator features
        sdm.SDMMatrix(stimuliinfo_decomp(:,1),1:nfeatures) = features(stimuliinfo_decomp(:,2),:);
        SDMMatrixpreHRF = sdm.SDMMatrix(:, 1:nfeatures);
        sdm.SDMMatrix(:,nfeatures + 1) = ones;
        sdm.RTCMatrix = sdm.SDMMatrix;

        % Save ripple indicator sdms
        sdm.SaveAs(sprintf('%s%s_run%d_RippleIndicator%dD_constant.sdm',prtdir, sub, run, nfeatures));

        % apply canonical HRF
        for f=1:nfeatures
            convolved = conv(sdm.SDMMatrix(1:nvols,f), h);
            sdm.SDMMatrix(1:nvols,f) = convolved(1:nvols);
        end
        sdm.RTCMatrix = sdm.SDMMatrix;
        RI_6D_HRF = sdm.SDMMatrix(:,1:nfeatures);

        % Save HRF ripple indicator sdms
        sdm.SaveAs(sprintf('%s%s_run%d_RippleIndicator%dD_HRF_constant.sdm',prtdir, sub, run, nfeatures));

        % Make z scored variations features? Without constant?
    %     sdm.SDMMatrix = SDMMatrixpreHRF;
    %     sdm.IncludesConstant = 0;
    %     sdm.PredictorNames = {'f01', 'f02', 'Rt1', 'Rt2', 'Om1', 'Om2'}; % Remove constant
    %     sdm.PredictorColors = sdm.PredictorColors(1:nfeatures, :); % Remove one color
    %     sdm.NrOfPredictors = nfeatures;
    %     sdm.FirstConfoundPredictor = 0; % no confound predictor
    %     
    %     % Apply HRF to z-score sdm
    %     for f=1:nfeatures
    %         convolved = conv(sdm.SDMMatrix(1:nvols,f), h);
    %         sdm.SDMMatrix(1:nvols,f) = convolved(1:nvols);
    %     end
    %     sdm.SDMMatrix = zscore(sdm.SDMMatrix);
    %     sdm.RTCMatrix = sdm.SDMMatrix;
    %     
    %     % Save z score ripple indicator sdms
    %     sdm.SaveAs(sprintf('%s%s_run%d_RippleIndicator%dD_HRF_z_noconstant.sdm',prtdir, sub, run, nfeatures));

        % Make scaled+flat sdms
        sdm.SDMMatrix = ceil(SDMMatrixpreHRF)* 0.6250; % Mean of all levels

        % Apply HRF to flat SDMs
        for f=1:nfeatures
            convolved = conv(sdm.SDMMatrix(1:nvols,f), h);
            sdm.SDMMatrix(1:nvols,f) = convolved(1:nvols);
        end

        % Add scaled predictors and constant column
        sdm.SDMMatrix = cat(2, RI_6D_HRF, sdm.SDMMatrix, ones(nvols,1));
        sdm.RTCMatrix = sdm.SDMMatrix;
        sdm.PredictorNames = {'f01_scale', 'f02_scale', 'Rt1_scale', 'Rt2_scale', 'Om1_scale', 'Om2_scale','f01_flat', 'f02_flat', 'Rt1_flat', 'Rt2_flat', 'Om1_flat', 'Om2_flat', 'Constant'};
        sdm.PredictorColors = cat(1,orig_colors, [255 175 65], [0 175 65], [255 0 65], [255 135 255], [134 74 90], [255 175 95], [0 175 65], [205 0 65], [255 175 205], [154 24 90], [234 24 90]);
        sdm.NrOfPredictors = (nfeatures*2)+1;
        sdm.IncludesConstant = 1;
        sdm.FirstConfoundPredictor = sdm.NrOfPredictors;

        % Save flat ripple indicator features
        sdm.SaveAs(sprintf('%s%s_run%d_RippleIndicator%dD_scaled+flat_HRF_constant.sdm',prtdir, sub, run, nfeatures));

        % Remove constant
    %     sdm.SDMMatrix = sdm.SDMMatrix(:,1:nfeatures);
    %     sdm.PredictorNames = {'f01', 'f02', 'Rt1', 'Rt2', 'Om1', 'Om2'}; % Remove constant
    %     sdm.PredictorColors = sdm.PredictorColors(1:nfeatures, :); % Remove one color
    %     sdm.NrOfPredictors = nfeatures;
    %     sdm.IncludesConstant = 0;
    %     
    %     % Zscore flat SDMs? before or after applying HRF? Should I let brain
    %     % voyager take care of some of this? like not worry about z scoreing
    %     % and leave the constant in?
    %     sdm.SDMMatrix = zscore(sdm.SDMMatrix);
    %     sdm.RTCMatrix = sdm.SDMMatrix;
    %     
    %     % Save flat sdms
    %     sdm.SaveAs(sprintf('%s%s_run%d_RippleIndicator%dD_flat_HRF_z_noconstant.sdm',prtdir, sub, run, nfeatures));
    % 
        % Make one pred per level of each feature (24D binary representation)
        nlevels = 4;
        sdmMatrix3 = SDMMatrixpreHRF;
        not3= find(sdmMatrix3 >= .5); 
        sdmMatrix3(not3) = 0;
        sdmMatrix3 = ceil(sdmMatrix3); % only .33 entries assigned 1, else 0

        sdmMatrix6 = SDMMatrixpreHRF;
        not6 = find(sdmMatrix6 <= .5);
        sdmMatrix6(not6) = 0;
        oones = find(SDMMatrixpreHRF == 1); % only 1 entries assigned 1, else 0
        sdmMatrix6(oones) = 0;
        sdmMatrix6 = ceil(sdmMatrix6); % only .66 entries assigned 1, else 0

        sdmMatrix1 = zeros(size(sdmMatrix6));
        sdmMatrix1(oones) = 1;

        sdmMatrix5 = zeros(size(sdmMatrix6));
        fives = find(SDMMatrixpreHRF == .5);
        sdmMatrix5(fives) = 1; % only .5 entries assigned 1, else 0

        % Concatenate matrices to give 4*6 = 24 dimensional binary feature vectors
        sdm.sdmMatrix = cat(2, sdmMatrix3, sdmMatrix5, sdmMatrix6, sdmMatrix1, ones(nvols,1));

        % Apply hrf to 24D features
        nnewfeatures = size(sdm.SDMMatrix, 2)-1;
        for f=1:nnewfeatures % don't apply HRF to constant
            convolved = conv(sdm.SDMMatrix(1:nvols,f), h);
            sdm.SDMMatrix(1:nvols,f) = convolved(1:nvols);
        end

        % Adjust other fields of SDM
        sdm.IncludesConstant = 1;
        sdm.PredictorNames = {'f01_33', 'f02_33', 'Rt1_33', 'Rt2_33', 'Om1_33', 'Om2_33', 'f01_5', 'f02_5', 'Rt1_5', 'Rt2_5', 'Om1_5', 'Om2_5', 'f01_66', 'f02_66', 'Rt1_66', 'Rt2_66', 'Om1_66', 'Om2_66', 'f01_1', 'f02_1', 'Rt1_1', 'Rt2_1', 'Om1_1', 'Om2_1'}; % Remove constant
        sdm.PredictorColors = cat(1, sdm.PredictorColors); % 13*2 colors
        sdm.PredictorColors = sdm.PredictorColors(1:nfeatures, :); % Remove one color for 25 predictors
        sdm.NrOfPredictors = nfeatures*nlevels+1;
        sdm.RTCMatrix = sdm.SDMMatrix;
        sdm.FirstConfoundPredictor = 0;
        sdm.IncludesConstant = 1;

        % Save 24D design matrix
        sdm.SaveAs(sprintf('%s%s_run%d_RippleIndicator%dD_binary_HRF_constant.sdm',prtdir, sub, run, nnewfeatures));

        clear sdm
    end
end
