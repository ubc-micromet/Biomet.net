function [RawData_DAQ] =  fr_read_dmpcom_files_at_PA(pth,currentDate,SiteFlag,RawData_DAQ);

% reads in data during times when Licor data is known to have been collected via the serial port 
%  using dump-com

% (c) Nick Grant, UBC                       file created:  Jan 22, 2007            
%                                           last modified: May 2, 2007

% revisions:
% May 2, 2007: 
%   -changed enddate for reading in dumpcom files (changed to April 12,
%   2007 when LI-7000 with bad analog out was finally changed) ... Nick
% March 15, 2007: revised to handle the case of dumpcom files created
%   between Nov 24 and Dec 4, 2006 in which the last three fields are
%   columns of zeros (Nick)


FileName_p    = FR_DateToFileName(currentDate);
if pth(length(pth)) ~= '\'
    pth = [pth '\'];
end
if exist([pth FileName_p(1:6)]) == 7
    pth1 = [pth FileName_p(1:6) '\'];
elseif pth(length(pth)) ~= '\'
    pth1 = [ pth '\'];
else
    pth1 = pth;
end

fn_com        = ['data' FileName_p '.bin' ] ;
fn_com        = fullfile(pth1,fn_com);


if exist(fn_com) == 2 & upper(SiteFlag) == 'PA'
    disp(['Dump com data file ' fn_com ' found']);
    
    % March 15: added a new if test after discovering that dumpcom files created 
    % between Nov 24 and Dec 4 had 8 fields with the last 3 being columns
    % of zeros (NG)
    if currentDate >= datenum(2006,11,24) & currentDate < datenum(2006,12,4,21,30,0) % |...
         %currentDate >= datenum(2007,4,12,19,30,0) & currentDate < datenum(2007,4,18,17,30,0) % added May 1, 2007 (NG)
           
        % data was output from licor serial port into 8 columns (last three
        % columns are zeros, hhour files ~1.3MB) with no time stamp and ~36,000 
        % samples per file (20Hz). We interpolate to get back to 20.83Hz (DAQ_book sampling freq).
        
        
        [junk,co2,h2o,Tb,Pb,junk,junk,junk] = textread(fn_com,'%4s%f%f%f%f%f%f%f','delimiter','t','headerlines',1);
        
        disp(['...and read']);
        % make sure all the traces are the same length--pad the end with zeros
        % if the last row of data is incomplete
        
        len = min([length(co2) length(h2o) length(Tb) length(Pb) ]);
        co2_new = zeros(len,1);
        h2o_new = zeros(len,1);
        Tb_new  = zeros(len,1);
        Pb_new  = zeros(len,1);
        
        co2_new = co2(1:len);
        h2o_new = h2o(1:len);
        Tb_new  = Tb(1:len);
        Pb_new  = Pb(1:len);
        
        LICOR = [co2_new  h2o_new  Tb_new  Pb_new ];
        
        % convert back to counts
        [LICOR] = licor_eng2counts(LICOR,RawData_DAQ);
        
        % now resample all traces at DAQbook frequency
        [LICOR] = resmp_to_DAQ(LICOR);
        
        % overwrite existing RawData_DAQ entries
        if length(RawData_DAQ) ~= length(LICOR)
            len = min(length(RawData_DAQ),length(LICOR));
            RawData_DAQ_tmp = RawData_DAQ(:,1:len);
            RawData_DAQ_tmp(6:9,:)     = LICOR(1:4,1:len);
            RawData_DAQ = RawData_DAQ_tmp;
        else
            RawData_DAQ(6:9,:)     = LICOR(1:4,:);
        end
    
    elseif currentDate >= datenum(2006,12,4,21,30,0) & currentDate < datenum(2006,12,15,21,30,0)
            
        % data was output from licor serial port into 10 columns (hhour files ~1.7
        % MB) with a time stamp.  Samples were dropped because of the large number of output fields (10)
        % so we interpolate to get back to 20.83Hz (DAQ_book sampling
        % freq).
        
        % read in data
        [junk,tv,junk,co2,junk,junk,h2o,junk,Pb,Tb] = textread(fn_com,'%5s%f%f%f%f%f%f%f%f%f','delimiter','t','headerlines',1);    % read the data
        disp(['...and read']);
        % some files have incomplete first and last rows--need to trim
        len = min([length(co2) length(h2o) length(Tb) length(Pb) ]);
        co2_tmp = zeros(len,1);
        h2o_tmp = zeros(len,1);
        Tb_tmp  = zeros(len,1);
        Pb_tmp  = zeros(len,1);
        
        co2_tmp = co2(1:len);
        h2o_tmp = h2o(1:len);
        Tb_tmp  = Tb(1:len);
        Pb_tmp  = Pb(1:len);
        
        %tv_new = tv(1):50:tv(end);                   % Mar14/07: Nick changed
        %                                               tv(end) to tv(len)
        %                                               to prevent the case
        %                                               that the last tv
        %                                               element is garbage.
        %                                             
        tv_new = tv(1):50:tv(len);                    % create time vector for 20Hz sampling (50ms)
        [tv_intp,ind_intp]        = setdiff(tv_new,tv(1:len));    % find tv values missing from the time-stamped values due to dropped samples
        [tv_old,ind_old,ind_junk] = intersect(tv_new,tv(1:len));  % indexes of old time-stamps in the new time vector
        
        co2_new = zeros(length(tv_new),1);
        h2o_new = zeros(length(tv_new),1);
        Tb_new  = zeros(length(tv_new),1);
        Pb_new  = zeros(length(tv_new),1);
        
        % YI = INTERP1(X,Y,XI) interpolates to find YI, the values of
        % the underlying function Y at the points in the vector XI.
        % The vector X specifies the points at which the data Y is
        % given.
        
        % calculate interpolated values and read in old values so that each
        % trace has 36000 samples
        
            disp('dropped samples...interpolating...');
            co2_new(ind_intp) = interp1(tv(1:len),co2_tmp,tv_intp);
            co2_new(ind_old)  = co2_tmp;
            
            h2o_new(ind_intp) = interp1(tv(1:len),h2o_tmp,tv_intp);
            h2o_new(ind_old)  = h2o_tmp;
            
            Tb_new(ind_intp) = interp1(tv(1:len),Tb_tmp,tv_intp);
            Tb_new(ind_old)  = Tb_tmp;
            
            Pb_new(ind_intp) = interp1(tv(1:len),Pb_tmp,tv_intp);
            Pb_new(ind_old)  = Pb_tmp;
        
        LICOR = [co2_new  h2o_new  Tb_new  Pb_new ];
        
        % get rid of any NaNs introduced by interpolation at the end of the traces 
        % before resampling--replace with trace mean rather than zero
        [junk,numchans] = size(LICOR);
        for i=1:numchans
            ind_nan = find(isnan(LICOR(:,i)));
            LICOR(ind_nan,i) = nanmean(LICOR(:,i));
        end
        
        % convert back to counts
        [LICOR] = licor_eng2counts(LICOR,RawData_DAQ);
        
        % now resample all traces at DAQbook frequency
        [LICOR] = resmp_to_DAQ(LICOR);
        
        % overwrite existing crap RawData_DAQ entries--number of samples in
        % each array usually differs slightly by 3-4 samples so need to trim
        if length(RawData_DAQ) ~= length(LICOR)
            len = min(length(RawData_DAQ),length(LICOR));
            RawData_DAQ_tmp = RawData_DAQ(:,1:len);
            RawData_DAQ_tmp(6:9,:)     = LICOR(1:4,1:len);
            RawData_DAQ = RawData_DAQ_tmp;
        else
            RawData_DAQ(6:9,:)     = LICOR(1:4,:);
        end
        
    
    elseif  currentDate >= datenum(2006,12,15,21,30,0) &...
              currentDate < datenum(2007,4,12,19,30,0)   %currentDate < datenum(2022,1,0)    % May 1, 2007: changed enddate for reading in
                                                                                            %  dumpcom files. (NG)
        % data was output from licor serial port into 5 columns (hhour files ~1.125
        % MB) with no time stamp and ~36,000 samples per file (20Hz). We interpolate to 
        % get back to 20.83Hz (DAQ_book sampling freq).
        
        %disp(['Dump-com data file ' fn_com ' found']);
        
        [junk,co2,h2o,Tb,Pb] = textread(fn_com,'%4s%f%f%f%f','delimiter','t','headerlines',1);
        disp(['...and read']);
        % make sure all the traces are the same length--pad the end with zeros
        % if the last row of data is incomplete
        
        len = min([length(co2) length(h2o) length(Tb) length(Pb) ]);
        co2_new = zeros(len,1);
        h2o_new = zeros(len,1);
        Tb_new  = zeros(len,1);
        Pb_new  = zeros(len,1);
        
        co2_new = co2(1:len);
        h2o_new = h2o(1:len);
        Tb_new  = Tb(1:len);
        Pb_new  = Pb(1:len);
        
        LICOR = [co2_new  h2o_new  Tb_new  Pb_new ];
        
        % convert back to counts
        [LICOR] = licor_eng2counts(LICOR,RawData_DAQ);
        
        % now resample all traces at DAQbook frequency
        [LICOR] = resmp_to_DAQ(LICOR);
        
        % overwrite existing RawData_DAQ entries
        if length(RawData_DAQ) ~= length(LICOR)
            len = min(length(RawData_DAQ),length(LICOR));
            RawData_DAQ_tmp = RawData_DAQ(:,1:len);
            RawData_DAQ_tmp(6:9,:)     = LICOR(1:4,1:len);
            RawData_DAQ = RawData_DAQ_tmp;
        else
            RawData_DAQ(6:9,:)     = LICOR(1:4,:);
        end
    else
        RawData_DAQ = RawData_DAQ;
        disp(['...but not read']);
    end
end
%================== internal functions =====================================
function [ser_instr] = resmp_to_DAQ(ser_instr);
%--------------------------------------------------------------------------

avg         = mean(ser_instr);
ser_instr   = resample(detrend(ser_instr,0),125,120,10); % resample at DAQ freq (20.8333 Hz)
avg         = avg(ones(size(ser_instr,1),1),:);                
ser_instr   = ser_instr + avg;                % add the means back to the traces
ser_instr   = ser_instr';

%==========================================================================
function [LICOR] = licor_eng2counts(LICOR,RawData_DAQ);
%--------------------------------------------------------------------------

% note: hard wired for PA

LICOR(:,1) = LICOR(:,1)*(5000/800)*(2^15/5000);      % convert co2 ppm to counts
LICOR(:,2) = LICOR(:,2)*(5000/30)*(2^15/5000);       % convert h2o mmol to counts
LICOR(:,3) = (LICOR(:,3)/0.01221)*(2^15/5000);       % convert Tb degC to counts
LICOR(:,4) = (LICOR(:,4)-60)*(5000/60)*(2^15/5000);  % convert Pb kPa to counts 
LICOR      = LICOR + mean(RawData_DAQ(5,:));         % add DAQ zero offset measured on ch5
