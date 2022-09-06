function [out1, out2, out3, out4, out5, out6] = fr_read_and_convert(par1, par2,par3)
% fr_read_and_convert - reads raw data files and converts them to eng.units
%
%   New syntax (After Nov 2001)
%   Inputs:
%       par1 = dateIn       - hhour to read
%       par2 = configIn     - configuration file
%       par3 = systemNum    - the system number 
%
%   Outputs:
%       out1 = Instrument_data().EngUnits   - all the traces 
%       out2 = Instrument_Stats()           - basic statistics and extra info (see Stats_Structure.doc under
%                                             .Instrument() for more details)
      %       out3 = headers      - all headers
%
% Old (still valid) syntax:
%       [EngUnits, RawData, DelTimes, FileName_p, EngUnits_DAQ, EngUnits_GillR2] = 
%                                                   fr_read_and_convert(DateIn, SiteID)
%
% (c) Zoran Nesic               File created:       Jun  5, 2000
%                               Last modification:  March 10, 2010
%

% Revisions:
% March 10, 2010
%   - added a check for mismatch between loggerSN in init_all files and in
%   CRBasic data files. To prevent mistaken cross calculation of data at
%   MPB sites (Nick).
% Feb 12, 2004
%   - improved "instrument missing" message by adding the instrument name to it.
%   Jun 27, 2002
%       - added polynomial conversion that used to be in fr_read_Digital1. Now each instrument must have
%         a .Poly values even if all are ones and zeros (1*x +0)
%       - moved Instrument.ProcessData from fr_create_systems here.
%   Oct 4, 2001
%       - added file type "INSTRUMENT" option (data read from an already loaded instrument)
%   Oct 1, 2001
%       - major revisions RE: conversion from a System based function (reads all Instrument files
%         for one System) to an Instrument based function (reads all Instruments regardless of the system)
%
out1 = [];out2=[];out3=[];out4=[];out5=[];out6=[];

if ~isstruct(par2) 
    % this handles legacy issues (year < 2001)
    [out1, out2, out3, out4, out5, out6] = fr_read_and_convert_old(par1, par2);
else
    % new reading function
    
    % Get input parameters
    dateIn = par1;
    configIn = par2;

    % Read all data and store it into a structure
    nInstrument = length(configIn.Instrument);
    for i=1:nInstrument
        try
            if ~strcmp(upper(configIn.Instrument(i).FileType), 'INSTRUMENT')
                funName = ['fr_read_' configIn.Instrument(i).FileType];                 % function name
                [EngUnits_tmp,headers_tmp] = feval(funName,dateIn,configIn,i);          % call the function
                Instrument_data(i).EngUnits = EngUnits_tmp;
                Instrument_data(i).Header = headers_tmp;
                % Nick added a check for logger SN between init_all and
                % read from datafile 3/10/2010
                if isfield(headers_tmp,'loggerSN') 
                   if ~isempty(configIn.Instrument(i).SerNum) & configIn.Instrument(i).SerNum ~=0
                      if headers_tmp.loggerSN~=configIn.Instrument(i).SerNum
                        disp('----------------------------------------------------------');
                        disp('*** Logger SN mismatch between data files and init_all ***');
                        disp(['for instrument # ' num2str(i) ' Type = ' configIn.Instrument(i).Name ]);
                        disp(['SN in datafile header: ' num2str(headers_tmp.loggerSN)]);
                        disp(['SN in init_all: ' num2str(configIn.Instrument(i).SerNum)]);
                        disp('...calculation aborted.');
                        disp('----------------------------------------------------------');
                        return
                      end
                   else
                      disp('----------------------------------------------------------');
                      disp(['SN for instrument # ' num2str(i) ' Type = ' configIn.Instrument(i).Type ]);
                      disp(['in init_all is missing or equal to zero. Please change.']);
                      disp('----------------------------------------------------------');
                   end
                end
    
            else
                instrumentNum = str2num(configIn.Instrument(i).FileID);
                chanNums = configIn.Instrument(i).ChanNumbers;
                Instrument_data(i).EngUnits = Instrument_data(instrumentNum).EngUnits(:,chanNums);
                Instrument_data(i).Header = [];
            end
            % run the data through polynomials
            if isfield(configIn.Instrument(i),'Poly') & ~isempty(configIn.Instrument(i).Poly)
                for j=1:configIn.Instrument(i).NumOfChans;
                    p = configIn.Instrument(i).Poly(j,:);
                    Instrument_data(i).EngUnits(:,j) = polyval(p,Instrument_data(i).EngUnits(:,j));
                end
            end

            % Run standard instrument conversions
            % for instruments like GILLR2 etc.
            if isfield(configIn.Instrument(i),'Type') & exist(['fr_process_instrument_' configIn.Instrument(i).Type])==2
                eval(['Instrument_data(i) = fr_process_instrument_' configIn.Instrument(i).Type '(Instrument_data(i),configIn,dateIn,i);']);
            end
            
            % Run extra conversions (example: open path IRGA conversion to mixing ratios)
            if isfield(configIn.Instrument(i),'ProcessData') ...
                    & ~isempty(configIn.Instrument(i).ProcessData)
                for j=1:length(configIn.Instrument(i).ProcessData)
                    eval(char(configIn.Instrument(i).ProcessData(j)));
                end
            end      
        catch
            disp(sprintf('File for %s, instrument #%d (%s) is missing!',datestr(dateIn),i,configIn.Instrument(i).Name));
            Instrument_data(i).EngUnits = [];
            Instrument_data(i).Header = [];
        end            
    end % for 

    % export Raw data
    out1 = Instrument_data;
