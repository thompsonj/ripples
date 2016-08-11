%  Evaluate permutation tests
%%
data_path = '/Users/jthompson/Dropbox/ripples/';
% betadir = 'Betas_allconds_2016-01-27/'; % This may change
% set(groot,'defaultFigurePaperPositionMode','auto')
% 
% subs = { 's01','s02', 's03','s04', 's05', 's06'};
subs = {'s02', 's03','s04', 's05', 's06'};
% feats = 'f0', 'Rt', 'Om'};
models = {'RI_quad','RI_cub', 'RI_sin', 'RI_poly2'};

for s=1:length(subs)
    sub = subs{s}
    sub='s02';
    for m=1:length(models)
        mdl = models{m}
        s_path = [data_path sub];
        % load results
%         res = sprintf('Results_ACs02_GCV_VoxSelect1_th2.02_CV1_%s_None_Denoise0_NormData1_RescaleData0_Laplacian0_L2SplitsNr0.mat', models{m});
%         res = sprintf('Results_ACs02_Trace_VoxSelect1_th2.02_CV1_%s_None_Denoise0_NormData1_RescaleData0_Laplacian0_L2SplitsNr0.mat', models{m});
        res = sprintf('Results_ACs02__simplePerRun__VoxSelect1_th2.02_CV1_%s_None_Denoise0_NormData1_RescaleData0_Laplacian0_L2SplitsNr0.mat', mdl);
%         res_perm = sprintf('Results_PERM_ACs02_GCV_VoxSelect1_th2.02_CV1_%s_None_Denoise0_NormData1_RescaleData0_Laplacian0_L2SplitsNr0.mat', models{m});
%         res_perm = sprintf('Results_PERM1_ACs02__VoxSelect1_th2.02_CV1_%s_None_Denoise0_NormData1_RescaleData0_Laplacian0_L2SplitsNr0.mat', models{m});
        res_perm = sprintf('Results_PERM1_ACs02__simplePerRun__VoxSelect1_th2.02_CV1_%s_None_Denoise0_NormData1_RescaleData0_Laplacian0_L2SplitsNr0.mat', mdl);
        r_path = fullfile(s_path, 'fMRIEncoding', 'univariate', 'OLS', ...
            'NoMasking');
        res = load(fullfile(r_path, res));
        perm = load(fullfile(r_path, res_perm));
        
        % Maximum statistic-based 
        % Omnibus test

        np = size(perm.MeanCV_Acc,1);
        Mp = max(perm.MeanCV_Acc,[],2);
        M1 = max(res.Acc)
        p_omni = sum(Mp>=M1)/np
        % Voxel effects, corrected for multiple tests
        for i=1:length(res.MeanCV_Acc)
            p(i) = sum(Mp>=res.MeanCV_Acc(i))/np;
        end
        nsuprathresh = sum(p<.05)
        
        % hist of 95% quantile per voxel
        sortedperm = sort(perm.MeanCV_Acc,1, 'ascend');
        histfit(sortedperm(950,:),100, 'normal')
        h=title(sprintf('95%% quantile per voxel: %s %s', sub, mdl), 'FontSize', 18);
        set(h,'interpreter','none')
        xlabel('Pearson correlation coefficient', 'FontSize', 18)
        savename = sprintf('%s_%s_hist_95quant_pervoxel.png',sub,mdl);
        print('-dpng', savename)
        
        % hist of max per voxel

        histfit(sortedperm(1000,:),100, 'normal')
        h=title(sprintf('max per voxel: %s %s', sub, mdl), 'FontSize', 18);
        set(h,'interpreter','none')
        xlabel('Pearson correlation coefficient', 'FontSize', 18)
        savename = sprintf('%s_%s_hist_max_pervoxel.png',sub,mdl);
        print('-dpng', savename)
        
        hold on
        h = histfit(res.MeanCV_Acc, 100, 'normal')
        set(h(1),'facecolor','g');
        
        
        for i=1:size(perm.MeanCV_Acc,2)
            Mp = max(perm.MeanCV_Acc,[],2);
            p_null(i) = sum(Mp>=perm.MeanCV_Acc(i))/np;
        end
        
    end

end
 %%       
% 
%     perms = squeeze(PermutedInd);
%     p1 = find(perms(1,:)==1);
%     p2 = find(perms(2,:)==2);
%     p3 = find(perms(3,:)==3);
%     p4 = find(perms(4,:)==4);
%     p5 = find(perms(5,:)==5);
%     p6 = find(perms(6,:)==6);
%     p7 = find(perms(7,:)==7);
%     p8 = find(perms(8,:)==8);
%     trueord = [p1 p2 p3 p4 p5 p6 p7 p8];
%     uniquetrueord = unique(trueord);
%     for i = 1:length(uniquetrueord)
%         y(i) = sum(trueord==uniquetrueord(i));
%     end
%     hist(y, 1:8)
%     title('s3: 610 out of 1000 permutations contain at least one element in the correct position', 'FontSize', 18)
%     xlabel('Number of elements in same positions as true ordering', 'FontSize', 18)
%     ylabel('Number of permutations', 'FontSize', 18)
%     
%     Acc_sq = squeeze(Acc);
%     
%     % Calculate mean of all null distributions
%     avg_v = mean(Acc_sq,2);
%     figure()
%     hist(avg_v, 100);
%     title('Mean empirical null distribution across all voxels', 'FontSize', 16, 'FontWeight', 'Bold')
%     perm.mean_var = var(avg_v);
%     figname = fullfile(rpath, 'hist_avgPerm.png');
%     printf('-dpng', figname);
%     
%     % Calculate thresholds per voxel
%     [sorted,ind] = sort(Acc_sq,2,'ascend');
%     th = sorted(:,950);
%     perm.avg_th = mean(th);
%     perm.max_th = max(th);
%     [maxes, ind] = max(Acc_sq);
%     [maxes_sorted, indsort] = sort(maxes, 'ascend');
%     ind_sorted = ind(indsort);
%     perm.th_maxstat = maxes_sorted(950);
%     
%     
%     indsig=find(pred_Acc > .22);
%     figure()
%     hold on
%     for i=1:999
%         hist(perm_Acc(indsig,i), 100)
%     end
%     hist([perm_Acc(indsig,1000),pred_Acc(indsig)], 100)
%     legend('1000 Permutations', 'Model')
%     hold off
%     title('S3: Histogram of Accuracies for voxels that exceed non-parametric threshold', 'fontsize', 18)
%     xlabel('Accuracy of encoding (correlation between true and predicted response)', 'fontsize', 18)
%     
%     distperms = sqrt(sum(bsxfun(@minus, perms, [1,2,3,4,5,6,7,8]').^2));
%     scatter(maxes, distperms)
%     corr(maxes', distperms')
%     
% end