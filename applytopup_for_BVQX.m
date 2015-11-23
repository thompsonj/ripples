% Applytopup
% @last_user: Omer Faruk Gulban

%dp = '/media/sf_D_DRIVE/fMRI/TEST/TOPUP/'; 
dp = '/media/sf_D_DRIVE/ripples/s03/images/'; 

epi_names{1}=fullfile(dp,'ripples_s03_run1_simple_SCSTBL_3DMCS_LTR_THPGLMF6c.fmr');
epi_names{2}=fullfile(dp,'ripples_s03_run2_combo_SCSTBL_3DMCS_LTR_THPGLMF6c.fmr');
epi_names{3}=fullfile(dp,'ripples_s03_run3_combo_SCSTBL_3DMCS_LTR_THPGLMF6c.fmr');
epi_names{4}=fullfile(dp,'ripples_s03_run4_simple_SCSTBL_3DMCS_LTR_THPGLMF6c.fmr');
epi_names{5}=fullfile(dp,'ripples_s03_run5_simple_SCSTBL_3DMCS_LTR_THPGLMF6c.fmr');
epi_names{6}=fullfile(dp,'ripples_s03_run6_combo_SCSTBL_3DMCS_LTR_THPGLMF6c.fmr');
epi_names{7}=fullfile(dp,'ripples_s03_run7_combo_SCSTBL_3DMCS_LTR_THPGLMF6c.fmr');
epi_names{8}=fullfile(dp,'ripples_s03_run8_simple_SCSTBL_3DMCS_LTR_THPGLMF6c.fmr');
epi_names{9}=fullfile(dp,'ripples_s03_run9_simple_SCSTBL_3DMCS_LTR_THPGLMF6c.fmr');
epi_names{10}=fullfile(dp,'ripples_s03_run10_combo_SCSTBL_3DMCS_LTR_THPGLMF6c.fmr');
epi_names{11}=fullfile(dp,'ripples_s03_run11_combo_SCSTBL_3DMCS_LTR_THPGLMF6c.fmr');
epi_names{12}=fullfile(dp,'ripples_s03_run12_simple_SCSTBL_3DMCS_LTR_THPGLMF6c.fmr');
 

%% Load fmr experiment time series, convert to nii
nr_epis=length(epi_names);
for i=1:nr_epis;
    epi{i}=xff(epi_names{i});
    epi{i}.Write4DNifti([epi_names{i}(1:end-3),'nii']);
    epi{i}.ClearObject;
end;

%% Apply topup
nr_epis=length(epi_names);
for i=8:12;
    unix(['fsl5.0-applytopup -i ',[epi_names{i}(1:end-3),'nii.gz'],' -a acqparams_unwarp.txt --topup=topup_results_s03 --inindex=1 --method=jac --interp=spline --out=',[epi_names{i}(1:end-4),'_corrected.nii.gz']]);
    unix(['gunzip ',[epi_names{i}(1:end-4),'_corrected.nii.gz']]);
    unix(['rm -rf ',[epi_names{i}(1:end-4),'_corrected.nii.gz']]);
    tempnii=xff([epi_names{i}(1:end-4),'_corrected.nii']);
    % Convert back to .fmr
    tempfmr=tempnii.Dyn3DToFMR;
    fmr_prop=xff(epi_names{i});
    % Position information
    fmr_prop.Slice.STCData=tempfmr.Slice.STCData;
    % Save
    fmr_prop.SaveAs([epi_names{i}(1:end-4),'_b02b0_TU.fmr']);
    unix(['rm -rf ',[epi_names{i}(1:end-4),'_corrected.nii']]);
    unix(['rm -rf ',[epi_names{i}(1:end-4),'.nii']]);
    disp(['fmr ' num2str(i) ' of ' num2str(nr_epis) ' computed']);
end;



