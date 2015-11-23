
//
// Example script for preprocessing a FMR project (single run)
// Feel free to adapt this script to your needs
//
//  Created by Rainer Goebel, last modified November 03 2005
//  Modified by Hester Breman for QX 2.1, August 31 2009
//  Added slice time correction command, PathToData, PathToSampleData (Rainer Goebel, January 2011)
//

// you can now use and set the properties "PathToData" and "PathToSampleData" (
//var sub = "s03";
var sub = "s05";
var DataPath = "D:\\ripples\\"+ sub + "\\images\\";
var targetFMR = DataPath + "ripples_"+ sub + "_AP.fmr";
//var MocoISAPath = "/Users/hester/Data/testdata/moco_isa/";

// This code will be executed when clicking 'Run'
//
Preprocess_allFMRs();
//MotionCorrectionISA();
//var fmrname = MocoISAPath  + "FFA_localizer_2/series0003_SCLAI2.fmr";
//MotionCorrection(fmrname, 1);

// These functions can be invoked

function Preprocess_allFMRs()
{
//ABBA
//	var FMRs = ["ripples_"+ sub + "_run1_simple", "ripples_"+ sub + "_run2_combo", "ripples_"+ sub + "_run3_combo", "ripples_"+ sub + "_run4_simple", "ripples_"+ sub + "_run5_simple", "ripples_"+ sub + "_run6_combo", "ripples_"+ sub + "_run7_combo", "ripples_"+ sub + "_run8_simple", "ripples_"+ sub + "_run9_simple", "ripples_"+ sub + "_run10_combo", "ripples_"+ sub + "_run11_combo", "ripples_"+ sub + "_run12_simple"];
//BAAB
	//var FMRs = ["ripples_"+ sub + "_run1_combo", "ripples_"+ sub + "_run2_simple", "ripples_"+ sub + "_run3_simple", "ripples_"+ sub + "_run4_combo", "ripples_"+ sub + "_run5_combo", "ripples_"+ sub + "_run6_simple", "ripples_"+ sub + "_run7_simple", "ripples_"+ sub + "_run8_combo", "ripples_"+ sub + "_run9_combo", "ripples_"+ sub + "_run10_simple", "ripples_"+ sub + "_run11_simple", "ripples_"+ sub + "_run12_combo", "ripples_"+ sub + "_AP", "ripples_"+ sub + "_PA" ];
	var FMRs = ["ripples_"+ sub + "_run1_combo", "ripples_"+ sub + "_run2_simple", "ripples_"+ sub + "_run3_simple", "ripples_"+ sub + "_run4_combo", "ripples_"+ sub + "_run5_combo", "ripples_"+ sub + "_run6_simple", "ripples_"+ sub + "_run7_simple", "ripples_"+ sub + "_run8_combo", "ripples_"+ sub + "_run9_combo", "ripples_"+ sub + "_run10_simple", "ripples_"+ sub + "_run11_simple", "ripples_"+ sub + "_run12_combo"];


	for (i = 0; i < FMRs.length; i++) { 
		BrainVoyagerQX.PrintToLog("Preprocessing " + FMRs[i]);
		Preprocess_FMR(FMRs[i]);
	}
}

