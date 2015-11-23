for p = 1:200
    perm(p,:) = randperm(8);
end
coefs = corr(perm');
hist(coefs(:), 100)
title('Correlations of 200 Randperm 8')
clear
for p = 1:200
    perm(p,:) = randperm(144);
end
coefs = corr(perm');
hist(coefs(:), 100)
title('Correlations of 200 Randperm 144')