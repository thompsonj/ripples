clear variables; close all;
dirsounds = 'D:\ripples\stimuliEncoding\';
subs = {'s01', 's02', 's03', 's04', 's05', 's06'};
ABBAtrainSimple = [1 2 2 1 1 2 2 1 1 2 2 1];
BAABtrainSimple = [2 1 1 2 2 1 1 2 2 1 1 2];
ABBAtrainCombo = [2 1 1 2 2 1 1 2 2 1 1 2];
BAABtrainCombo = [1 2 2 1 1 2 2 1 1 2 2 1];
for s = 1:length(subs)
    sub = subs{s}
    dirsubj = ['D:\ripples\' sub filesep];
    if strcmp(sub, 's01') 
        CrossValMat = ABBAtrainSimple(1:8)';
    elseif strcmp(sub, 's02') || strcmp(sub, 's03')
        CrossValMat = ABBAtrainSimple';
    elseif strcmp(sub, 's04') || strcmp(sub, 's05') || strcmp(sub, 's06')
        CrossValMat = BAABtrainSimple';
    end 
    if s==1
        optstruct.Mask = 'AC_LR.msk';
    else
        optstruct.Mask = 'ACs02.msk';
    end
    optstruct.Denoise = 1;
    optstruct.hrfthresh = 20;
    optstruct.DenoisePredType = '1cond_ceil.prt';
    optstruct.FIRPredType = '1cond_ceil.prt';
    optstruct.SEPPredType = 'allconds_simple_per_run.prt';
    optstruct.CrossValFirFlag = 1;
    optstruct.NrOfStick = 8;
    if s==1
        optstruct.NrSplitsFIR = 4;
    else 
        optstruct.NrSplitsFIR = 6;
    end

    getBetas(dirsubj,CrossValMat,optstruct);
end