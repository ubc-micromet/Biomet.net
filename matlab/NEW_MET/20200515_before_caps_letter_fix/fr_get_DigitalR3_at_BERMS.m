function [R3,RawData_DAQ] = fr_get_DigitalR3_at_BERMS(pth,currentDate,c,SiteFlag,RawData_DAQ);

    % define times when an offset existed between PC's collecting DAQ and
    % digital data at OBS  Aug4-12, 2006
    if currentDate >= datenum(2006,8,4,19,0,0) & currentDate <= datenum(2006,8,12,2,0,0)...
            & upper(SiteFlag) == 'BS'
        two_PCs = 1;
    else
        two_PCs = 0;
    end
                  
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
   
    
    % if there is an offset between DAQ and Digital data e.g. they were
    % collected on different PC's with non-synchronized clocks
    if two_PCs 
        FileName1   = [pth1 FileName_p c.ext '3'];
        currentDate = FR_prevHHour(currentDate);
        FileName_p  = FR_DateToFileName(currentDate);
        pth2        = [pth FileName_p(1:6) '\'];
        FileName2   = [pth2 FileName_p c.ext '3'];
    else 
        FileName1  = [pth1 FileName_p c.ext '3'];
    end

    if exist(FileName1) == 2  & two_PCs == 0 % if file exists and no offset
        disp(['Digital R3 data file ' FileName1 ' found']);
        R3 = FR_read_raw_data(FileName1,5)';    % read the data
        avg1 = mean(R3/100);
        R3      = resample(detrend(R3/100,0),125,120,10); % resample to 20.833Hz (from 20Hz)
        %R3 = resample(R3/100,125,120);     
        avg1 = avg1(ones(size(R3,1),1),:);                % add the means back to the traces
        R3   = R3 + avg1;
        R3(:,1:3) = R3(:,1:3)/0.012/5000*2^15;  % Convert u,v,w to counts
        R3(:,4) = (R3(:,4)-273.15)/0.024/5000*2^15; % convert T to counts
        R3 = R3+ mean(RawData_DAQ(5,:));        % add the DAQ offset :-)
       [del_1,del_2] = ...
          fr_find_delay(RawData_DAQ, R3',[14 1],1000,[-60 60]);
       [RawData_DAQ,R3]= ...
          fr_remove_delay(RawData_DAQ,R3',del_1,del_2);
        RawData_DAQ([14 16 12 13],:) = R3(1:4,:);
    elseif exist(FileName1) == 2  & exist(FileName2) == 2 & two_PCs == 1
        disp(['Digital R3 data file ' FileName1 ' found']);
        disp(['Digital R3 data file ' FileName2 ' found']);
        
        R3      = FR_read_raw_data(FileName1,5)';    % read the data for the current hhour
        R3_prev = FR_read_raw_data(FileName2,5)';    % read the data for the prev hhour
        R3_tmp  = [ R3_prev; R3 ];                   % join the two halfhours together
       
        avg1 = mean(R3_tmp/100);                     % remove mean values before resampling
        
        % resample whole Gill trace consisting of 2 half-hours joined
        % together
        R3      = resample(detrend(R3_tmp/100,0),125,120,10);  
        
        % resample previous half-hour--we need length of resampled previous half-hour 
        % to calculate the PC clock offset
        R3_prev = resample(detrend(R3_prev,0),125,120,10);  
                                                                                                               
        avg1 = avg1(ones(size(R3,1),1),:);                % add the means back to the traces
        R3   = R3 + avg1;
        R3(:,1:3) = R3(:,1:3)/0.012/5000*2^15;            % Convert u,v,w to counts
        R3(:,4) = (R3(:,4)-273.15)/0.024/5000*2^15;       % convert T to counts
        R3 = R3 + mean(RawData_DAQ(5,:));                 % add the DAQ offset :-)
        
       % find pc clock offset
       [clock_del,xc] = delay(RawData_DAQ(3,:)',R3(length(R3_prev)+1:end,4),[-5000 5000]);
       disp(['DAQ/Gill R3 PC offset calculated as ' num2str(clock_del) ' samples']);
       
       % create new traces to correct for PC clock offset, plus addnl
       % samples
       
       addnl = 200;
       R3 = [R3(length(R3_prev)-abs(clock_del)-addnl:end-abs(clock_del)-addnl,:)];
       
       % now find and remove delays (they should be around 200 samples)
        [del_1,del_2] = ...
          fr_find_delay(RawData_DAQ,R3',[3 4],2000,[-300 300])
       [RawData_DAQ,R3]= ...
          fr_remove_delay(RawData_DAQ,R3',del_1,del_2);
        RawData_DAQ([14 16 12 13],:) = R3(1:4,:);
    else
        R3 = [];    
    end

