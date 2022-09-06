function [data_HF, data_HH] = ach_find_and_read_data(currentDate,SiteFlag,systemType)
%Function that finds and reads datafiles from automated respiration system dataloggers
%
%[data_HF, data_HH] = ach_find_and_read_data(currentDate,SiteFlag,systemType)
%
%Input variables:   currentDate
%                   SiteFlag
%                   systemType, 1 for version 1.0 (CR10 and 21X), 2 for version 2.0 (CR23X)
%
%Output variables:  data_HF, high frequency (0.2 Hz) data
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

%Find beginning (S) and end (E) of HF and HH data for currentDate
if day == 1
	dayN = 366
else
	dayN = day;
end
indHFS = find(data_HFC(:,3) == dayN-1 & data_HFC(:,4) == 2400); %currentDate-1 at 24:00
indHHS = find(data_HHC(:,3) == day & data_HHC(:,4) == 30);      %currentDate at 00:30
indHFE = find(data_HFC(:,3) == day & data_HFC(:,4) == 2359);    %currentDate at 23:59
indHHE = find(data_HHC(:,3) == day & data_HHC(:,4) == 2400);    %currentDate+1 at 24:00

%-------------------------------------- HH -------------------------------------- 
if isempty(indHHS)
	%load previous day
	[data_HFP,data_HHP] = ach_read_data(currentDate-1,SiteFlag,systemType);
	indHHSP = find(data_HHP(:,3) == day & data_HHP(:,4) == 30); 
	if isempty(indHHSP)
		disp('Beginning of HH file can not be found!');
		return
	else
		data_HHCNew = data_HHP(indHHSP:end,:);
	end
else
	data_HHCNew = data_HHC(indHHS:end,:);
end

if isempty(indHHE)
	%load following day
	[data_HFF,data_HHF] = ach_read_data(currentDate+1,SiteFlag,systemType);
	indHHEF  = find(data_HHF(:,3) == day & data_HHF(:,4) == 2400);
	if isempty(indHHEF)
		disp('End of HH file can not be found!');
		return
	else
		data_HHCNew = [data_HHCNew(:,:);data_HHF(1:indHHEF,:)];
	end
else
	data_HHCNew = [data_HHCNew(:,:);data_HHC(1:indHHE,:)];
end

if ~isempty(indHHS) & ~isempty(indHHE) 
    data_HHCNew = data_HHC(indHHS:indHHE,:);
end


%-------------------------------------- HF -------------------------------------- 
if isempty(indHFS)
	%load previous day
	[data_HFP,data_HHP] = ach_read_data(currentDate-1,SiteFlag,systemType);
	indHFSP = find(data_HFP(:,3) == day-1 & data_HFP(:,4) == 2400);
	if isempty(indHFSP)
		disp('Beginning of HF file can not be found!');
		return
	else
		indHFSP = indHFSP(1);
		data_HFCNew = data_HFP(indHFSP:end,:);
	end
else
	indHFS = indHFS(1);
	data_HFCNew = data_HFC(indHFS:end,:);
end

if isempty(indHFE)
	%load following day
	[data_HFF,data_HHF] = ach_read_data(currentDate+1,SiteFlag,systemType);
	indHFEF  = find(data_HFF(:,3) == day & data_HFF(:,4) == 2359);
	if isempty(indHFEF)
		disp('End of HF file can not be found!');
		return
	else
		indHFEF = indHFEF(end);
		data_HFCNew = [data_HFCNew(:,:);data_HFF(1:indHFEF,:)];
	end
else
	indHFE = indHFE(end); 
	data_HFCNew = [data_HFCNew(:,:);data_HFC(1:indHFE,:)];
end

if ~isempty(indHFS) & ~isempty(indHFE) 
    data_HFCNew = data_HFC(indHFS:indHFE,:);
end

%-------------------------------------------------------------------------------- 

data_HF = data_HFCNew;
data_HH = data_HHCNew;

