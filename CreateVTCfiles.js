
/* 	CreateVTCfiles.qs
	Script to create VTC files 
	By Rainer Goebel 2005
	Modified for QX 2.1 by Hester Breman 2009
	Modified for QX 2.4 by Rainer Goebel 2012
*/

/* This information is used in the functions */
	var sub = "s03";
	var DataPath = "D:\\ripples\\"+ sub + "\\images\\";
//	var DTIDataPath = BrainVoyagerQX.PathToSampleData + "Human31dir/";
	var today = new Date();
//	var nameFMR = ObjectsRawDataPath + "CG_OBJECTS_SCRIPT_SCCAI_3DMCTS_SD3DSS4.00mm_THPGLMF2c.fmr";
	var nameVMRinNative = DataPath +"ripples_s03_T1_divPD_IIHC_ISOpt6.vmr";
	var nameVMRinACPC = DataPath + "ripples_s03_T1_divPD_IIHC_ISOpt6_ACPC.vmr";
	var nameVMRinTAL = DataPath + "ripples_s03_T1_divPD_IIHC_ISOpt6_TAL.vmr";
	var nameIAfile = DataPath + "ripples_s03_run1_simple_SCSTBL_3DMCS_LTR_THPGLMF6c_b02b0_TU-TO-ripples_s03_T1_divPD_IIHC_ISOpt6_IA.trf";
	var nameFAfile = DataPath + "ripples_s03_run1_simple_SCSTBL_3DMCS_LTR_THPGLMF6c_b02b0_TU-TO-ripples_s03_T1_divPD_IIHC_ISOpt6_FA.trf";
	var nameACPCfile = DataPath + "ripples_s03_T1_divPD_IIHC_ISOpt6_ACPC.trf";
	var nameTALfile = DataPath + "ripples_s03_T1_divPD_IIHC_ISOpt6_ACPC.tal";
	//var nameVTCinNative= ObjectsRawDataPath + "CG_OBJECTS_SCRIPT_NATIVE.vtc";
	//var nameVTCinACPC = ObjectsRawDataPath + "CG_OBJECTS_SCRIPT_ACPC.vtc";
	//var nameVTCinTAL= ObjectsRawDataPath + "CG_OBJECTS_SCRIPT_TAL.vtc";
	var dataType = 2; // 1: int16, 2: float32
	var resolution = 2; // one of 1, 2 or 3 mm^2
	var interpolation = 2; // : ‘0’ for nearest neighbor interpolation, ‘1’ for trilinear interpolation, ‘2’ for sinc interpolation.
	var threshold = 100; 
	var extendedBoundingBox = false;
	//var FMRs = ["ripples_"+ sub + "_run1_simple", "ripples_"+ sub + "_run2_combo", "ripples_"+ sub + "_run3_combo", "ripples_"+ sub + "_run4_simple", "ripples_"+ sub + "_run5_simple", "ripples_"+ sub + "_run6_combo", "ripples_"+ sub + "_run7_combo", "ripples_"+ sub + "_run8_simple", "ripples_"+ sub + "_run9_simple", "ripples_"+ sub + "_run10_combo", "ripples_"+ sub + "_run11_combo", "ripples_"+ sub + "_run12_simple"];
	var FMRs = ["ripples_"+ sub + "_run2_combo", "ripples_"+ sub + "_run3_combo", "ripples_"+ sub + "_run4_simple", "ripples_"+ sub + "_run5_simple", "ripples_"+ sub + "_run6_combo", "ripples_"+ sub + "_run7_combo", "ripples_"+ sub + "_run8_simple", "ripples_"+ sub + "_run9_simple", "ripples_"+ sub + "_run10_combo", "ripples_"+ sub + "_run11_combo", "ripples_"+ sub + "_run12_simple"];


/* 	This code is executed when clicking 'Run' 
	If an error occurs, it is printed to the BrainVoyager QX Log tab 
*/
	BrainVoyagerQX.ShowLogTab();
	BrainVoyagerQX.PrintToLog("Start creating VTCs...");
	for (i = 0; i < FMRs.length; i++) { 
		BrainVoyagerQX.PrintToLog("VTC for  " + FMRs[i]);
		var nameFMR = DataPath + FMRs[i] + "_SCSTBL_3DMCS_LTR_THPGLMF6c_b02b0_TU.fmr"
		var nameVTCinTAL = DataPath + FMRs[i] + "_SCSTBL_3DMCS_LTR_THPGLMF6c_b02b0_TU_TAL.vtc"

		try {
			//CreateVMRinNativeSpace(); 
			//CreateVMRinAcpcSpace();
			CreateVMRinTalairachSpace(extendedBoundingBox); // make a VTC in Talairach space with extended bounding box = false
			//extendedBoundingBox = true;
			//var nameVTCinTAL= ObjectsRawDataPath + "CG_OBJECTS_SCRIPT_TAL_ext.vtc"; // rename, so that the file won't be overwritten
			//CreateVMRinTalairachSpace(extendedBoundingBox); // make a VTC in Talairach space with extended bounding box (in z-dir)
		} catch (e) {
			BrainVoyagerQX.PrintToLog("Error: " + e);
		}
	}

/* These functions are invoked from the section above */
	function CreateVMRinNativeSpace() 
	{
		var docVMR = BrainVoyagerQX.OpenDocument(nameVMRinNative);
		docVMR.ExtendedTALSpaceForVTCCreation = false; // this is true or false
		var success = docVMR.CreateVTCInVMRSpace(nameFMR, nameIAfile, nameFAfile, nameVTCinNative, dataType, resolution, interpolation, threshold);
		docVMR.Close();
	}

	function CreateVMRinAcpcSpace() 
	{
		var docVMR = BrainVoyagerQX.OpenDocument(nameVMRinNative);
		docVMR.ExtendedTALSpaceForVTCCreation = false; // this is true or false
		var success = docVMR.CreateVTCInACPCSpace(nameFMR, nameIAfile, nameFAfile, nameACPCfile, nameVTCinACPC, dataType, resolution, interpolation, threshold);
		docVMR.Close();
	}

	function CreateVMRinTalairachSpace(useExtendedBoundingBox) 
	{
		var docVMR = BrainVoyagerQX.OpenDocument(nameVMRinNative);
		docVMR.ExtendedTALSpaceForVTCCreation = useExtendedBoundingBox; // this is true or false

		// new in v2.4.1: specify bounding box for target VTC (works for any target reference space)
		//docVMR.UseBoundingBoxForVTCCreation = true; // use bounding box
		// use properties to read and set bounding box values (here we create VTC only in lower posterior part of brain):
		//docVMR.TargetVTCBoundingBoxZStart = 110; // values will be adjusted to fit on multiple of resolution
		//docVMR.TargetVTCBoundingBoxZEnd  = 150; // values not changed (here X/Y) use default (TAL) bounding box values
		//docVMR.TargetVTCBoundingBoxYStart = 128;

		var success = docVMR.CreateVTCInTALSpace(nameFMR, nameIAfile, nameFAfile, nameACPCfile, nameTALfile, nameVTCinTAL, dataType, resolution, interpolation, threshold);
		
		docVMR.Close();

		var docVMRTAL = BrainVoyagerQX.OpenDocument(nameVMRinTAL);
		docVMRTAL.LinkVTC(nameVTCinTAL);
	}
