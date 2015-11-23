clear variables; close all;

% dirsounds = '/Users/Federico/fMRIData/EcodingTestData/S3_STIM/';
% dirsubj = '/Users/Federico/fMRIData/EcodingTestData/S3/';


% dirsounds = 'C:\Users\jessica.thompson\Dropbox\ripples\fmri_exp\stimuliEncoding\';
% dirsounds = 'D:\ripples\stimuliEncoding\';
% dirfeats = 'C:\Users\jessica.thompson\Dropbox\ripples\fmri_exp\';
% dirsubj = 'D:\ripples\s01\';
% dirsubj = 'D:\ripples\s02\';

dirsounds = '/Users/jthompson/data/ripples/stimuliEncoding/';
dirfeats = '/Users/jthompson/Dropbox/ripples/fmri_exp/';
dirsubj = '/Users/jthompson/data/ripples/s06/';

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% PERIPHERAL PROCESSING %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% OpPeriphProc.prefix = '';  %%% has to be s3_ if the underscore has is there.

OpPeriphProc.method = 'None';
% OpPeriphProc.N = 1024;
% OpPeriphProc.shift = 0.25;
% OpPeriphProc.ResizeSpect = 1;
% OpPeriphProc.ResizeF = 128;
% OpPeriphProc.ResizeT = 10;
% OpPeriphProc.FreqScale = 'log';
% OpPeriphProc.ramp = 0;
% OpPeriphProc.equal = 0;
% OpPeriphProc.frmlen = 4;
% OpPeriphProc.resample = 1;
% OpPeriphProc.newfs = 16000;
% OpPeriphProc.MatchSoundsLength = 1;
[PeriphProc,OpProc] = PeripheralProcessing(dirsounds,OpPeriphProc);

%%%% plotting the peripheral processing results %%%%%
% soundIdx = [1 100];
% DispPeriphProc(dirsounds,soundIdx,PeriphProc);
%%%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% SOUND DECOMPOSITION %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% this produces a decomposition per channel
%%% for location studies the combination of the channels 
%%% has still to be implemented


OpInput.method = 'None';
% OpInput.PeriphProc = PeriphProc;
% OpInput.OpProc = OpProc;
OpInput.MatchSoundsLength = 1;

OpDec.Dec = 'CUST';
OpDec.FeatName = 'RippleIndicator3d_simple_per_run';
load([dirsounds 'ripple_features_simple_per_run_3D.mat']);
OpDec.custom_decomp = features;
OpDec.SoundFileOrder = [dirsounds 'fnames_DecompOrder_simple_per_run.txt'];
% OpDec.NfreqBins = 112;
% OpDec.rv = [1 3 9 27];
% OpDec.sv = (2.^(linspace(log2(0.5),log2(4),4)));
% OpDec.MapParam = 'Rate-Scale-Freq';

% OpDec.Dec = 'SWT';
% OpDec.NfreqBins = 8;
% OpDec.rv = [1 3 9 27];
% OpDec.sv = (2.^(linspace(log2(0.5),log2(4),4)));
% OpDec.MapParam = 'Rate-Scale-Freq-Time-UpDown';


% OpDec.Dec = 'SWT_I_FSpec';
% OpDec.NfreqBins = 16;
% OpDec.rv = [1 3 9 27];
% OpDec.sv = (2.^(linspace(log2(0.5),log2(4),4)));
% OpDec.MapParam = 'Rate-Scale-Freq';

% OpDec.Dec = 'SWT_I_FNSpec';
% OpDec.NfreqBins = 120;
% OpDec.rv = [1 3 9 27];
% OpDec.sv = (2.^(linspace(log2(0.5),log2(4),4)));
% OpDec.MapParam = 'Rate-Scale-Freq';
% 
% OpDec.Dec = 'CochFiltMean';
% OpDec.NfreqBins = 128;

%OpDec.ContinuousSounds = 1;
%OpDec.TR = 1;
%OpDec.Overlap = 20;
%OpDec.NormRowCol = 0;

Decomp = SoundDecomposition(dirsounds,OpInput,OpDec);

%%%% plotting the Decomposition results %%%%%
% soundIdx = [1 100];
% DispDecomp(dirsounds,soundIdx,[],Decomp);
%%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% ESTIMATE BETAS %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% order = 'BAAB';
ABBAtrainSimple = [1 2 2 1 1 2 2 1 1 2 2 1];
ABBAtrainCombo = [2 1 1 2 2 1 1 2 2 1 1 2];
BAABtrainSimple = [2 1 1 2 2 1 1 2 2 1 1 2];
BAABtrainCombo= [1 2 2 1 1 2 2 1 1 2 2 1];
CrossValMat = BAABtrainSimple';

