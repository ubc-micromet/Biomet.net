%	Example program For Version 4: 
%
%	Program Location  =>  "C:\Ryan\DataBase_Project\currentStageOne\version4"
%
% 	1.	First copy the two directories 'trace_tool' and 'cleaning_tools' to
% 		your own computer(or add paths to the directory).
% 	2.	Then, setup the matlab search path to include these directories.
% 	3.	Next, create an ini_file and make sure its in matlab's search path.
% 	4.	Two example files for the Old Black Spruce Site are provided in the directory:
%	 			Black_Spruce_2000_TEST.ini
%				Black_Spruce_2000_TEST.mat		
%
%	INPUTS:
%  	ini_file = description of each trace.  Example in the 'stageOneExample.ini' file.
%  	mat_file = contains everything in the "ini" file AND lists points removed,
%			     restored and interpolated.  It also includes some cleaning statistics. 
%
%		Menuflag = 'view_menu' to view the setup menu.(this is the default value)
%
%	OUTPUTS:
%		An array of structures where each element represents one trace listed in the 
%		ini_file and/or mat_file.  Also returned, in each element of the structure array,
%		is the various cleaning procedures.
%
%  Some Updates:
%	1. A new statistics menu is available with two new options: view all cleaning stats,
%		and view cleaning stats of selected points.
%	2. There is a script called 'close_hid' that will delete the interface
%		if any problems occurr during execution (if interface fails to close itself).
%	3. Accelarator keys for the fullview, "f", and zoom,"z", commands.
%	4. Undo and redo work for dependent traces as well as the current trace loaded.

%First Run: reading directly from the ini_file.  
TA_FirstStage('Black_Spruce_2000_TEST.ini');
%Equivalent to
TA_FirstStage('Black_Spruce_2000_TEST.ini','','view_menu');
%OR with no menu(which will do basic cleaning and create a mat_file) with no exporting.
TA_FirstStage('Black_Spruce_2000_TEST.ini','','no_menu');

%Further Runs:
%Note: Any differences in the ini_file and mat_file are recorded into a text file which
%is saved into a specified location.
%Also, the ONLY information used from the ".mat" file are lists of points removed,restored
%and interpolated for any corresponding traces in the ini_file.   All other traces in the
%mat_file which are not present in the ini_file are ignored.  For all traces in the 
%ini_file which are not in the mat_file, the mat_file is not used.

TA_FirstStage('Black_Spruce_2000_TEST.ini','Black_Spruce_2000_TEST.mat');

%OR

%In this case all the traces in the .mat_file (including the ini information) are used.
TA_FirstStage('','Black_Spruce_2000_TEST.mat')


%-------------------------------------------------------------------------------------
%-------------------------------------------------------------------------------------
%It is also possible to import a single structure, or even a single column of data,
%directly to the function "TraceAnalysis_Tool".  This allows various data sets to be
%manually inspected.
%
%	INPUTS:
%					1. A single column of data OR
%					2. A single trace structure with the optional fields indicated in the 
%						function description for "TraceAnalysis_Tool".
%
%	OUTPUTS:
%					A single trace structure that can be re-input when calling 
%					"TraceAnalysis_Tool" again.
%
%

%The syntax is 
trace_structure = TraceAnalysis_Tool(randn(1000,1));

%OR

trace_structure = TraceAnalysis_Tool(one_trace_structure);


%-------------------------------------------------------------------------------------
%-------------------------------------------------------------------------------------
%SCRIPT: Close_Program
%This script file will close all figures currenlty open (all children of the root).
%So if any of the interfaces failed to close during an abnormal program termination,
%this script will delete them.
% Syntax:
close_program