%    out2 = Instrument_stats;
end % if ~isstruct(par2) 

%============= End of function =============



%=================================================================================
%
% Legacy version of the fr_read_and_convert
%
function [EngUnits, RawData, DelTimes, FileName_p, EngUnits_DAQ, EngUnits_GillR2] = fr_read_and_convert_old(DateIn, SiteID)

FileName_p      = FR_DateToFileName(DateIn);            % create file name for given hhour
c               = fr_get_init(SiteID,DateIn);           % get configuration data
pth             = c.path;                               % extract the path

[ RawData_DAQ, ... 
  RawData_DAQ_stats, ...
  DAQ_ON,...
  RawData_GillR2, ...
  RawData_GillR2_stats, ...
  GillR2_ON ]   = FR_read_data_files(pth,FileName_p,c); % Read in the raw data values

% if GillR2 digital input is used (GillR2_ON==1) then synchronize DAQ with GillR2    
if GillR2_ON & DAQ_ON
   [del_1,del_2] = ...
      fr_find_delay(RawData_DAQ, RawData_GillR2,[12 3],1000,[-60 60]);
   [RawData_DAQ,RawData_GillR2]= ...
      fr_remove_delay(RawData_DAQ,RawData_GillR2,del_1,del_2);
end
    
% DAQbook measurements are ON then convert DAQ measurements to eng units
if DAQ_ON
    [EngUnits_DAQ,chi,test_var] = ...
                FR_convert_to_eng_units(RawData_DAQ,2,c);
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
        EngUnits = [];
        RawData = [];
    elseif GillR2_ON == 0
        % if GillR2 is off (serial communication with it didn't work)
        % assume that DAQ book has measured proper u,v,w,T and use its 
        % measurements instead. 
        EngUnits = [ EngUnits_DAQ([14 16 12 13 5],:) ;EngUnits_DAQ]';
        RawData  = [zeros(c.GillR2chNum,length(RawData_DAQ));RawData_DAQ]';
    elseif DAQ_ON == 0
        EngUnits = [ EngUnits_GillR2 ; zeros(c.DAQchNum,length(EngUnits_GillR2))]';
        RawData  = [RawData_GillR2 ; zeros(c.DAQchNum,length(RawData_GillR2 ))]';
    else
        EngUnits = [ EngUnits_GillR2 ; EngUnits_DAQ]';
        RawData  = [RawData_GillR2 ; RawData_DAQ]';
    end
else
    if DAQ_ON == 0
        EngUnits = [];
        RawData = [];
    else
        if GillR2_ON ~= 0                           % if Gill R2 is connected to the serial port
            EngUnits_DAQ([14 16 12 13],:) = ...
                    EngUnits_GillR2(1:4,:);         % replace DAQ measurements with Gill serial port values
        end                                         % and proceed with the rest of calculations
        EngUnits = EngUnits_DAQ';
        RawData  = RawData_DAQ';            
    end
end


