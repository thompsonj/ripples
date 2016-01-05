% run from main ripples directory



% subs={'s01', 's02', 's03', 's04', 's05', 's06',};
subs={'s01', 's02', 's03', 's04', 's05', 's06',};
data_path = '/Users/jthompson/Dropbox/ripples/';
%%
for s=1:length(subs)
    sub = subs{s};
    subjdir = [data_path, sub, filesep];
    if strcmp(sub, 's01')
		% ABBA 8 runs
		bases = {['ripples_', sub, '_run1_simple'], ['ripples_', sub, ...
            '_run2_combo'], ['ripples_', sub, '_run3_combo'], ...
            ['ripples_', sub, '_run4_simple'], ['ripples_', sub, ...
            '_run5_simple'], ['ripples_', sub, '_run6_combo'], ...
            ['ripples_', sub, '_run7_combo'], ['ripples_', sub, ...
            '_run8_simple']};
        comboruns = [2, 3, 6, 7];
    elseif strcmp(sub, 's02') || strcmp(sub, 's03')
		% ABBA 12 runs
		bases = {['ripples_', sub, '_run1_simple'], ['ripples_', sub, ...
            '_run2_combo'], ['ripples_', sub, '_run3_combo'], ...
            ['ripples_', sub, '_run4_simple'], ['ripples_', sub, ...
            '_run5_simple'], ['ripples_', sub, '_run6_combo'], ...
            ['ripples_', sub, '_run7_combo'], ['ripples_', sub, ...
            '_run8_simple'], ['ripples_', sub, '_run9_simple'], ...
            ['ripples_', sub, '_run10_combo'], ['ripples_', sub, ...
            '_run11_combo'], ['ripples_', sub, '_run12_simple']};
        comboruns = [2, 3, 6, 7, 10, 11];
    else
        % BAAB 12 runs
		bases = {['ripples_', sub, '_run1_combo'], ['ripples_', sub, ...
            '_run2_simple'], ['ripples_', sub, '_run3_simple'], ...
            ['ripples_', sub, '_run4_combo'], ['ripples_', sub, ...
            '_run5_combo'], ['ripples_', sub, '_run6_simple'], ...
            ['ripples_', sub, '_run7_simple'], ['ripples_', sub, ...
            '_run8_combo'], ['ripples_', sub, '_run9_combo'], ...
            ['ripples_', sub, '_run10_simple'], ['ripples_', sub, ...
            '_run11_simple'], ['ripples_', sub, '_run12_combo']};
        comboruns = [1, 4, 5, 8, 9, 12];
    end

    % Make cell array of vtc and sdm file names
    smooth = '_SD3DVSS6.00mm';
    sdmdir = [subjdir 'sdms' filesep];
    params = ['_minus', '_scaled', '_cHRF', '+MC'];
    nfeatures = 4;
    if strcmp(sub, 's01')
        for r=1:8
            if ismember(r, comboruns)
                runtype='combo';
            else
                runtype='simple';
            end
            VTCs{r} = [subjdir, bases{r}, ...
                '_SCSTBL_3DMCS_THPGLMF6c_b02b0_TU_TAL', smooth, '.vtc'];
            sdm_fname{r} = sprintf('%s%s_run%d_%s_RippleIndicator%dD%s.sdm',sdmdir, sub, r, runtype, nfeatures, params);
        end
    else
        for r=1:12
            if ismember(r, comboruns)
                runtype='combo';
            else
                runtype='simple';
            end
            VTCs{r} = [subjdir, bases{r}, ...
                '_SCSTBL_3DMCS_LTR_THPGLMF6c_b02b0_TU_TAL', smooth, ...
                '.vtc'];
            sdm_fname{r} = sprintf('%s%s_run%d_%s_RippleIndicator%dD%s.sdm',sdmdir, sub, r, runtype, nfeatures, params);
        end
    end
    
    % Save .mdm per subject
    mdm = xff('new:mdm');
    mdm.XTC_RTC = [VTCs(:), sdm_fname(:)]; 
    mdm.SaveAs([subjdir, 'mdms', filesep, sprintf('%s_RippleIndicator%dD%s%s.mdm', sub, nfeatures, params, smooth)]);
end
    

%%
for s=1:length(subs)
    sub=subs{s};
    subjdir = [data_path, sub, filesep];
    if s==1
        bigmdm = xff([subjdir, 'mdms', filesep, sprintf('%s_RippleIndicator%dD%s%s.mdm', sub, nfeatures, params, smooth)]);
    else
        mdm=xff([subjdir, 'mdms', filesep, sprintf('%s_RippleIndicator%dD%s%s.mdm', sub, nfeatures, params, smooth)]);
        bigmdm.XTC_RTC = cat(1, bigmdm.XTC_RTC, mdm.XTC_RTC);
    end
end

bigmdm.SaveAs([data_path, 'group', filesep, sprintf('allsubs_RippleIndicator%dD%s%s.mdm', nfeatures, params, smooth)])