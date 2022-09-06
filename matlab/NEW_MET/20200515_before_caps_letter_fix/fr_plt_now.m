function [EngUnits_GillR2,EngUnits_DAQ,RawData_GillR2,RawData_DAQ] = fr_plt_now(chanNum,num_of_samples,systemFlag,dateIN,SiteFlag)

if ~exist('SiteFlag')
    SiteFlag = FR_current_siteID;
 end
 
if ~exist('num_of_samples')
   num_of_samples = [];
end
    
if ~exist('chanNum')
   chanNum = 'CO2';
end

if isstr(chanNum)
   switch chanNum
   case 'CO2',
      chanNum = 6;
   case 'H2O'
      chanNum = 7;
   otherwise
      chanNum = chanNum;
   end
end
if ~exist('systemFlag')             % systemFlag = 1 for GillR2, 2 for DAQ book
   systemFlag = 2;
end


if exist('dateIN') & ~isempty(dateIN) & FR_nextHHour(now) ~= FR_nextHHour(dateIN)
    tmpNow = FR_nextHHour(dateIN);          % use given date
else
    tmpNow = FR_nextHHour(now);             % or assume NOW
    pth = 'e:\data\';
end

[	startDate.year,...
 	startDate.month,...
	startDate.day,...
	startDate.hour,...
	startDate.minute] = datevec(tmpNow);

startDate.num   = tmpNow;

c               = fr_get_init(SiteFlag,startDate.num);
if ~exist('pth')
    pth             = c.path;
end

currentDate     = startDate.num;

    FileName_p    = FR_DateToFileName(currentDate);

    [ RawData_DAQ, ... 
      RawData_DAQ_stats, ...
      DAQ_ON,...
      RawData_GillR2, ...
      RawData_GillR2_stats, ...
      GillR2_ON ]                   = FR_read_data_files(pth,FileName_p,c,num_of_samples);
       
%if ~isempty(num_of_samples)
   
	 %
    % if this is PA data, shift it in such a way that it becomes the same as
    % the weird CR data (don't ask!)
    % This enables us to use the same calc. procedures on both PA and CR data
    % later on
    %
%    if DAQ_ON & strcmp(upper(SiteFlag),'PA')
%        if c.DAQchNum < 20
%            vec_tmp = [17:19 19 1:7 10 11 8 12 9 13:16];
%        else
%            vec_tmp = [17:20    1:7 10 11 8 12 9 13:16];
%        end
%        RawData_DAQ = RawData_DAQ(vec_tmp,:);
%        c.gains = c.gains(vec_tmp);
%    end
    

    if GillR2_ON & DAQ_ON
        [del_1,del_2]   = fr_find_delay(RawData_DAQ, ...
                                    RawData_GillR2,[12 3],2000,[-80 80]);
        [RawData_DAQ, ...
         RawData_GillR2]= fr_remove_delay(RawData_DAQ, ...
                            RawData_GillR2, del_1,del_2);
    end
    
    if DAQ_ON
        [EngUnits_DAQ,chi,test_var] = ...
                    FR_convert_to_eng_units(RawData_DAQ,2,c);
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
    

    if systemFlag == 1
        t = (1:length(EngUnits_GillR2))/20.832;
        plot(t,EngUnits_GillR2(chanNum,:));
    else
        t = (1:length(EngUnits_DAQ))/20.832;    
        plot(t,EngUnits_DAQ(chanNum,:));
    end
    xlabel('(sec)')
    title(FileName_p)
    
zoom on