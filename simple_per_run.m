load('/Users/jthompson/data/ripples/stimuliEncoding/ripple_features_3d.mat')
features_spr = zeros(132,3);
for r=1:6
    r
    strt = 6*(r-1)+1;
    for j=0:5
        strt+j
        features_spr(strt+j,:) = features(r,:);
    end
end
clear features
features = features_spr;
save('ripple_features_simple_per_run_3D.mat', 'features')