% Linear modeling in significant voxels

sub='s04';
subjdir = ['D:\ripples\' sub filesep];
prtdir = [subjdir 'prts' filesep];
if strcmp(sub, 's01')
    order = 'ABBA';
    comboruns = [2, 3, 6, 7];
    simpleruns = [1, 4, 5, 8];
elseif strcmp(sub, 's02') || strcmp(sub, 's03')
    order = 'ABBA';
    comboruns = [2, 3, 6, 7, 10, 11];
    simpleruns = [1, 4, 5, 8, 9, 12];
elseif strcmp(sub, 's04') || strcmp(sub, 's05') || strcmp(sub, 's06')
    order = 'BAAB';
    comboruns = [1, 4, 5, 8, 9, 12];
    simpleruns = [2, 3, 6, 7, 10, 11];
end

%% Load response to sound, save mask
% Load 1cond_sound glm
glm1cond = xff([subjdir sub '_VTC_N-12_FFX_ZT_AR-2_ITHR-100_1cond_Sound.glm']);
tMap = glm1cond.FFX_tMap;

% show loaded objects
x = xff
 
% select vmp (2nd object)
vmp = xff(2);
msk = vmp.CreateMSK;

% Determine FDR threshold value
stats = vmp.Map(1).VMPData;
th = applyfdr(stats, 't', .05, 1895);
th = th(1);
msk.Mask = stats>th;
mskname = [subjdir sub '_ActiveVoxels_FDRth' str(th) '.msk'];
msk.SaveAs(mskname)

%% Calculate separate GLMs for simple and mixes using 6D sdms in only
% significant voxels. 

simple_vtcs = findfiles(subjdir, '*simple*.vtc');
combo_vtcs = findfiles(subjdir, '*combo*.vtc');
simple_sdms = findfiles(prtdir, '*simple_RippleIndicator6D_HRF_constant.sdm');
combo_sdms = findfiles(prtdir, '*combo_RippleIndicator6D_HRF_constant.sdm');


mdm = xff('new:mdm');
mdm.RFX_GLM = 0;
mdm.XTC_RTC = [simple_vtcs(:) simple_sdms(:)];
glmoutname = sprintf('%s%s_simple_ActiveMsk.glm', prtdir, sub);
opts = struct( ...
    'mask',     mskname, ...
    'outfile',  glmoutname);
%     'restcond',  'rest', ...
%     'tfilter',   160, ...
%     'tfilttype', 'fourier');
%    'motpars',   {rps(:)}, ...
%     'robust',    true, ...

mdm.ComputeGLM([options])

collintest(SDMMatrixpreHRF, 'plot', 'on', 'varnames', {'f0_1 scale', 'f0_2scale', 'Rt_1 scale', 'Rt_2 scale', 'Om_1 scale', 'Om_2 scale'})
% Extract betas from simple GLM

% Use simple Betas to predict activity to combos

% Calculate correlation and R squared for each voxel in analysis

% Make maps