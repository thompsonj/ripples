% Topup
% @last_user: Omer Faruk Gulban

%dp = '/media/sf_D_DRIVE/fMRI/TEST/TopupIlkay/TOPUP/'; 
dp = '/media/sf_D_DRIVE/ripples/s03/images/'; 

% Load AP and PA phase '.fmr'
% phaseEncFilename_1 = fullfile(dp,'ripples_s01_AP_3DMCStoAP5.fmr');
% phaseEncFilename_2 = fullfile(dp,'ripples_s01_PA_3DMCStoPA.fmr');
phaseEncFilename_1 = fullfile(dp,'ripples_s03_AP_3DMCS.fmr');
phaseEncFilename_2 = fullfile(dp,'ripples_s03_PA_3DMCS.fmr');


%% Convert to nii
phaseEnc_1 = xff(phaseEncFilename_1); 
phaseEnc_1.Write4DNifti([phaseEncFilename_1(1:end-3),'nii']);
phaseEnc_1.ClearObject;

phaseEnc_2 = xff(phaseEncFilename_2); 
phaseEnc_2.Write4DNifti([phaseEncFilename_2(1:end-3),'nii']);
phaseEnc_2.ClearObject;

%% Merge
unix(['fsl5.0-fslmerge -t up_down_phase_s03 ',...
     [phaseEncFilename_1(1:end-3),'nii '],...
     [phaseEncFilename_2(1:end-3),'nii']]);

%% Topup
unix('fsl5.0-topup --imain=up_down_phase_s03 --datain=acqparams.txt --config=b02b0.cnf --out=topup_results_s03');
disp('top up computed')