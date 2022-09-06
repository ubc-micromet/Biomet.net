function fr_chamber_plot_HF(ch,currentDate,SiteFlag,i)
%Function that plots HF CO2 data from soil chamber measurements (from recalculated hhour files)
%
%called within TA_contextmenu(Trace analysis tool)
%
%syntax: fr_chamber_plot_HF(ch,currentDate,SiteFlag,i)
%
%(c) dgg     Apr. 4, 2002
dayOffSet = datenum(0,0,1,0,0,0);

[y,m,d,h,m,s] = datevec(currentDate);

if (upper(SiteFlag) == 'bs' & currentDate < datenum(2002,04,07) & h > 12) | ...
 (upper(SiteFlag) == 'pa' & currentDate < datenum(2002,03,25) & h > 12)
      currentDateNew = currentDate;
elseif (upper(SiteFlag) == 'bs' & currentDate < datenum(2002,04,07) & h < 12) | ...
 (upper(SiteFlag) == 'pa' & currentDate < datenum(2002,03,25) & h < 12)
      currentDateNew = currentDate - dayOffSet;
else
      currentDateNew = currentDate;
end

%loads file
pthIn = ['\\Annex001\database\' num2str(y) '\' upper(SiteFlag) '\hhour_database\'];

c = fr_get_init(upper(SiteFlag),currentDateNew);
fileNameDate = FR_DateToFileName(currentDateNew); 
fileNameDate = fileNameDate(1:6);

MAT_filename = ([fileNameDate c.hhour_ch_ext]);   % name of hhour file

if exist([pthIn MAT_filename]) == 2
   fname = ([pthIn MAT_filename]);
   load(fname)    
   load(fname)
else
   warndlg('HF data cannot be found in the database','Warning');
end

CO2_HF = Stats.Chambers.CO2_HF;
Time_vector_HF = Stats.Chambers.Time_vector_HF;

%creates index for the chamber under cleaning
ls = datenum(0,0,0,0,0,c.chamber.slopeLength); 

ch = str2num(ch); 
chMax = c.chamber.chNbr; %number of chambers connected to the system

chOffSet = chMax-ch+1;

skipSec = datenum(0,0,0,0,0,c.chamber.slopeStartPeriod);

ind = find(Time_vector_HF >= (currentDate-(ls*chOffSet)) + skipSec & ...
           Time_vector_HF <= (currentDate-(ls*(chOffSet-1))) - skipSec);  

%plots HF CO2 data with the selected index
GMTOffSet = datenum(0,0,0,6,0,0);

figure(i);
plot(Time_vector_HF-GMTOffSet,CO2_HF);
hold on;
plot(Time_vector_HF(ind)-GMTOffSet,CO2_HF(ind),'ro');
hold off;
datetick('x',15);
title(datestr(currentDate-GMTOffSet));
axis([Time_vector_HF(1)-GMTOffSet Time_vector_HF(end)-GMTOffSet 200 1000]);
xlabel('Time of day');
ylabel('CO_2 (ppm)');
zoom on;
grid on;

clear currentDateNew;
clear currentDate;
