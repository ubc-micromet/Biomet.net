function [R3,RawData_DAQ] = fr_get_DigitalR3_at_PA(pth,FileName_p,c,RawData_DAQ);

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
    
    FileName1  = [pth1 FileName_p c.ext '3'];

    if exist(FileName1) == 2                    % if file exists
        R3 = FR_read_raw_data(FileName1,5)';    % read the data
        R3 = resample(R3/100,125,120);          % resample to 20.833Hz (from 20Hz)
        R3(:,1:3) = R3(:,1:3)/0.012/5000*2^15;  % Convert u,v,w to counts
        R3(:,4) = (R3(:,4)-273.15)/0.024/5000*2^15; % convert T to counts
        R3 = R3+ mean(RawData_DAQ(5,:));        % add the DAQ offset :-)
       [del_1,del_2] = ...
          fr_find_delay(RawData_DAQ, R3',[14 1],1000,[-60 60]);
       [RawData_DAQ,R3]= ...
          fr_remove_delay(RawData_DAQ,R3',del_1,del_2);
        RawData_DAQ([14 16 12 13],:) = R3(1:4,:);
    else
        R3 = [];
    end

