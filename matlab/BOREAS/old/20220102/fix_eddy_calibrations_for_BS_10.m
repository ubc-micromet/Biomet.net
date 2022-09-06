% fix_eddy_calibrations_for_BS_10.m

% January 3, 2006:  NickG

% Performs 3 fixes:

% 1. Splices together two eddy calibration files from OBS
%     The site PC was replaced on October 13, 2005 due to a failure 
%     and the up-to-date eddy cal file was not copied over to the new PC.  
%     Therefore, in order to recover all calibration data, an
%     eddy calibration file that was archived before the most recent eddy cal fix 
%     (on October 5, 2005) before a fix for two bad H2O calibrations
%      was spliced together with the calibration file current as of
%      January 3, 2006.

% 2. Replaces an incorrect Licor SN in the current eddy cal file

% 3. Replaces the cal1 CO2 conc. in two periods: 
%    Oct. 13th to Oct 19/2005 (after the PC was changed)
%    and after Oct 20, 2005 (after new cal1 tank installed)

%  
%------------------------------------------------------
% Splice together eddy calibration files
%------------------------------------------------------
%

VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

% Load the archived eddy cal file (covers calibrations DOY 0 to 277)

fileName = '\\Paoa001\sites\Paob\HHour\calibrations_20051005.cb2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage_archived = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY_arch =(cal_voltage_archived(1,:)+cal_voltage_archived(2,:)+VB2MatlabDateOffset-GMToffset);

%
% Load the current eddy cal file--covers eddy calibrations from DOY 286 to
% end of year.
%

fileName = '\\Paoa001\sites\Paob\HHour\calibrations.CB2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY_curr = (cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% extract calibrations that were run after DOY 277

ind_replPC = find(decDOY_curr >= datenum(2005,1,277) & decDOY_curr <= datenum(2006,1,6));
cal_voltage = cal_voltage(:,ind_replPC);

%--------------replace incorrect Licor SN in current cal file-------------------

cal_voltage(3,:) = 791*ones(size(cal_voltage(3,:)));

% ---------- splice together archived and current cal_voltage arrays ---------------------------
% 

cal_voltage_spl = cat(2,cal_voltage_archived,cal_voltage);
decDOY_spl     = (cal_voltage_spl(1,:)+cal_voltage_spl(2,:)+VB2MatlabDateOffset-GMToffset);

% ----------insert correct cal1 CO2 concentrations
%           for AES #502 = 353.020 ppm, Oct. 13th to Oct 19/2005
%           for AES #516 = 359.462 ppm, Oct. 20th to present

ind_AES502repl = find( decDOY_spl >= datenum(2005,10,13) & decDOY_spl <= datenum(2006,10,19) );
ind_AES516repl = find( decDOY_spl >= datenum(2005,10,20) & decDOY_spl <= datenum(2006,1,6) );

cal_voltage_spl(4,ind_AES502repl) = 353.020;
cal_voltage_spl(4,ind_AES516repl) = 359.462;

%-----------eliminate one remaining bad calibration on DOY 228

ind_badcal                    = find(cal_voltage_spl(10,:) > 500 & (decDOY_spl >= datenum(2005,1,228) & ...
                                      decDOY_spl <= datenum(2005,1,230)));

cal_voltage_spl(6,ind_badcal) = 1;

% Save the spliced cal_voltage array to the current eddy calibrations file
fileName = '\\Paoa001\sites\Paob\HHour\calibrations.CB2';
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage_spl,'float32');
fclose(fid);
