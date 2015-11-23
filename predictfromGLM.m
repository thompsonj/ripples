

clear all

sub = 's03';
if strcmp(sub, 's01') || strcmp(sub, 's02') || strcmp(sub, 's03')
    order = 'ABBA';
    comboruns = [2, 3, 6, 7, 10, 11];
elseif strcmp(sub, 's04') || strcmp(sub, 's05') || strcmp(sub, 's06')
    order = 'BAAB';
    comboruns = [1, 4, 5, 8, 9, 12];
end

subjdir = ['/Users/jthompson/data/ripples/' sub];
logdir = [subjdir '/logs/'];
prtdir = [subjdir '/prts/'];
stimdir = '/Users/jthompson/data/ripples/';
nruns=12;
runtypes = {'simple','combo'};
glmfname = [subjdir filesep 's03_VTC_N-6_FFX_ZT_AR-2_ITHR-100_RippleIndicator6D_scale+constant_simple.glm'];
glm = xff(glmfname);

% Plot
for rt = 1:2
    for f=1:6
        
        betamap = glm.GLMData.BetaMaps(:,:,:,f);
        subdir = 'beta_maps';
        mapname = glm.Predictor(f).Name2;
        fname = sprintf('%s_BetaMap_%s_%s',sub, mapname, runtypes(rt));
        
        InfoVTC.Resolution
        InfoVTC.BBox
        InfoVTC.DimVTC
        InfoVTC.voxVTC
        saveICAMap(subjdir,subdir,betamap,mapname,fname,InfoVTC)
     glm.GLMData.BetaMaps(:,:,:,f);
    end
end