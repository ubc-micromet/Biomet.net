function data = ach_load_file(fileNameDate,loggerName,pthHF,NumOfChans,tableID)
%data = ach_load_file(fileNameDate,loggerName,pthHF,NumOfChans,tableID)
%
%Generic function for loading Chamber system logger files
%It tries to handle all the abnormalities that may happen in a CSI logger file.
%For this function to work there must be a valid and unique tableID available.  
%
%fileNameDate    -   yymmdd format (string)
%loggerName      -   logger file name (see c.chamber.namexxxxx variable in the ini file)
%pthHF           -   path to high frequency data  (output of fr_get_local_path)
%NumOfChans      -   number of output variables in the file (see c.chamber.chans_xxxx variable in the ini file)
%tableID         -   table ID is needed so the function can recover data from the files that have rows of data
%                       with incorrect number of channels.  The function looks for tableID to re-establish the
%                       data pattern. * see the NOTE below *
%
%data_HF         -   an empty matrix if there is an error, otherwise it contains the HF data
%
%NOTE: If there is a problem in a file whose tableID is matching the DOY (or some other integer in the file), this
%      function will not be able to re-establish the pattern.  Further improvements could be made by introducing
%      a two-byte patterns (tableID + Year) but that would make my head hurt. :-)
%
%(c) Zoran Nesic           File created:       Sep 30, 2002
%                          Last modification:  Nov 24, 2005

% Revisions:
%   - Nov 24, 2005, now uses fr_read_csi to load chamber datalogger .dat
%   files (David)
data = [];

filename = ([fileNameDate '\' fileNameDate '_' loggerName '.dat']);        
fname = fullfile(pthHF, filename);

if exist(fname)~=2 
   error(['File: ' fname ' does not exist!'])
end

[tv,data] = fr_read_csi(fname,[],1:NumOfChans,tableID,0,'sec',2);