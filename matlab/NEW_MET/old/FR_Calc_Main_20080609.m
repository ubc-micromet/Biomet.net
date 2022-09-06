function Stats = fr_calc_main(SiteFlag,startDate,endDate)
%
%
%
%
%
%
%
% (c) Zoran Nesic           File created:       Oct   , 1997
%                           Last modification:  Oct 18, 2007

%
% Revisions:
%   Oct 18, 2007
%       -removed unnecessary check for site when checking for presence
%       LI-7000...Nick
%   May 1, 2007
%       -modified "if" test checking for pressure and temperature corrected
%       data to use the licor number (c.licor)...Nick
%   Feb 19, 2007
%       - modified to ensure that serially collected LI-7000 files processed with the DAQ
%       algorithms are NOT corrected for pressure and temperature (LI-7000
%       does this already!)...Nick
%   Jan 19, 2007
%       - modified to allow serially collected dumpcom files at PA to be
%       processed (Nick)
%   Jan 20, 2006
%       - removed chamber calcs from nain calculations (dgg)
%   Mar 24, 2005
%       - removed some stupid mistake in the calculation of HRcoeff = 1e38;
%         that prevented this function from running in Matlab 6
%   Dec 05, 2003
%       - removed chamber licor and profile licor calibration extraction program from 
%         the fr_calc_main program. Daily licor calibrations are now extracted 
%         independently using a seperate matlab function - or so we hope.
%   Dec 03, 2003
%       - modified chamber calculation programs (David)
%   Dec 03, 2002
%       - added fr_profile_get_licor_cal to get calibration data from profile system on a 
%         daily basis (David)
%   Jun 29, 2002
%       - added Digital R3 supplemental program for PA site (see also fr_get_digitalR3_at_pa.m) 
%   Feb 14, 2002
%       - added chamber stats and fluxes calculations (David)
%   Aug 5, 2001
%       - worked on the modifications for the profile system. Changed the syntax
%         of fr_profile_stats_init()
%   Feb 1, 2001
%       - corrected wind direction calculation. Replaced internal function
%         Fr_Gill_wind_direction with an external function: FR_Sonic_wind_direction
%       - corrected mean wind direction calculation (by going 180-540deg)
%   Sep 28, 1999
%       - removed an extra line that was overwriting the Pbarometric
%            BarometricP = StatsRotated.AvgMinMax(1,20);     
%         for PA sites
%   Aug 29, 1999
%       - changed fr_Gill_wind_direction() so it can handle CSAT3 data.
%       - also changed the same function so it returns direction = 0 for
%         a non-existing sonic type.
%   May 23, 1999
%       - changes in hhour_calc (see below)
%   May 6, 1998
%       - added:     direction   = rem(direction,360) to
%         make the direction an angle 0-359.99
%       - changed startDate and endDate from structures to just plain 
%         double precision time/date number (startDate=now)
%   Apr 15, 1998
%       -   fixed an error in calculation for the wind direction. Due to wrong
%           assumption about the u_wind direction the calculated wind direction
%           needs to be calculated as 360 - old_direction. This has been included
%           in the program. 
%       -   added two more outputs to the "stats":
%               - Configuration      (copy of the data read from FR_init_all or PA_init_all
%               - RecalcTimeVector   (vector of datenum(s) that contains time when
%                                     data has been calculated)
%       -   changed:
%               StatsIn = fr_calc_stats([ zeros(c.GillR2chNum,length(EngUnits_DAQ)) ;EngUnits_DAQ]',c);
%           to:
%               StatsIn = fr_calc_stats([ EngUnits_DAQ([14 16 12 13 5],:) ; EngUnits_DAQ]',c);
%           This fixes problems when GillR2 serial comunication program didn't work but
%           the Gill anemometer worked well and had been measured by DAQbook. By using
%           DAQ measurements of u,v,w,T,junk we get the rest of program to work corectly:
%           the rotation can be done, proper air temperature is used, ...
%       -   if data set has less than 5 minutes of data program will not use its data at all.
%
%   Apr 13, 1998
%       -   see changes in additional_calc()
%       -   see changes in hhour_calc()
%   Apr  3, 1998
%       -   limited the delay time calculations on the data sets that have enough points:
%                   if length(EngUnits_DAQ) > max(c.Delays.ArrayLengths)
%   Mar 29, 1998
%       -   see fr_calc_stats
%       -   delay time calculation for selected channels (see fr_init_all and pa_init_all)
%
%   Mar 26, 1998
%       -   continuation of the work started on Mar 25.
%   Mar 25, 1998
%       -   changes to the main data structures. The new Stats structure has the
%           following components:
%               Stats.BeforeRot.AvgMinMax
%                              .Cov.LinDtr
%                                  .AvgDtr
%                    .AfterRot.AvgMinMax
%                             .Cov.LinDtr
%                                 .AvgDtr
%                    .RawData.AvgMinMax.Counts
%                                      .Voltages
%                    .Fluxes.LinDtr ->|
%                           .AvgDtr ->|->
%                                         [ 1. LELicor
%                                           2. SensibleSonic
%                                           3. SensibleTc1
%                                           4. SensibleTc2
%                                           5. Fc
%                                           6. LEKrypton 
%                                           7. BowenRatioLICOR
%                                           8. WaterUseEfficiency
%                                           9. Ustar
%                                          10. Penergy
%                                          11. HRcoeff
%                                          12. BowenRatioKrypton  ]
%                    .Misc -> 
%                                         [ 1. NumOfSamples_Gill
%                                           2. NumOfSamples_DAQ
%                                           3. CupWindSpeed_Gill
%                                           4. 3DWindSpeed_Gill
%                                           5. CupWindSpeed_DAQ
%                                           6. 3DWindSpeed_DAQ
%                                           7. WindDir_Gill
%                                           8. StdWindDir_Gill
%                                           9. WindDir_DAQ
%                                          10. StdWindDir_DAQ
%                                          11. co2 delay (samples)
%                                          12. h2o delay (samples)
%                                          13. T_DAQ
%                                          14. Tc1
%                                          15. Tc2
%                                          16. w_DAQ
%                                          17. kh2o
%                                           
%                    .Angles   ->
%                                        [  1. eta
%                                           2. theta
%                                           3. beta  ]
%                    .TimeVector
%                    .DecDOY
%                    .Year
%                    .Configuration
%                    .RecalcTimeVector
%
%   Mar 14, 1998
%       -   changes to enable program to work with an increased number
%           of channels in PA. New addition
%                   vec_tmp = [17:20    1:7 10 11 8 12 9 13:16];
%   Feb 11, 1998
%       -   added 'CR' support for the flux calculation
%       -   added Krypton (kh2o) support for both sites (see hhour_stats() )
%   Feb 10, 1998
%       -   added flux calculations
%       -   converted the output stats into a structure: Stats.BeforeRot, Stats.AfterRot...
%       
%   Feb 9, 1998
%       -   added MiscStats to the list of output parameters
%       -   added rotation
%   Jan 4, 1998
%       -   many changes to make this program work for PA & CR sites
%
%   Jan 3, 1998
%       -   added TimeVector to the output parameter list
%       -   changed (inside the loop)
%                   c             = fr_get_init(startDate);
%           to
%                   c             = fr_get_init(currentDate);

MAX_FLUXES      = 15;
MAX_MISC        = 15;
c               = fr_get_init(SiteFlag,startDate);
pth             = c.path;

currentDate     = startDate;
hhours          = floor( (endDate - startDate) * 48 + 1/480 ) + 1;

maxColumns      = c.DAQchNum + c.GillR2chNum;
maxCovColumns   = length(c.covVector);

Stats.BeforeRot.AvgMinMax   = zeros(4,maxColumns,hhours);
Stats.BeforeRot.Cov.LinDtr  = zeros(maxCovColumns,maxCovColumns,hhours);
Stats.BeforeRot.Cov.AvgDtr  = zeros(maxCovColumns,maxCovColumns,hhours);

Stats.AfterRot.AvgMinMax    = zeros(4,maxColumns,hhours);
Stats.AfterRot.Cov.LinDtr   = zeros(maxCovColumns,maxCovColumns,hhours);
Stats.AfterRot.Cov.AvgDtr   = zeros(maxCovColumns,maxCovColumns,hhours);

Stats.RawData.AvgMinMax.Counts    = zeros(4,maxColumns,hhours);
Stats.RawData.AvgMinMax.Voltages  = zeros(4,maxColumns,hhours);

Stats.Fluxes.LinDtr         = zeros(hhours,MAX_FLUXES);
Stats.Fluxes.AvgDtr         = zeros(hhours,MAX_FLUXES);

Stats.Misc                  = zeros(hhours,MAX_MISC);
Stats.Angles                = zeros(hhours,3);
Stats.TimeVector            = zeros(hhours,1);
Stats.DecDOY                = zeros(hhours,1);
Stats.Year                  = zeros(hhours,1);
Stats.RecalcTimeVector      = zeros(hhours,1);
Stats.Configuration(hhours+1) = c;                          % init array of structures 'c'
Stats.Configuration = Stats.Configuration(1:hhours);        % whith hhour elements. Looks bad but it works

if c.Profile.ON                                             % if profile system is ON
   try                                                      % try to initialize the profile stats
      prOut = fr_profile_stats_init(c.Profile.Cycles, ...
                                    c.Profile.Levels, ...
                                    c.Profile.Licor.Type,...
                                    hhours); 
   end
end

for i = 1:hhours
    tic;
    Stats.TimeVector(i) = currentDate;                      % store hhour's time vector 
    FileName_p    = FR_DateToFileName(currentDate);         % create file name for given hhour
    c             = fr_get_init(SiteFlag,currentDate);      % get configuration data
    Stats.Configuration(i) = c;                             % store the configuration for this hhour
    Stats.RecalcTimeVector(i)= now;                         % store when calculation has taken place

    [ RawData_DAQ, ... 
      RawData_DAQ_stats, ...
      DAQ_ON,...
      RawData_GillR2, ...
      RawData_GillR2_stats, ...
      GillR2_ON ]                   = FR_read_data_files(pth,FileName_p,c);

%------------ Jun 29, 2002 -------------------------------------------
% Special cases: Handling of GillR3 digital data (*.dp3) if available)
% if strcmp(upper(SiteFlag),'PA') & DAQ_ON 
%     [R3,RawData_DAQ] = fr_get_DigitalR3_at_PA(pth,FileName_p,c,RawData_DAQ);
% end
%------------- Oct 27, 2006 -------------------------------------------
% Handling of GillR3 digital data at OBS Aug 4-12, 2006 (*.db3) if available)
%     -new function handles PA and OBS
%---------------------------------------------------------------------
if (strcmp(upper(SiteFlag),'PA') & DAQ_ON) | (strcmp(upper(SiteFlag),'BS') & DAQ_ON) 
    [R3,RawData_DAQ] = fr_get_DigitalR3_at_BERMS(pth,currentDate,c,SiteFlag,RawData_DAQ);
end
%-------------- Jan 19, 2007 -------------------------------------------
% Handling of LI-7000 data at PA collected serially in dumpcom files 
%------------------------------------------------------------------------
if (strcmp(upper(SiteFlag),'PA') & DAQ_ON)  
    [RawData_DAQ] =  fr_read_dmpcom_files_at_PA(pth,currentDate,SiteFlag,RawData_DAQ);
end
%-------------------------------------------------------------------------

    if length(RawData_DAQ) < 10*60*20.83                    % if data set has less than 10 minutes
        DAQ_ON = 0;                                         % of data don't use it (Apr 15, 1998)
    end
    if length(RawData_GillR2) < 10*60*20.83                 % if data set has less than 10 minutes
        GillR2_ON = 0;                                      % of data don't use it
    end

    if GillR2_ON & DAQ_ON                                   % synchronize DAQ with GillR2
        [del_1,del_2] = ...
            fr_find_delay(RawData_DAQ, RawData_GillR2,[12 3],1000,[-60 60]);
        [RawData_DAQ,RawData_GillR2]= ...
            fr_remove_delay(RawData_DAQ,RawData_GillR2,del_1,del_2);
    end
    
    if DAQ_ON
        
        % commented out in order to invoke fix below: Nick, Feb 19/07
%         [EngUnits_DAQ,chi,test_var] = ...
%                     FR_convert_to_eng_units(RawData_DAQ,2,c);   
        
        %---------------- begin Nick's fix for PA with an LI-7000, Feb 19/07* --------
        %                        -from Oct 3, 2005: LI-7000 connected via
        %                        analog out to DAQbook
        %                        -from Nov 24, 2006: LI-7000 data collected digitally but processed via DAQ algorithms       
       
        % if (strcmp(upper(SiteFlag),'PA') & currentDate >= datenum(2005,10,3,0,0,0) & currentDate < datenum(2022,1,0))
        
        % if strcmp(upper(SiteFlag),'PA') & ( c.licor == 7000 ) % May 1, 2007: changed "if" test to check licor serial
                                                               %              number rather than the date (NG)
       
       if  c.licor == 7000     % Oct 18, 2007  removed the siteFlag check because a LI7000 was installed at BS (Nick)                                                          
            disp('LI-7000 data detected...');
            [EngUnits_DAQ,chi,test_var] = ...
                FR_convert_to_eng_units(RawData_DAQ,99,c);  % used a new DAQ_SYS_TYPE parameter 99--uses no temp or pressure corrections
        else                                                %   since this is already done internally by LI-7000
            [EngUnits_DAQ,chi,test_var] = ...
                FR_convert_to_eng_units(RawData_DAQ,2,c);
        end
        %--------------------- end Nick's fix----------------------
        
        %
        % Delay time calc here (for co2, h2o, kh2o using w or T as the reference)
        %
        if length(EngUnits_DAQ) > max(c.Delays.ArrayLengths)
            DelTimes = zeros(1,length(c.Delays.Channels));
            for Del_i = 1:length(c.Delays.Channels)
                DelTimes(Del_i) = fr_delay(EngUnits_DAQ(c.Delays.RefChan,1:c.Delays.ArrayLengths(1)), ...
                                    EngUnits_DAQ(c.Delays.Channels(Del_i),1:c.Delays.ArrayLengths(2)),c.Delays.Span );
            end
        end                  
    else
        EngUnits_DAQ = [];
        chi = 0;
    end
    
    if GillR2_ON
        [EngUnits_GillR2,Tair_v,test_var]   = ...
                    FR_convert_to_eng_units(RawData_GillR2,1,c,chi);
    else
        EngUnits_GillR2 = [];
    end

    if strcmp(upper(c.site),'CR')
        if GillR2_ON == 0 & DAQ_ON == 0
           StatsIn = [];
           RawDataStatsIn  = [];
        elseif GillR2_ON == 0
           % if GillR2 is off (serial communication with it didn't work)
           % assume that DAQ book has measured proper u,v,w,T and use its 
           % measurements instead. 
           StatsIn = ...
              fr_calc_stats([ EngUnits_DAQ([14 16 12 13 5],:) ;...
                              EngUnits_DAQ]',c);
           RawDataStatsIn  = ...
              fr_RawDataStats([zeros(c.GillR2chNum,length(RawData_DAQ)) ; ...
                              RawData_DAQ]');
        elseif DAQ_ON == 0
           StatsIn = ...
              fr_calc_stats([ EngUnits_GillR2 ; zeros(c.DAQchNum, ...
                              length(EngUnits_GillR2))]',c);
           RawDataStatsIn  = ...
              fr_RawDataStats([RawData_GillR2 ; zeros(c.DAQchNum, ...
                              length(RawData_GillR2 ))]');
        else
           StatsIn = ...
              fr_calc_stats([ EngUnits_GillR2 ; EngUnits_DAQ]',c);
           RawDataStatsIn  = ...
              fr_RawDataStats([RawData_GillR2 ; RawData_DAQ]');
        end
    else
        if DAQ_ON == 0
           StatsIn = [];
           RawDataStatsIn  = [];
        else
            if GillR2_ON ~= 0                           % if Gill R2 is connected to the serial port
                EngUnits_DAQ([14 16 12 13],:) = ...
                        EngUnits_GillR2(1:4,:);         % replace DAQ measurements with Gill serial port values
            end                                         % and proceed with the rest of calculations
            StatsIn = ...
                  fr_calc_stats(EngUnits_DAQ',c);
            RawDataStatsIn  = ...
                  fr_RawDataStats(RawData_DAQ');            
        end
    end
    k = 1;                                                          % get misc stats for the half hour
    Stats.Misc(i,k)  =   length(RawData_GillR2);                    % the number of samples collected from GillR2
    k = k + 1;
    Stats.Misc(i,k)  =   length(RawData_DAQ);                       % the number of samples collected from DAQ

    if ~isempty(StatsIn)
        [n,m]                       = size(StatsIn.Cov.LinDtr);
        [n1,m1]                     = size(StatsIn.AvgMinMax);                                       

        Stats.BeforeRot.Cov.LinDtr(1:n,1:m,i)       = StatsIn.Cov.LinDtr;
        Stats.BeforeRot.Cov.AvgDtr(1:n,1:m,i)       = StatsIn.Cov.AvgDtr;
        Stats.BeforeRot.AvgMinMax(1:n1,1:m1,i)      = StatsIn.AvgMinMax;    
            
        Stats.RawData.AvgMinMax.Counts(1:n1,1:m1,i) = RawDataStatsIn.AvgMinMax.Counts;
        Stats.RawData.AvgMinMax.Voltages(1:n1,1:m1,i)  = RawDataStatsIn.AvgMinMax.Voltages;
        
        MiscX = additional_calc(c,EngUnits_GillR2,EngUnits_DAQ);        % calculate additional stuff from high freq. data

        k = k+1 : length(MiscX)+k;
        Stats.Misc(i,k) = MiscX;                                        % (cup wind speed, wind direction, ...)
        k = max(k);

        k = k+1 : length(DelTimes)+k;
        Stats.Misc(i,k) = DelTimes;                                     % delay times
        k = max(k);
        
        StatsInTmp.Cov = StatsIn.Cov.LinDtr;                             % do hhour calculations on
        StatsInTmp.AvgMinMax = StatsIn.AvgMinMax;                        % linearly detrended data
        [StatsRotatedX, FluxesX,angles] = hhour_calc(c,StatsInTmp);      % Do rotation, flux and misc. other calculations
        Stats.AfterRot.Cov.LinDtr(1:n,1:m,i)  = StatsRotatedX.Cov;
        Stats.AfterRot.AvgMinMax(1:n1,1:m1,i) = StatsRotatedX.AvgMinMax;
        Stats.Fluxes.LinDtr(i,1:length(FluxesX)) = FluxesX;              % Store flux values
        
        StatsInTmp.Cov = StatsIn.Cov.AvgDtr;                             % do hhour calculations on
        [StatsRotatedX, FluxesX,angles]       = hhour_calc(c,StatsInTmp);% block-average detrended data
        Stats.AfterRot.Cov.AvgDtr(1:n,1:m,i)  = StatsRotatedX.Cov;       % Do rotation, flux and misc. other calculations
        Stats.Fluxes.AvgDtr(i,1:length(FluxesX)) = FluxesX;              % Store flux values
                   
        Stats.Angles(i,:) = angles;                                      % store angles of rotation
    end

    % profile calculations
    if c.Profile.ON
        try
            profileVoltages = (RawData_DAQ(fr_reorder_chans(c.Profile.DAQ_chans,c),:)'...
                                - mean(RawData_DAQ(5,:)) )*5000/2^15;
            prOutTmp = fr_profile_calc(profileVoltages,c);
            if isfield(prOutTmp.co2,'Avg')
                prOut = fr_profile_stats_add(prOut,prOutTmp,i);
            else
                disp('==> bad profile data');
            end
        end
    end

    currentDate     = FR_nextHHour(currentDate);
    disp(sprintf('%s,  (%d/%d), time = %4.2f (s)',FileName_p,i,hhours,toc));    
end

[Stats.DecDOY,Stats.Year] = fr_get_doy(Stats.TimeVector);   % calculate dec.time

if c.Profile.ON                                             % if profile system is ON
    try
        Stats.Profile = prOut;                              % store profile results
    end 
end

% chambers calculations
%if c.chamber.ON                                             % if chamber system is ON   
%   try 
%      chOut = ach_calc(SiteFlag,startDate,Stats,c,0);
%      Stats.Chambers = chOut;                               % store chamber results
%   catch
%      disp('Error while calculating autoch stats');
%   end
%end


%=====================================================================================
% Functions
%=====================================================================================

%===============================================================
function  [StatsIn]  = fr_calc_stats(EngUnits,c);
%
%
% Revisions
%
% Mar 29, 1998
%   -   delay removal
%   -   removed covVector from the list of input parameter and
%       added structure c instead
%

covVector               = c.covVector;
[n,m]                   = size(EngUnits);
m1                      = length(covVector);
StatsIn.AvgMinMax       = zeros(4,m);

StatsIn.AvgMinMax(1,:)  = mean(EngUnits);
StatsIn.AvgMinMax(2,:)  = min(EngUnits);
StatsIn.AvgMinMax(3,:)  = max(EngUnits);
StatsIn.AvgMinMax(4,:)  = std(EngUnits);

covData                 = EngUnits(:,covVector);                % extract data whose covariances need to be calculated
covData                 = fr_shift(covData, ...
                            c.Delays.All(covVector));           % remove the delay times for the covData
detrendVal              = detrend(covData);                     % linear detrending (only on selected vars.!)
StatsIn.Cov.LinDtr      = cov(detrendVal);
detrendVal              = detrend(covData,0);                   % block-average detrending (only on selected vars.!)
StatsIn.Cov.AvgDtr      = cov(detrendVal);

%===============================================================
function  RawDataStats  = ...
                fr_RawDataStats(RawData);
%===============================================================

[n,m]                              = size(RawData);
RawDataStats.AvgMinMax.Counts      = zeros(4,m);
RawDataStats.AvgMinMax.Voltages    = zeros(4,m);   % not yet implemented 

RawDataStats.AvgMinMax.Counts(1,:) = mean(RawData);
RawDataStats.AvgMinMax.Counts(2,:) = min(RawData);
RawDataStats.AvgMinMax.Counts(3,:) = max(RawData);
RawDataStats.AvgMinMax.Counts(4,:) = std(RawData);


%===============================================================
function  MiscX = ...
                   additional_calc(c,EngUnits_GillR2,EngUnits_DAQ)
%===============================================================

%
% Revisions:
%   Apr 13, 1998
%       -   changed line if m2 > 1
%           to           if m2 > 1 & n2 >= 16
%           to prevent program from crashing when # of channels < 16
%       -   changed MiscX       =   zeros(1,6);
%           to      MiscX       =   zeros(1,8);
%

MiscX       =   zeros(1,8);
[n1,m1]     =   size(EngUnits_GillR2);
[n2,m2]     =   size(EngUnits_DAQ);
if m2 > 1 & n2 >= 16
    MiscX(3)    =   mean(sum(EngUnits_DAQ([14 16],:).^2)'.^0.5);    % cup wind speed (DAQ)
    MiscX(4)    =   mean(sum(EngUnits_DAQ([14 16 12],:).^2)'.^0.5); % wind speed 3D vector(DAQ)
    direction   =   fr_Sonic_wind_direction(EngUnits_DAQ([14 16],:), ...
                                           c.sonic) + c.Orientation;% wind direction DAQ
    direction   =   rem(direction,360);
    MiscX(7)    =   mean(direction+180)-180;
    MiscX(8)    =   std(direction);
end
if strcmp(c.site,'PA')
    MiscX(1)    =   0;
    MiscX(2)    =   0;
elseif strcmp(c.site,'CR') & m1 > 1
    MiscX(1)    =   mean(sum(EngUnits_GillR2(1:2,:).^2)'.^0.5);     % cup wind speed GillR2
    MiscX(2)    =   mean(sum(EngUnits_GillR2(1:3,:).^2)'.^0.5);     % wind speed 3D vector GillR2
    direction   =   fr_Sonic_wind_direction(EngUnits_GillR2([1 2],:), ...
                                           c.sonic) + c.Orientation;% wind direction GillR2
    direction   =   rem(direction,360);   
    MiscX(5)    =   mean(direction+180)-180;
    MiscX(6)    =   std(direction);
end


%===============================================================
function [StatsRotated, FluxesX,angles] = hhour_calc(c,StatsIn);
%===============================================================
%
%
%
% (c) Zoran Nesic       File created:       Feb  9, 1998
%                       Last modiifcation:  May 24, 1999

%
% Revisions:
%
%   May 24, 1999
%       - moved Sensible heat calculations ahead of Krypton specific calculation
%         (it's needed for Oxigen corrections)
%       - fixed a bug with the pressure calculation (Pbarometric), when
%         looking for Pbarometric measurement program used to search for
%             [junk1,junk2] = size(StatsRotated.AvgMinMax);           % check if the pressure was measured
%             if junk2 > 25                                          % at this point in time
%         instead of 
%             if junk2 >=25 
%         this resulted in the pressure ALWAYS being Pbarometric=99. This error
%         is a flux error and needs to be corrected. Fcorrected = Fmeasured/99*Pbarometric
%         
%	Apr 25, 1999
%		- added 'BS' and 'JP' sites (same calculations as 'PA'). 
%		- fixed flux calculations so kh2o is used only if it exists
%
%   Apr 13, 1998
%       - program is now testing if the number of channels is high enough
%         before trying to extract data from a non-existant channel. This
%         prevents program from crashing when # of channels measured by
%         DAQ was 15 or 16. See lines that calculate BarometricP for both sites.
%       - added WPL and oxygen corrections for Krypton
%   Mar 26, 1998
%       -   changes to data structures (see the main program)
%   Feb 22, 1998
%       -   proper calc. of LE_Licor, converted wh from mmol/mol to g/m3
%           before applying the flux formula
%       -   corrected calculations of HRcoeff
%   Feb 11, 1998
%       -   added 'CR' support for the flux calculation
%       -   added Krypton (kh2o) calculations for both sites
%


%
% Rotation:----------------------
%
n               = length(c.covVector);
if strcmp(c.site,'PA') | strcmp(c.site,'BS') | strcmp(c.site,'JP')
    meansS          = StatsIn.AvgMinMax(1,[14 16 12]);      % get u,v,w bar
    statsS          = StatsIn.Cov;                          % extract covariances
    if strcmp(c.rotation,'N')
        [meansSr,statsSr,angles] = ...
                      fr_rotatn(meansS,statsS);              % perform rotation
    else
        %
        % Fix rotatc!!
        %
        [meansSr,statsSr,angles] = ...
                      fr_rotatn(meansS,statsS);              % perform rotation
    end
    StatsRotated.AvgMinMax    = StatsIn.AvgMinMax;
    StatsRotated.AvgMinMax(1,[14 16 12]) = meansSr;         % change only vector mean values
    StatsRotated.Cov  = statsSr;                            % and all the covariances

    % extract all the flux-calculation variables
    %
    Tair   = StatsIn.AvgMinMax(1,13)+273.15;                % absolute air temp. (degK) from sonic
    Tc1air = StatsIn.AvgMinMax(1,3)+273.15;                 % absolute air temp. (degK) from Tc1
    Tc2air = StatsIn.AvgMinMax(1,4)+273.15;                 % absolute air temp. (degK) from Tc2
    h2o_bar = StatsRotated.AvgMinMax(1,7);                  % mmol / mol of dry air
    WaterMoleFraction = h2o_bar/(1+h2o_bar/1000);           % get mmol/mol of wet air              

    [junk1,junk2] = size(StatsRotated.AvgMinMax);           % check if the pressure was
    if junk2 >= 20                                           % measured at this point in time
        BarometricP = StatsRotated.AvgMinMax(1,20);         % barometric pressure
    else 
        BarometricP = 0;                                    % else set pressure to zero
    end 
    if BarometricP < 89 | BarometricP > 105                 % check if the pressure makes sense
        BarometricP = 94.5;                                 % default pressure for PA is 94.5kPa
    end
% Commented out Sep 28, 1999
%    BarometricP = StatsRotated.AvgMinMax(1,20);             % barometric pressure 
elseif strcmp(c.site,'CR')
    %***************************************************
    % Rotation and flux calculation are based on
    % the GillR2 digital data (u1, v1, w1, T1 in the
    % MasterKeyTable). If DAQ data needs to be used
    % do the reshaping of StatsIn so u2,v2,w2,T2 change
    % places with the u1-T1.
    %***************************************************
    meansS          = StatsIn.AvgMinMax(1,[1:3]);           % get u,v,w bar
    statsS          = StatsIn.Cov;                          % extract covariances
    if strcmp(c.rotation,'N')
        [meansSr,statsSr,angles] = ...
                      fr_rotatn(meansS,statsS);             % perform rotation
    else
        [meansSr,statsSr,angles] = ...
                      fr_rotatn(meansS,statsS);             % perform rotation
    end
    StatsRotated.AvgMinMax    = StatsIn.AvgMinMax;
    StatsRotated.AvgMinMax(1,[1:3]) = meansSr;              % change only vector mean values
    StatsRotated.Cov  = statsSr;                            % and all the covariances

    % extract all the flux-calculation variables
    %
    Tair = StatsIn.AvgMinMax(1,4)+273.15;                   % absolute air temp. (degK) from sonic
    Tc1air = StatsIn.AvgMinMax(1,8)+273.15;                 % absolute air temp. (degK) from Tc1
    Tc2air = StatsIn.AvgMinMax(1,9)+273.15;                 % absolute air temp. (degK) from Tc2
    h2o_bar = StatsRotated.AvgMinMax(1,12);                 %
    WaterMoleFraction = h2o_bar/(1+h2o_bar/1000);           % get mmol/mol of wet air              

    [junk1,junk2] = size(StatsRotated.AvgMinMax);           % check if the pressure was measured
    if junk2 >= 25                                          % at this point in time
        BarometricP = StatsRotated.AvgMinMax(1,25);         % barometric pressure
    else 
        BarometricP = 0;                                    % if not assume P = 0
    end 
    if BarometricP < 89 | BarometricP > 105                 % check if pressure makes sense
        BarometricP = 99;                                   % default pressure for CR is 99kPa
    end
end
uw      = StatsRotated.Cov(1,3);                            % covariance u^w
vw      = StatsRotated.Cov(2,3);                            % covariance v^w   
wT      = StatsRotated.Cov(3,4);                            % covariance w^T (sonic temp)
wTc1    = StatsRotated.Cov(3,5);                            % covariance w^Tc1 (first thermocouple)
wTc2    = StatsRotated.Cov(3,6);                            % covariance w^Tc2 (second thermocouple)
wc      = StatsRotated.Cov(3,7);                            % covariance w^C
wh      = StatsRotated.Cov(3,8);                            % covariance w^h
hh      = StatsRotated.Cov(8,8);                            % variance h^h
constH    = 1000/461 * BarometricP / Tair;                  % conv.const. mmol/mol -> g/m3


%
% Sensible heat calculations
%

SensibleSonic  = wT * BarometricP * ( 29*(1-WaterMoleFraction/1000) ...
                 + 18*WaterMoleFraction/1000 )... 
                 * 1000 / Tair / 8.314 * 1.004;             % Sensible heat (Sonic)
SensibleTc1    = wTc1 * BarometricP * ( 29*(1-WaterMoleFraction/1000) ...
                 + 18*WaterMoleFraction/1000 )... 
                 * 1000 / Tc1air / 8.314 * 1.004;           % Sensible heat (Tc1)
SensibleTc2    = wTc2 * BarometricP * ( 29*(1-WaterMoleFraction/1000) ...
                 + 18*WaterMoleFraction/1000 )... 
                 * 1000 / Tc2air / 8.314 * 1.004;           % Sensible heat (Tc2)

if length(StatsRotated.Cov) > 8          					% do kh2o stats if it exists
   wkh2o   = StatsRotated.Cov(3,9);                         % covariance w^kh2o    
	hr      = StatsRotated.Cov(8,9);                        % covariance h^kh2o
	rr      = StatsRotated.Cov(9,9);                        % variance kh2o^kh2o
	%
	% Krypton WPL correction
	%
	% 28.96 g air/mol   (molecular weight for mean condition of air, Stull, 1995)
	% 18.02 g water/mol (molecular weight for water, Stull, 1995)
	%

	mu = 28.96/18.02;
	Pa = 1e6 * BarometricP/ 287/ Tair;
	sigma = h2o_bar*constH/Pa;
	wkh2o = (1 + mu*sigma)*(wkh2o + h2o_bar*constH/Tair*wT);
	StatsRotated.Cov(3,9) = wkh2o;
    StatsRotated.Cov(9,3) = wkh2o;
   
	oxygen_corr = 2.542 * abs(c.KH2O_poly(1))/Tair*SensibleSonic;
	LEKrypton = wkh2o * 1918.06 * ( Tair / (Tair - 33.91) )^2 + ...
                                                oxygen_corr;    % LE Krypton
	if hh == 0 | rr == 0 | isnan(hh) | isnan(rr)
   	 HRcoeff = 1e38;
	else
   	 HRcoeff = hr / abs( hh * rr ) ^ 0.5;                    % h-r correlation coeff
	end
   
else
    HRcoeff = 1e38;
    LEKrypton = 0;
end



%
% Flux calculation -----------------------------
%

wh_g      = wh * constH;                                        % convert to g/m^3
LELicor   = wh_g  * 1918.06 * ( Tair / (Tair - 33.91) ) ^ 2;    % LE LICOR

if LELicor == 0
    BowenRatioLICOR = 1e38;
else
    BowenRatioLICOR = SensibleSonic / LELicor;              % BowenRation LICOR
end

if LEKrypton == 0
    BowenRatioKrypton = 1e38;
else
    BowenRatioKrypton = SensibleSonic / LEKrypton;          % BowenRation Krypton
end

R = 8.31451;
Mc = 44;
Fc = wc * (Mc/R) * BarometricP*1000 / Tair /Mc;             % CO2 flux (umol m-2 s-1)

if wh == 0
    WaterUseEfficiency = 1e38;
else
    WaterUseEfficiency = - wc / wh;                         % WaterUseEfficiency
end

Ustar   = ( uw.^2 + vw.^2 ) ^ 0.25;                         % Ustar
Penergy = -10.47 * wc;                                      % Penergy

%
% Store fluxes in the output array
%
FluxesX = [ LELicor ...
            SensibleSonic ...
            SensibleTc1 ...
            SensibleTc2 ...
            Fc ...
            LEKrypton ...
            BowenRatioLICOR ...
            WaterUseEfficiency ...
            Ustar ...
            Penergy ...
            HRcoeff ...
            BowenRatioKrypton  ];



