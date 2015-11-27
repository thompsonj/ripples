glm13 = xff('glms/s02_VTC_N-12_FFX_ZT_AR-2_ITHR-100_RI13D+SoundOn_binary_combos.glm');

%% f0
f0Betas = glm13.GLMData.BetaMaps(:,:,:, [1,4,7,10]);
f0Betasflat(1,:)= reshape(f0Betas(:,:,:,1),[],1);
f0Betasflat(2,:)= reshape(f0Betas(:,:,:,2),[],1);
f0Betasflat(3,:)= reshape(f0Betas(:,:,:,3),[],1);
f0Betasflat(4,:)= reshape(f0Betas(:,:,:,4),[],1);

% mask to get only voxels of interest


% cluster 
[idx_5,C_5,sumd_6,D_5] = kmeans(f0Betasflat',6, 'Distance', 'sqeuclidean', 'Replicates', 3, 'Display', 'iter');
nvox = length(f0Betasflat);
plot([1/3, 1/2, 2/3, 1],C_5(1,:))
hold on
plot([1/3, 1/2, 2/3, 1],C_5(2,:))
plot([1/3, 1/2, 2/3, 1],C_5(3,:))
plot([1/3, 1/2, 2/3, 1],C_5(4,:))
plot([1/3, 1/2, 2/3, 1],C_5(5,:))
plot([1/3, 1/2, 2/3, 1],C_5(6,:))
hold off
legend(sprintf('Cluster 1 %d %%',round(100*sum(idx_5==1)/nvox)), ...
    sprintf('Cluster 2 %d %%',round(100*sum(idx_5==2)/nvox)), ...
    sprintf('Cluster 3 %d %%',round(100*sum(idx_5==3)/nvox)), ...
    sprintf('Cluster 4 %d %%',round(100*sum(idx_5==4)/nvox)), ...
    sprintf('Cluster 5 %d %%',round(100*sum(idx_5==5)/nvox)), ...
    sprintf('Cluster 6 %d %%',round(100*sum(idx_5==6)/nvox)));
set(gca,'XTick',[1/3, 1/2, 2/3, 1])
set(gca,'XTickLabel',{'1/3', '1/2', '2/3', '1'})
xlabel('Presence of f0_1', 'FontSize', 16)
ylabel('Beta in GLM with one predictor per level', 'FontSize', 16)
title('Centroid of k-means clusters (k=6) for f0_1 in s02, all voxels, mix runs only', 'FontSize', 16)
print('-dpng', 'figures/s02_f0_k-means6_13DGLM_mixedruns')




[coeff,score,latent,tsquared,explained,mu] = pca(f0Betasflat');
% each column of coeff is a PC, ordered in terms of their explained
% variance
plot([1/3, 1/2, 2/3, 1],coeff(:,1))
hold on
plot([1/3, 1/2, 2/3, 1],coeff(:,2))
plot([1/3, 1/2, 2/3, 1],coeff(:,3))
plot([1/3, 1/2, 2/3, 1],coeff(:,4))
hold off
legend(sprintf('1st PC %s %%',num2str(explained(1))), ...
    sprintf('2nd PC %s %%',num2str(explained(2))), ...
    sprintf('3rd PC %s %%',num2str(explained(3))), ...
    sprintf('4th PC %s %%',num2str(explained(4))));
xlabel('Presence of f0_1', 'FontSize', 16)
ylabel('Beta in GLM with one predictor per level', 'FontSize', 16)
title('Principal components of Betas for f0_1 in s02, all voxels, mix runs only', 'FontSize', 16)
print('-dpng', 'figures/s02_f0_PCs_13DGLM_mixedruns')

[m,ind] = max(score');
[m,ind] = max(abs(score'));
ind1 = (ind==1)*1;
ind2 = (ind==2)*1;
vmp = xff('maps/test4maps.vmp');
vmp.Map(1).VMPData = reshape((ind==1)*1,size(f0Betas(:,:,:,1))); 
vmp.Map(2).VMPData = reshape((ind==2)*1,size(f0Betas(:,:,:,1))); 
vmp.Map(3).VMPData = reshape((ind==3)*1,size(f0Betas(:,:,:,1))); 
vmp.Map(4).VMPData = reshape((ind==4)*1,size(f0Betas(:,:,:,1))); 
vmp.Map(1).Name = sprintf('1st PC %s %%',num2str(explained(1)));
vmp.Map(2).Name = sprintf('2nd PC %s %%',num2str(explained(2)));
vmp.Map(3).Name = sprintf('3rd PC %s %%',num2str(explained(3)));
vmp.Map(4).Name = sprintf('4th PC %s %%',num2str(explained(4)));
vmp.SaveAs('maps/GLM_13D_PCs_pref_abs_f0');

%% Rt
OmBetas = glm13.GLMData.BetaMaps(:,:,:, [2,5,8,11]);
OmBetasflat(1,:)= reshape(OmBetas(:,:,:,1),[],1);
OmBetasflat(2,:)= reshape(OmBetas(:,:,:,2),[],1);
OmBetasflat(3,:)= reshape(OmBetas(:,:,:,3),[],1);
OmBetasflat(4,:)= reshape(OmBetas(:,:,:,4),[],1);
[coeff,score,latent,tsquared,explained,mu] = pca(OmBetasflat');
plot([1/3, 1/2, 2/3, 1],coeff(:,1))
hold on
plot([1/3, 1/2, 2/3, 1],coeff(:,2))
plot([1/3, 1/2, 2/3, 1],coeff(:,3))
plot([1/3, 1/2, 2/3, 1],coeff(:,4))
hold off
legend(sprintf('1st PC %s %% ',num2str(explained(1))), ...
    sprintf('2nd PC %s %%',num2str(explained(2))), ...
    sprintf('3rd PC %s %%',num2str(explained(3))), ...
    sprintf('4th PC %s %%',num2str(explained(4))));
xlabel('Presence of Rt_1', 'FontSize', 16)
ylabel('Beta in GLM with one predictor per level', 'FontSize', 16)
title('Principal components of Betas for Rt_1 in s02, all voxels, mix runs only', 'FontSize', 16)
print('-dpng', 'figures/s02_Rt_PCs_13DGLM_mixedruns')

%% Om
OmBetas = glm13.GLMData.BetaMaps(:,:,:, [3,6,8,12]);
OmBetasflat(1,:)= reshape(OmBetas(:,:,:,1),[],1);
OmBetasflat(2,:)= reshape(OmBetas(:,:,:,2),[],1);
OmBetasflat(3,:)= reshape(OmBetas(:,:,:,3),[],1);
OmBetasflat(4,:)= reshape(OmBetas(:,:,:,4),[],1);
[coeff,score,latent,tsquared,explained,mu] = pca(OmBetasflat');
plot([1/3, 1/2, 2/3, 1],coeff(:,1))
hold on
plot([1/3, 1/2, 2/3, 1],coeff(:,2))
plot([1/3, 1/2, 2/3, 1],coeff(:,3))
plot([1/3, 1/2, 2/3, 1],coeff(:,4))
hold off
legend(sprintf('1st PC %s %% ',num2str(explained(1))), ...
    sprintf('2nd PC %s %%',num2str(explained(2))), ...
    sprintf('3rd PC %s %%',num2str(explained(3))), ...
    sprintf('4th PC %s %%',num2str(explained(4))));
xlabel('Presence of Om_1', 'FontSize', 16)
ylabel('Beta in GLM with one predictor per level', 'FontSize', 16)
title('Principal components of Betas for Om_1 in s02, all voxels, mix runs only', 'FontSize', 16)
print('-dpng', 'figures/s02_Om_PCs_13DGLM_mixedruns')