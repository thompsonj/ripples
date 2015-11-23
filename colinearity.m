% Assess multicolinearity
sub='s02';
subjdir = ['D:\ripples\' sub filesep];
prtdir = [subjdir 'prts' filesep];
sdmdir = [subjdir 'sdms' filesep];
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

% concatenate Ripple Indicator sdms 
% RI6D_noHRF = zeros(168*6+150*6, 6);
% RI6D_HRF = zeros(168*6+150*6, 6);
% RI24D_HRF = zeros(168*6+150*6, 24);
RI13D_HRF = zeros(168*6+150*6, 13);
i=0;
for r=1:nruns
    if ismember(r, comboruns)
        nvols = 168;
        runtype='combo';
    else
        nvols = 150;
        runtype='simple';
    end
%     sdmname = sprintf('%s_run%d_%s_RippleIndicator6D_constant.sdm', sub, r, runtype);
%     sdm24D = sprintf('%s_run%d_%s_RippleIndicator24D_bin_HRF_constant.sdm', sub, r, runtype);
    sdm13D = sprintf('%s_run%d_%s_RippleIndicator13D_MINUS_bin_HRF_constant.sdm', sub, r, runtype);
%     sdmnamehrf = sprintf('%s_run%d_%s_RippleIndicator6D_HRF_constant.sdm', sub, r, runtype);
%     sdmname_scale+flat_hrf = sprintf('%s_run%d_%s_RippleIndicator6D_scaled+flat_HRF_constant.sdm', sub, r, runtype);
%     sdm6D = xff([sdmdir sdmname]);
%     sdm24D = xff([sdmdir sdm24D]);
    sdm13D = xff([sdmdir sdm13D]);
%     RI6D_noHRF(i+1:i+nvols,:) = sdm.SDMMatrix(:,1:6);
%     RI6D_HRF(i+1:i+nvols,:) = sdm6D.SDMMatrix(:,1:end-1);
%     RI24D_HRF(i+1:i+nvols,:) = sdm24D.SDMMatrix(:,1:end-1);
%     RI23D_HRF(i+1:i+nvols,:) = sdm24D.SDMMatrix(:,1:end-1);
    RI13D_HRF(i+1:i+nvols,:) = sdm13D.SDMMatrix(:,1:end-1);
    i=i+nvols;
end
imagesc(RI6D_noHRF')
sum_minus = [RI6D_noHRF(:,1)+RI6D_noHRF(:,2) RI6D_noHRF(:,1)-RI6D_noHRF(:,2) ...
    RI6D_noHRF(:,3)-RI6D_noHRF(:,4) ...
    RI6D_noHRF(:,5)-RI6D_noHRF(:,6)];

sum_minus_flat = sum_minus >0;

sum_minus_z = zscore(sum_minus);
minus_z = sum_minus_z(:,[2,4,6]);
newfeats_z = sum_minus_z(:,[1,2,4,6]);
collintest(sum_minus, 'plot', 'on', 'varnames', {'f0+', 'f0-', 'Rt+', 'Rt-', 'Om+', 'Om-'})
collintest(minus_z, 'plot', 'on', 'varnames', {'f0-', 'Rt-', 'Om-'})
collintest(RI24D_HRF, 'plot', 'on', 'varnames',{'f01_33', 'f02_33', 'Rt1_33', 'Rt2_33', 'Om1_33', 'Om2_33', 'f01_5', 'f02_5', 'Rt1_5', 'Rt2_5', 'Om1_5', 'Om2_5', 'f01_66', 'f02_66', 'Rt1_66', 'Rt2_66', 'Om1_66', 'Om2_66', 'f01_1', 'f02_1', 'Rt1_1', 'Rt2_1', 'Om1_1', 'Om2_1'});
collintest(RI13D_HRF, 'plot', 'on', 'varnames',{'f01-f01=-1', 'Rt1-Rt2=-1', 'Om1-Om2=-1', ...
            'f01-f01=-33', 'Rt1-Rt2=-33', 'Om1-Om2=-33', ...
            'f01-f01=33', 'Rt1-Rt2=33', 'Om1-Om2=33', ...
            'f01-f01=1', 'Rt1-Rt2=1', 'Om1-Om2=1', 'SoundOn'});
collintest(RI6D_noHRF, 'plot', 'on', 'varnames', {'f0_1 scale', 'f0_2scale', 'Rt_1 scale', 'Rt_2 scale', 'Om_1 scale', 'Om_2 scale'})
[coeff,score,latent,tsquared,explained,mu] = pca(RI6D_noHRF);
pcafeatures = score(:,1:4);

% Create new SDMs with newfeats_z

