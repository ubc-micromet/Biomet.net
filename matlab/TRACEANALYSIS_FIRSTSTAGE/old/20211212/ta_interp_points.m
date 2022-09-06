function [data_out,index] = ta_interp_points(data_in,interp_len)
%This function performs linear interpolation of variable length on NaNs in the input
%data set.
%	INPUT:		'data_in' 		-column or row of data with NaNs present
%					'interp_len'	-maximum interpolation length
%	Output:		'data_out'		-interpolated 'data_in'
%					'index'			-indices of all interpolated points
%
%The first main algorithm searches for sequences of NaNs of length 'interp_len' or less
%using the matlab 'diff' function repeatedly.  The starting point is stored into an array
%structure(ex: first indices of all sequences of 5 NaNs are stored into ind_to_interp(5)).
%
%The next algorithm searches through data using a 'divide and conquer' algorithm to 
%interpolate NaNs of variable length:
%	1.	start from max interpolation length and cycle down to 2.
%	2. Interpolate the middle point of all sequences of NaNs with each current interpolation
%		length (found in "ind_to_interp(current)"). This splits each sequence into two.
%	3.	On Each side of this interpolated middle point is a smaller sequence of NaNs.
%		Add these sequences to the list of sequences "~ind_to_interp(curr/2)"
%	3. Finally interpolate all NaN points when the NaN sequences become length 2 or 3.
%
%
%	NOTES: 1.	Could use interp1(x,y,xi,'linear') but does not use variable length.
%  		 2.	Could use [ind=find(isnan(x)); x(ind) = (x(ind-1)+ x(ind+1))/2], but
%					only used for interpolation of length 1.
%			 3.  	In both these cases the index of interpolated points is not tracked, which
%					is need for the visual point picking tool.

data_out=data_in;
index = '';

if length(data_in) <2					%check if 'data_in' is a vector larger than one.
   return
end
temp_nan = find(isnan(data_in));
all_num = find(~isnan(data_in));			%find non_NaN data set
all_data = data_in(all_num);						

if isempty(temp_nan) | isempty(all_num)   					%if no NaNs present, do nothing.
   return
end
if length(all_num)==1												%special case if only one non-NaN
   bgn = temp_nan(find(temp_nan <all_num));
   lst = temp_nan(find(temp_nan >all_num));
   if length(bgn) <= interp_len
      data_in(bgn) = data_in(all_num);				%check at first index of data_in
   end
   if length(lst) <= interp_len
      data_in(lst) = data_in(all_num);				%check at last index of data_in
   end
   data_out = data_in;
   return
end

if temp_nan(1)==1    												%special cases for end points.
   if all_num(1)-1 <= interp_len								
      data_in(1:all_num(1)-1) = data_in(all_num(1));	%interpolate first NaNs
   end
   chck = diff(temp_nan);
   if all_num(1) > temp_nan(end)									
      data_out = data_in;
      return
   end  
end
temp_nan = find(isnan(data_in));				%interpolate NaNs at end of data set.
if temp_nan(end)==length(data_in)
   if length(data_in) - all_num(end) <= interp_len
      data_in(end:-1:all_num(end)+1) = data_in(all_num(end));
   end
   if all_num(end) < temp_nan(1)
      data_out = data_in;
      return
   end 
end

data_in(end+1) = data_in(all_num(end));
data_in(end+2:end+1+interp_len) = NaN;			%add a 0 and NaN points to the end
															%for use with the diff function.
ind_to_interp = [];
ind = find(isnan(data_in));						%find all NaN points
df = diff(ind);
ind_st = find(df==1);
ind_shift = ind_st+1;
df(ind_shift) = 1;
ind_to_interp(1).ind = ind(find(df~=1));				%find single point NaNs
index = ind_to_interp(1).ind;						%track all indices of interpolated points
for i=2:interp_len   
   df_temp = diff(ind_st);					%find multiple point NaNs
   ind_temp = find(df_temp==1);
   ind_shift = ind_temp+1;
   df_temp(ind_shift) = 1;
   mult_nan = find(df_temp~=1);   
   if i==2      
      test_n=ind_st(mult_nan);   		%find double points first
      ind_nan = ind(test_n);
      ind_to_interp(2).ind = ind_nan;
      ind_first = ind_st;
      ind_st = ind_temp;      
   end 
   if i>2
      test_n = ind_first(ind_st(mult_nan));	%find more than 2 consecutive NaNs
      ind_nan = ind(test_n);
      ind_to_interp(i).ind = ind_nan;
      ind_st = ind_st(ind_temp);
   end
   for j=1:i
      index = union(index,ind_nan+j-1);     %track all points that will be interpolated
   end
end

data_in = data_in(1:end-interp_len-2);			%remove extra data added for diff function.
sing_pts = [];


%the max interpolation length.
%(ex.ind_to_interp(5) contains the starting point
%		of each sequence of 5 NaNs).

for j=length(ind_to_interp):-1:2
   temp = ind_to_interp(j).ind;   
   if ~isempty(temp)
      if j==2
         %interpolate all pairs of NaNs 
         pt_btw = (data_in(temp-1) + data_in(temp+2))/2;		
         diff_btw = pt_btw - data_in(temp-1);
         data_in(temp) = data_in(temp-1) + diff_btw*2/3;
         data_in(temp+1) = data_in(temp-1)+ diff_btw*4/3;
      elseif j==3
         %interpolate all triples of NaNs
         data_in(temp+1) = (data_in(temp-1) + data_in(temp + j))/2;         
         sing_pts = union(sing_pts, union(temp,temp+2));         
      elseif mod(j,2)==0         
         %interpolate the middle point of even numbered sequences of NaNs 
         %and add the two sections on either side to smaller sequences to interpolate.
         pt_btw = (data_in(temp-1) + data_in(temp+j))/2;
         diff_btw = pt_btw - data_in(temp-1);					
         data_in(temp+(j/2)-1) = data_in(temp-1)+ diff_btw*j/(j+1);
         ind_to_interp(j/2-1).ind = union(ind_to_interp(j/2-1).ind, temp);
         ind_to_interp(j/2).ind = union(ind_to_interp(j/2).ind, temp+j/2);     
      elseif mod(j,2)==1          
         data_in(temp + floor(j/2)) = (data_in(temp-1) + data_in(temp + j))/2;  %middle point
         
         ind_to_interp(floor(j/2)).ind = ...
            union(ind_to_interp(floor(j/2)).ind, union(temp,temp+ceil(j/2))); 
      end    
   end
end
temp = ind_to_interp(1).ind;
temp = union(temp,sing_pts);
data_in(temp)= (data_in(temp - 1) + data_in(temp + 1))/2;
data_out = data_in;

