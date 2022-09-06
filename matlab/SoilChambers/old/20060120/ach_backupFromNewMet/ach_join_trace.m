function [t,x] = ach_join_trace_(traceName,startDay,endDay,fileExt,pth)
%
%  This program joins traces from autochambers data.
%
%	inputs:   traceName - e.g. statsMisc(:,9) 
%             startDay  - in decimals
%				endDay    - in decimals
%				fileExt   - '.hc.mat' or '.hp.mat' or 's.hc.mat' or 's.hp.mat'
%				pth       - hhour data path
%	
%
%	outputs: 	t - timevector in Tdoy (GMT) (add one for Julian DOY)
%				x = joined trace
%
%(c) dgg                    File created:       May 07, 1998
%                           Last modification:  Jan 06, 2006
%
%
% Revisions:
%
%   Jan 6, 2006
%       - fixed DOY calculations that assumed year = 2005
%          used: datenum(d_vec(1),1,0); instead of datenum(2005,1,0);
%         form more details see below
%   Feb 02, 2004
%       - created this new program (fromEva and Zoran's work) for loading of automated 
%         chamber data. The other program "fr_join_trace" is still used for eddy and profile data
%   Nov 23, 2000
%       - attempted to fix the bug that prevented this program from working when
%         the first day or two do not exist.
%   Mar 30, 2000
%       - attempted to fix the bug that caused the program to stop running if
%         a file is missing. Now it should work as long as the first file exists!
%   May 29, 1998
%       - fixed the program so it can load multiple traces (now it works
%         with traceName='squeeze(stats.AfterRot.AvgMinMax(1:3,10,:))'
%

pth_out = fr_valid_path_name(pth);
if isempty(pth_out)
    msg = ['Directory does not exist!'];
    error(msg)
else
    pth = pth_out;
end

if fileExt(end-3:end) ~= '.mat'
   fileExt = [fileExt '.mat'];
end

t = [];
x = [];
for i=startDay:endDay
   fileName = datestr(i,2);
   fileName = fileName([7 8 1 2 4 5]);
   fileName = [pth fileName  fileExt];
    try
       eval(['load ' fileName])
       % Deal with YF data
       if exist('Stats') == 1
           stats.Chambers = Stats;
           d_vec = datevec(Stats.Time_vector_HH(end));
           stats.DecDOY = Stats.Time_vector_HH-datenum(d_vec(1),1,0);
           clear Stats;
       end
       % END Deal with YF data
       c = [ 'x1 = ' traceName ';'];
       eval(c);
       t = [t ; stats.DecDOY];
       if ~isempty(x1)
           z = i;
       else
           z = 0;
       end
    catch
       z = 0;
    end
    if z > 0, 
        break;
    end
end   

t = [];
x = [];

if z == 0, 
    return,
end

for i=z:endDay
   fileName = datestr(i,2);
   fileName = fileName([7 8 1 2 4 5]);
   fileName = [pth fileName  fileExt];
    try
       eval(['load ' fileName])
       % Deal with YF data
       if exist('Stats') == 1
           stats.Chambers = Stats;
           d_vec = datevec(Stats.Time_vector_HH(end));
           stats.DecDOY = Stats.Time_vector_HH-datenum(d_vec(1),1,0);
           clear Stats
       end
       % END Deal with YF data
       c = [ 'x1 = ' traceName ';'];
       eval(c);
       t = [t ; stats.DecDOY];
    catch
       %uses this part to fix missing days (when they don't appear at
       %the beginning of the period)
       t = [t ;linspace(t(end)+1/48,t(end)+1,48)'];
       [mm,nn]= size(x1);  
       nn1 = min(mm,nn);     
       x1 = zeros(48,nn1);
    end            
   [m,n]= size(x1);
   if m == 48
       x = [x ; x1];
   else
       [mm,nn]= size(x1);  
       nn1 = min(mm,nn);     
       x1 = zeros(48,nn1);
       x = [x ; x1];
   end
end   
