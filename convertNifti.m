
subs = {'s01', 's02', 's03', 's04', 's05', 's06'};

for s=1:6
    sub=subs{s}
    vmr = xff(sprintf('%s/ripples_%s_T1_divPD_IIHC_ISOpt6_TAL.vmr',sub,sub));
    vmr.ExportNifti(sprintf('%s/ripples_%s_T1_divPD_IIHC_ISOpt6_TAL_NE.nii',sub,sub));
end
% vmr.ExportNifti(niifile [, talorder])
