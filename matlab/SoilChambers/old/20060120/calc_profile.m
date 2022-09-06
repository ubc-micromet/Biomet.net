function [t,s] = calc_profile(timeSer, dataIn, status, flagVoltages, Skip_count);
%
% Program to plot Co2 and H2o profiles
%
%
% Inputs: 	t = timevector
%				dataIn = column with input data
%				status = input data status or flags (to indicate which profile level measured, etc)
%				flagVoltages = possible status values
%				Skip_count = how many values ignore from the beginning when calculating means
%
% Outputs: 	t = matrix with times associated with each mean for each possible status
%				s = matrix with means associated with each possible status
%
% Elyn Humphreys and Zoran Nesic			Oct 13, 1998

N = length(flagVoltages)
nDays = 14;
nHHours = 48;
mins = 5;
s = zeros(nDays*nHHours*mins,N);
t = zeros(nDays*nHHours*mins,N);

for mainIndex = 1:N
   ind_lv =find(status == flagVoltages(mainIndex));
	d=(diff(ind_lv));
	tmp = find(d > 1);
	d = d(min(tmp):end);
	ind_lv = ind_lv(min(tmp):end); 
	k = 0;
	old_k = 0;
	m = 0;
	flag1 = 0;
	for i=1:length(d)
   	if d(i) > 1 & flag1 == 0
      	k = k+1;
	      flag1 = 1;
   	   t(k,mainIndex) = timeSer(ind_lv(i+1));
	   elseif d(i) > 1 & flag1 == 1
   	   flag1 = 2;
	   end
   	switch flag1
	   	case 0,disp('Something is wrong(0)!')
	      case 1,
   	      m = m+1;
      	   if m > Skip_count
         	   s(k,mainIndex) = s(k,mainIndex) + dataIn(ind_lv(i+1));
	         end
         case 2,
            s(k,mainIndex) = s(k,mainIndex) / (m - Skip_count);
            m = 0;
	         flag1=1;
   	      k = k +1;
      	   m = m+1;
         	t(k,mainIndex) = timeSer(ind_lv(i+1));
	         if m > Skip_count
   	         s(k,mainIndex) = s(k,mainIndex) + dataIn(ind_lv(i+1));
      	   end
	      otherwise,disp('Something is wrong(1)!')
   	end     
   end
   disp('Getting mean');
end