function Preprocess_FMR(FMR)
{
//	var ret = BrainVoyagerQX.TimeOutMessageBox( "This script function will run standard FMR preprocessing steps.\n\nYou can cancel this script by pressing the 'ESCAPE' key.", 8);
//	if( !ret ) return;
 
	// Create a new FMR or open a previously created one.  

	var docFMR = BrainVoyagerQX.OpenDocument(DataPath  + FMR + ".fmr");
	if(docFMR == undefined)
		return;
  
	// Set spatial and temporal parameters relevant for preprocessing
	// You can skip this, if you have checked that these values are set when reading the data
	// To check whether these values have been set already (i.e. from header), use the "VoxelResolutionVerified" and "TimeResolutionVerified" properties
	//
	// if( !docFMR.TimeResolutionVerified )
	// {
	// 	docFMR.TR = 2000;
	// 	docFMR.InterSliceTime = 80;
	// 	docFMR.TimeResolutionVerified = true;
	// }
	// if( !docFMR.VoxelResolutionVerified )
	// {
	// 	docFMR.PixelSizeOfSliceDimX = 3.5;
	// 	docFMR.PixelSizeOfSliceDimY = 3.5;
	// 	docFMR.SliceThickness = 3;
	// 	docFMR.GapThickness = 0.99;
	// 	docFMR.VoxelResolutionVerified = true;
	// }
 
	// We also link the PRT file, if available (if no path is specified, the program looks in folder of dcoument)
	// docFMR.LinkStimulationProtocol( "CG_OBJECTS.prt" );
 
	// We save the new settings into the FMR file
	// docFMR.Save();
 
	//
	// Preprocessing step 1: Slice time correction
	//
	// ret = BrainVoyagerQX.TimeOutMessageBox("Preprocessing step 1: Slice time correction.\n\nTo skip this step, press the 'ESCAPE' key.", 5);
	// if(ret)
	BrainVoyagerQX.PrintToLog("Slice Time Correction");
	// docFMR.CorrectSliceTiming( 1, 3 ); // New v1.5
	docFMR.CorrectSliceTimingUsingTimeTable(2); // Interpolation method: 0: trilinear, 1: cubic spline, 2: windowed SINC. F
	// First param: Scan order 0  -> Ascending,  1  -> Asc-Interleaved,  2  -> Asc-Int2,   10 -> Descending,  11 -> Desc-Int,  12 -> Desc-Int2
	// Second param: Interpolation method: 0 -> trilinear, 1 -> cubic spline, 3 -> sinc

	// in case default options do not apply, you can now also use a free slice order (as a string param) to specify slice time correction (new in BVQX 2.3)
	// the following string specifies the same order as the "ascending interleaved" option using cubic spline interpolation
	// docFMR.CorrectSliceTimingWithSliceOrder("1 14 2 15 3 16 4 17 5 18 6 19 7 20 8 21 9 22 10 23 11 24 12 25 13", 1);

	ResultFileName = docFMR.FileNameOfPreprocessdFMR;
	docFMR.Close(); // docFMR.Remove();  // close or remove input FMR
	docFMR = BrainVoyagerQX.OpenDocument( ResultFileName );
 
	//
	// Preprocessing step 2: 3D motion correction
	//
	// ret = BrainVoyagerQX.TimeOutMessageBox("Preprocessing step 2: 3D motion correction.\n\nTo skip this step, press the 'ESCAPE' key.", 5);
	// if(ret)
	BrainVoyagerQX.PrintToLog("3D Motion Correction");
	// align to first volume of AP, sinc interpolation, use full dataset, 100 max iterations, generate movie, generate log file
	docFMR.CorrectMotionTargetVolumeInOtherRunEx(targetFMR, 1, 3, 1, 100, 1, 1);

	// docFMR.CorrectMotionTargetVolumeInOtherRun(targetFMR, 1);  // Intra-session alignment: Align everything to volume 1 of AP volumes 
	// docFMR.MotionCorrection3D();
	ResultFileName = docFMR.FileNameOfPreprocessdFMR;  // the current doc (input FMR) knows the name of the automatically saved output FMR
	docFMR.Close();            // close input FMR
	docFMR = BrainVoyagerQX.OpenDocument( ResultFileName ); // Open motion corrected file (output FMR) and assign to our doc var
	//
	// Preprocessing step 3: Spatial Gaussian Smoothing    (not recommended for individual analysis with a 64x64 matrix)
	//
	// ret = BrainVoyagerQX.TimeOutMessageBox("Preprocessing step 3: Spatial gaussian smoothing.\n\nTo skip this step, press the 'ESCAPE' key.", 5);
	// if(ret) 
	// {
	// 	docFMR.SpatialGaussianSmoothing( 4, "mm" );    // FWHM value and unit
	// 	ResultFileName = docFMR.FileNameOfPreprocessdFMR;
	// 	docFMR.Close();           // docFMR.Remove();  // close or remove input FMR
	// 	docFMR = BrainVoyagerQX.OpenDocument( ResultFileName );
	// }
 
	// Preprocessing step 4: Temporal High Pass Filter, includes Linear Trend Removal
	//
	BrainVoyagerQX.PrintToLog("Temporal high-pass filtering");
	// ret = BrainVoyagerQX.TimeOutMessageBox("Preprocessing step 4: Temporal high-pass filter.\n\nTo skip this step, press the 'ESCAPE' key.", 5);
	// if(ret) 
	docFMR.TemporalHighPassFilterGLMFourier(6);
	// docFMR.TemporalHighPassFilter( 6, "cycles" );
	//ResultFileName = docFMR.FileNameOfPreprocessdFMR;
	//docFMR.Close();           // docFMR.Remove();  // close or remove input FMR
	//docFMR = BrainVoyagerQX.OpenDocument( ResultFileName );
 
	// Preprocessing step 5: Temporal Gaussian Smoothing  (not recommended for event-related data)
	//
	// ret = BrainVoyagerQX.TimeOutMessageBox("Preprocessing step 5: Temporal gaussian smoothing.\n\nTo skip this step, press the 'ESCAPE' key.", 5);
	// if (ret)
	// {
	// 	docFMR.TemporalGaussianSmoothing( 10, "s" );
	// 	ResultFileName = docFMR.FileNameOfPreprocessdFMR;
	// 	docFMR.Close();           // docFMR.Remove();  // close or remove input FMR
	// 	docFMR = BrainVoyagerQX.OpenDocument( ResultFileName );
	// }
 
	// docFMR.Close() // you may want to close the final document, i..e to preprocess another run
}

function MotionCorrectionISA()
{
	var docFMR = BrainVoyagerQX.OpenDocument(MocoISAPath  + "FFA_localizer_2/series0003_SCLAI2.fmr");
//	docFMR.CorrectMotionTargetVolumeInOtherRun(MocoISAPath + "FFA_localizer_1/series0002_SCCAI2_3DMCT.fmr", 1 );
	docFMR.CorrectMotionTargetVolumeInOtherRunEx(MocoISAPath + "FFA_localizer_1/series0002_SCCAI2_3DMCT.fmr", 1, 1, 1, 100, 0, 1 );
}

function MotionCorrection(fmrname, targetvolume)
{
	var docFMR = BrainVoyagerQX.OpenDocument(fmrname);
 	docFMR.CorrectMotion(targetvolume); // new param: target volume, with "1" this is the same as: docFMR.MotionCorrection3D();
 
 	// for intra-session motion correction use this command (with approprate file name):
    	// docFMR.CorrectMotionTargetVolumeInOtherRun("run1.fmr", 1);
 
	 var ResultFileName = docFMR.FileNameOfPreprocessdFMR;
 	docFMR.Close();
	docFMR = BrainVoyagerQX.OpenDocument( ResultFileName );
}
