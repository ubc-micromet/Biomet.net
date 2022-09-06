function    [ RawData_DAQ, ... 
        RawData_DAQ_stats, ...
        DAQ_ON,...
        RawData_GillR2, ...
        RawData_GillR2_stats, ...
        GillR2_ON,...
        SamplesToCollect ] ...
    = FR_read_data_files(pth,FileName_p,c,SamplesToCollect);
    %
    %
    %
    % (c) Zoran Nesic           File created:       Dec   , 1997
    %                           Last modification:  March 4, 2008
    
    %
    % Revisions:
    %   March 4, 2008
    %       - added upsampling for GillR3 data from CR to reflect a change
    %       made in this function at the CR site in 2005 (Nick)
    %   Jul 25, 2001
    %       - changed:
    %           error([ 'Missing input data files: ' FileName1 ' and ' FileName2])
    %         to:
    %           disp([ 'Missing input data files: ' FileName1 ' and ' FileName2])
    %   May 16, 1998
    %       -   changed:
    %               FR_read_raw_data(FileName1,c.5);
    %           to more general:
    %               FR_read_raw_data(FileName1,c.GillR2chNum);
    %       -   implemented error handling for file_read errors
    %       -   added input parameter: SamplesToCollect that limits the number of
    %           samples read from the file to the last SamplesToCollect values
    %   Apr 16, 1998
    %       -   added channel reordering (see FR_init_all and PA_init_all for details)
    %               RawData_DAQ = RawData_DAQ(c.ChanReorder,:);
    %
    
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
    
    FileName1  = [pth1 FileName_p c.ext '1'];
    FileName2  = [pth1 FileName_p c.ext '2'];
    
    if exist('SamplesToCollect') == 0
        SamplesToCollect = 1e38;                    % if SamplesToCollect not given
    end                                             % read all the samples
    
    if exist(FileName2) == 2
        [RawData_DAQ,TotalSamples,SamplesRead]  = ...
            FR_read_raw_data(FileName2,c.DAQchNum,SamplesToCollect);
        if ~isempty(RawData_DAQ)
            RawData_DAQ = RawData_DAQ(c.ChanReorder,:);             % reorder the channels (see FR_init_all)
            RawData_DAQ_stats.TotalSamples = TotalSamples;
            RawData_DAQ_stats.SamplesRead   = SamplesRead;
            DAQ_ON = 1;
        else
            DAQ_ON = 0;
        end
    else
        RawData_DAQ                     = 0;
        RawData_DAQ_stats.TotalSamples  = 0;
        RawData_DAQ_stats.SamplesRead   = 0;
        DAQ_ON = 0;
    end
    
    if exist(FileName1) == 2
            [RawData_GillR2,TotalSamples,SamplesRead]  = ...
                FR_read_raw_data(FileName1,c.GillR2chNum,SamplesToCollect);
        
        if strcmp(upper(c.sonic),'GILLR3') & strcmp(upper(c.site),'CR')
            RawData_GillR2 = resample(RawData_GillR2',125,120)';          % resample to 20.833Hz (from 20Hz) added Mar 4, 2008
        end
                    
        if ~isempty(RawData_GillR2)
            RawData_GillR2_stats.TotalSamples  = TotalSamples;
            RawData_GillR2_stats.SamplesRead   = SamplesRead;
            GillR2_ON = 1;
        else
            GillR2_ON = 0;
        end
    else
        RawData_GillR2                      = 0;
        RawData_GillR2_stats.TotalSamples   = 0;
        RawData_GillR2_stats.SamplesRead    = 0;
        GillR2_ON = 0;
    end
    
    if isfield(c,'ext_sonic')
        % Override the existing sonic data with this from the XSITE system
        % see fr_init_all for explanation
            [RawData_GillR2]  = ...
                FR_read_digital2_file([pth1 FileName_p c.ext_sonic]);
            RawData_GillR2 = RawData_GillR2';
            TotalSamples  = length(RawData_GillR2);
            SamplesRead   = TotalSamples;
        
        if ~isempty(RawData_GillR2)
            RawData_GillR2_stats.TotalSamples  = TotalSamples;
            RawData_GillR2_stats.SamplesRead   = SamplesRead;
            GillR2_ON = 1;
        else
            GillR2_ON = 0;
        end
    end       
    
    if GillR2_ON == 0 & DAQ_ON == 0 
        disp([ 'Missing input data files: ' FileName1 ' and ' FileName2])
    end 