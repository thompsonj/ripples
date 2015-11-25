
// This simple script shows how VTC files linked ot a VMR document can be preprocessed
// This is especially helpful if VTCs are created with no (or modest, i.e. 4mm) spatial smoothing
// but when spatial smoothing (e.g. with FWHM of 8-10mm) is desired for group studies.
// In this case one could smooth the original FMR and create a second VTC file. It is, however,
// much more efficient to smooth the VTC file directly with an appropriate kernel as shown here
// While spatial smoothing is probably the most useful scenario of VTC smoothing, the
// code below shows how to call all available preprocessing options.
//
// To prepare this script, load a VMR and link a VTC - or add the appropriate script commands

//subs = ["s01", "s02", "s03", "s04", "s05", "s06"];
subs = ["s06"];
for (s = 0; s < subs.length; s++) { 
	//var sub = "s03";
	var sub = subs[s];
	if (sub == "s01") {
		//ABBA 8 runs
		var VTCs = ["ripples_"+ sub + "_run1_simple", "ripples_"+ sub + "_run2_combo", "ripples_"+ sub + "_run3_combo", "ripples_"+ sub + "_run4_simple", "ripples_"+ sub + "_run5_simple", "ripples_"+ sub + "_run6_combo", "ripples_"+ sub + "_run7_combo", "ripples_"+ sub + "_run8_simple"];
 	} else if (sub == "s02" || sub == "s03" ) {
		//ABBA 12 runs
		var VTCs = ["ripples_"+ sub + "_run1_simple", "ripples_"+ sub + "_run2_combo", "ripples_"+ sub + "_run3_combo", "ripples_"+ sub + "_run4_simple", "ripples_"+ sub + "_run5_simple", "ripples_"+ sub + "_run6_combo", "ripples_"+ sub + "_run7_combo", "ripples_"+ sub + "_run8_simple", "ripples_"+ sub + "_run9_simple", "ripples_"+ sub + "_run10_combo", "ripples_"+ sub + "_run11_combo", "ripples_"+ sub + "_run12_simple"];
	} else {
		//BAAB 12 runs
		//var VTCs = ["ripples_"+ sub + "_run1_combo", "ripples_"+ sub + "_run2_simple", "ripples_"+ sub + "_run3_simple", "ripples_"+ sub + "_run4_combo", "ripples_"+ sub + "_run5_combo", "ripples_"+ sub + "_run6_simple", "ripples_"+ sub + "_run7_simple", "ripples_"+ sub + "_run8_combo", "ripples_"+ sub + "_run9_combo", "ripples_"+ sub + "_run10_simple", "ripples_"+ sub + "_run11_simple", "ripples_"+ sub + "_run12_combo"];
		var VTCs = ["ripples_"+ sub + "_run9_combo", "ripples_"+ sub + "_run10_simple", "ripples_"+ sub + "_run11_simple", "ripples_"+ sub + "_run12_combo"];

	}

	var DataPath = "/Users/jthompson/data/ripples/"+ sub+"/";
	// load VMR
	var docVMR = BrainVoyagerQX.OpenDocument(DataPath + "ripples_" + sub + "_T1_divPD_IIHC_ISOpt6_TAL.vmr");
 
	for (i = 0; i < VTCs.length; i++) { 
		if (sub == 's01') {
			VTC = DataPath + VTCs[i] + "_SCSTBL_3DMCS_THPGLMF6c_b02b0_TU_TAL.vtc";
		} else {
			VTC = DataPath + VTCs[i] + "_SCSTBL_3DMCS_LTR_THPGLMF6c_b02b0_TU_TAL.vtc";
		}
		docVMR.LinkVTC(VTC);
		BrainVoyagerQX.PrintToLog("Filtering " + VTCs[i]);
		Filter_VTC(VTC);
		docVMR.Close
	}
}

function Filter_VTC(VTC)
{
	BrainVoyagerQX.PrintToLog("Current VTC file: " + docVMR.FileNameOfCurrentVTC);  // show name of current VTC

	// smooth VTC with a 'ideal' kernel of 2 mm:
	docVMR.SpatialGaussianSmoothing( 6, "mm" );    // FWHM value and unit ("mm" or "vx")

	BrainVoyagerQX.PrintToLog("Name of spatially smoothed VTC file: " + docVMR.FileNameOfCurrentVTC);
}


// Note that all intermediate VTC files are kept on disk. In order to remove no longer needed files, use
// the file access script routines (see "UsingCustomFiles.js" script) 