function [data_HF,data_HH] = ach_find_and_read_data(currentDate,SiteFlag,systemType)
%[data_HF, data_HH] = ach_find_and_read_data(currentDate,SiteFlag,systemType)
%
%Function that finds datafiles from automated respiration system dataloggers
%
%Input variables:   currentDate
%                   SiteFlag
%                   systemType, 1 for version 1.0 (CR10 and 21X), 2 for version 2.0 (CR23X)
%
%Output variables:  data_HF, high frequency (5 sec.) data
%                   data_HH, half hour data
%
%(c) dgg                
%Created:  Feb 1, 2005
%Revision: none
if ~exist('systemType') | isempty(systemType)
    systemType = 2;
end

%get the init data and day under analysis
c = fr_get_init(SiteFlag,currentDate);			
day = floor(fr_get_doy(currentDate,0));

%load currentDate HF and HH data (try for 3 consecutive days if file does not exist)
try
	[data_HFC,data_HHC] = ach_read_data(currentDate,SiteFlag,systemType);
catch
	try
		currentDate = currentDate+1;
		[data_HFC,data_HHC] = ach_read_data(currentDate,SiteFlag,systemType);
	catch
		try
			currentDate = currentDate+1;
			[data_HFC,data_HHC] = ach_read_data(currentDate,SiteFlag,systemType);
		catch
			disp('Chamber data can not be found!');
			return
		end
	end
end

%extract one full day of data from one or more source files
tv_HFC  = fr_round_time(fr_csi_time(data_HFC(:,c.chamber.TV_HF.ChannelNum(:,1:4))),'sec',3);
ind_HFC = find(tv_HFC > currentDate & tv_HFC <= currentDate+1);

%create year vector if using CR10 datalogger
if systemType == 1
    dateTime = ach_get_tvCR10(data_HHC,tv_HFC,c); %LOCAL FUNCTION (SEE BELOW)
else 
    dateTime = data_HHC(:,c.chamber.TV_HH.ChannelNum(:,1:3));
end
tv_HHC  = fr_round_time(fr_csi_time(dateTime),'min',1);
ind_HHC = find(tv_HHC > currentDate & tv_HHC <= currentDate+1);

%------------------------------------- HF ---------------------------------------- 
%if beginning of the day is missing by more than 1 minute load previous day's data
if (tv_HFC(1) - currentDate) >= datenum(0,0,0,0,1,0)
	%load previous day
	[data_HFP,data_HHP] = ach_read_data(currentDate-1,SiteFlag,systemType);
    data_HFC = [data_HFP; data_HFC];
	tv_HFC  = fr_round_time(fr_csi_time(data_HFC(:,c.chamber.TV_HF.ChannelNum(:,1:4))),'sec',3);
	ind_HFC = find(tv_HFC > currentDate & tv_HFC <= currentDate+1);
end
data_HFC = data_HFC(ind_HFC,:);

%if the end of the day is missing by more than 1 minute load next day's data
if (floor(currentDate)+1 - tv_HFC(end)) >= datenum(0,0,0,0,1,0)
	%load next day
	[data_HFN,data_HHN] = ach_read_data(currentDate+1,SiteFlag,systemType);
    data_HFC = [data_HFC ; data_HFN];
	tv_HFC  = fr_round_time(fr_csi_time(data_HFC(:,c.chamber.TV_HF.ChannelNum(:,1:4))),'sec',3);
	ind_HFC = find(tv_HFC > currentDate & tv_HFC <= currentDate+1);

    data_HFC = data_HFC(ind_HFC,:);
end

%------------------------------------- HH ----------------------------------------- 
%if beginning of the day is missing by more than 25 minute load previous day's data
if (tv_HHC(1) - currentDate) >= datenum(0,0,0,0,25,0)
	%load previous day if needed
    if ~exist('data_HHP')
		[data_HFP,data_HHP] = ach_read_data(currentDate-1,SiteFlag,systemType);
    end
    data_HHC = [data_HHP; data_HHC];    

    %Added Dec 5, 2005
    if systemType == 1
        dateTime = ach_get_tvCR10(data_HHC,tv_HFC,c);
    else 
        dateTime = data_HHC(:,c.chamber.TV_HH.ChannelNum(:,1:3));
    end
    
    tv_HHC  = fr_round_time(fr_csi_time(dateTime),'min',1);
    ind_HHC = find(tv_HHC > currentDate & tv_HHC <= currentDate+1);

end
data_HHC = data_HHC(ind_HHC,:);

%if the end of the day is missing by more than 25 minutes load next day's data
if ( floor(currentDate)+1 - tv_HHC(end)) >= datenum(0,0,0,0,25,0)
	%load next day if needed
    if ~exist('data_HHN')
		[data_HFN,data_HHN] = ach_read_data(currentDate+1,SiteFlag,systemType);
    end
    data_HHC = [data_HHC ; data_HHN];

    %Added Dec 5, 2005
    if systemType == 1
        dateTime = ach_get_tvCR10(data_HHC,tv_HFC,c);
    else 
        dateTime = data_HHC(:,c.chamber.TV_HH.ChannelNum(:,1:3));
    end
    
    tv_HHC  = fr_round_time(fr_csi_time(dateTime),'min',1);
    ind_HHC = find(tv_HHC > currentDate & tv_HHC <= currentDate+1);
    
    data_HHC = data_HHC(ind_HHC,:);
    
end

%-------------------------------------------------------------------------------- 

data_HF = data_HFC;
data_HH = data_HHC;

%##############
%Local function
%##############

function [dateTime] = ach_get_tvCR10(data_HHC,tv_HFC,c)

yearX = datevec(tv_HFC);
yearX = yearX(1);
if all(diff(data_HHC(:,2))>=0)
    dateTime = [yearX * ones(size(data_HHC,1),1) data_HHC(:,c.chamber.TV_HH.ChannelNum(:,1:2)) ];
end