optstruct.Mask = 'ACs02.msk';
optstruct.Denoise = 1;
optstruct.hrfthresh = 20;

optstruct.DenoisePredType = '1cond_ceil.prt';
optstruct.FIRPredType = '1cond_ceil.prt';
optstruct.SEPPredType = 'allconds_simple_per_run.prt';
optstruct.CrossValFirFlag = 1;
optstruct.NrSplitsFIR = 6;


getBetas(dirsubj,CrossValMat,optstruct);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% ENCODING %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%
ABBAtrainSimple = [1 2 2 1 1 2 2 1 1 2 2 1];
ABBAtrainSimples01 = [1 2 2 1 1 2 2 1];
ABBAtrainCombo = [2 1 1 2 2 1 1 2 2 1 1 2];
BAABtrainSimple = [2 1 1 2 2 1 1 2 2 1 1 2];
BAABtrainCombo= [1 2 2 1 1 2 2 1 1 2 2 1];
CrossValMat = BAABtrainSimple';

opten.decomp_type = 'CUST';
opten.FeatName = 'RippleIndicator3d_simple_per_run';
opten.PeriphProcType = 'None';
% opten.MapParam = 'Rate-Scale-Freq';
opten.StimOrderFName = 'SoundOrder_simple_per_run.txt';
opten.Denoise = 1;
opten.BetaMask = 'ACs02';
% opten.BetaMask = 'AC_LR';
opten.L2splits = 0;
opten.normdata = 1;

opten.VoxSelect_cv = 1;
opten.VoxSelect_cv_th = 2.5;
% opten.VoxSelect_cv_name = 'FMap_BetaACs02_cv';
%opten.VoxSelect_cv_Mtype = 'ica';

opten.mode = 'univariate';
% opten.searchlight = 1;
% opten.searchlightMethod = 'SL_Iterative'; 
% default 10.^(0.5:(1/3):11)
% opten.lambda_range = 10.^(0.5:(1/3):11); % range 1
% opten.lambda_range = linspace(580,610,300); % range 2
opten.lambda_range = 10.^(0.5:(1/3):11); 

opten.method = 'Ridge';
opten.lambdaSelMethod='Trace'; % Trace or GCV

% opten.CovEstim = 1; % default to 0
% opten.lambdaCC_range = [0.01:0.1:5];

opten.SaveWeights = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FOR ContinuousSounds %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% opten.ContinuousSounds = 1;
% opten.HRFModel = 'FIR';
% opten.NrOfSticks = 10;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% opten.parallelOFF = 1;

% opten.useLaplacian = 0;
% opten.LaplacianMode = 1;

opten.Permute = 0;
fMRI_Encoding(dirsubj,dirsounds,CrossValMat,opten)
% % % 
% opten.Permute = 1;
% opten.NrPermute=250;
% fMRI_Encoding(dirsubj,dirsounds,CrossValMat,opten)

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% COMPUTE SCORE %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CrossValMat = [1 1 1 1 1 1 2 2]';
ABBAtrainSimple = [1 2 2 1 1 2 2 1 1 2 2 1];
ABBAtrainCombo = [2 1 1 2 2 1 1 2 2 1 1 2];
BAABtrainSimple = [2 1 1 2 2 1 1 2 2 1 1 2];
BAABtrainCombo= [1 2 2 1 1 2 2 1 1 2 2 1];
CrossValMat = BAABtrainSimple';
BetaMask = 'ACs02';
mode = 'univariate';
method = 'Ridge';
mask = 'NoMasking';

% nrCVs  =size(CrossValMat,2);
nrCVs = 1;
optScore = struct([]);
optscore.perm = 0;
optscore.FeatName = 'RippleIndicator3d_simple_per_run';
[out] = IdentifySounds(dirsubj,mode,method,BetaMask,mask,nrCVs,optScore);


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% CREATE MAPS %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CrossValMat = [1 1 1 1 1 1 2 2]';
CrossValMat = [1 1 1 2; 1 1 2 1]';
BetaMask = 'AC_LR';
nrCVs  =size(CrossValMat,2);
method = 'Ridge';
mask = 'NoMasking';

opMaps.Denoise = 1;
% opMaps.BetaMask = 'Volume';
% opMaps.VoxSelect_cv = 1;
% opMaps.VoxSelect_cv_th = 5;
opMaps.smoothVRF = 0;
opMaps.method = 'BestFeature';
opMaps.scaleCol = 'log';
opMaps.lambdaSelMethod = 'Trace';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FOR ContinuousSounds %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

opMaps.ContinuousSounds = 0;
opMaps.HRFModel = 'FIR';
opMaps.NrOfSticks = 15;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


CreateMaps(dirsubj,method,mask,nrCVs,opMaps);



