function [x_bin, y_bin] = make_bin(x, y, bin, g, perc)
% make_bin.m Creates binned data with specified intervals
% function [x_bin, y_bin] = make_bin(x, y, bin, g, perc)
% inputs:   x: independant variable (to be bined)
%           y: dependant variable (to be averaged)
%           g: statistic variable to be used 
%           (1 = mean, 2 = median, 3 = max, 4 = min, 5 = sum, 6 = std, 7 = se, 8 = n)
%           bin: specified interval range eg, [0:0.1:3](with increment if different of 1) OR
%                a single number indicates # of observations in each group
%           
% outputs:  x_bin: x interval range
%           y_bin: selected binned y value (or all statistics for y)
%           
% example:  x = soil_temp_2;
%           y = storage_ori;
%           g = 1;
%           bin = [-5:.1:20];
%          

% Created by        David Gaumont-Guay   27.03.01
% Revisions: E. Humphreys Feb 20, 2002 - introduced bins with a certain number of data pts
%            E. Humphreys April 9, 2002/Sept 27, 2002 - expanded output options (renamed get_bin to make_bin)
%            E. Humphreys Nov 7, 2003 - added 'compress' as subfunction
% ------------------------------------------------
n = 8;

if length(bin) == 1;
   %bin by groups of data of length bin
   data = [x y];
   data = compress(sortrows(data,1));
   j = [1:bin:length(data)+rem(length(data),bin)];
   y_bin = NaN.*ones(length(j),n);
   x_bin = NaN.*ones(length(j),1);
   
   for i = 1:length(j);
      if j(i) > length(data);
         break
      elseif j(i)+bin-1 > length(data);   
         if nargin > 4; %take only the upper # percent of the data within the bin (for boundary line analysis)
            y_tmp = data(j(i):length(data),2);
            y_tmp = sort(y_tmp);
            n_tmp = length(y_tmp);
            y_tmp2 = y_tmp(n_tmp- perc.*n_tmp:end);
            y_bin(i,:) = [mean(y_tmp) ...
                  median(y_tmp) ...
                  max(y_tmp) ...
                  min(y_tmp) ...
                  sum(y_tmp) ...
                  std(y_tmp) ...
                  std(y_tmp)./(length(y_tmp)).^0.5...
                  length(y_tmp)];               
         else     
            y_tmp = data(j(i):length(data),2);              
            y_bin(i,:) = [mean(y_tmp) ...
                  median(y_tmp) ...
                  max(y_tmp) ...
                  min(y_tmp) ...
                  sum(y_tmp) ...
                  std(y_tmp) ...
                  std(y_tmp)./(length(y_tmp)).^0.5...
                  length(y_tmp)];
         end       
         x_bin(i) = mean(data(j(i):length(data),1));
      else
         y_tmp = data(j(i):j(i)+bin-1,2);
         if nargin > 4; %take only the upper # percent of the data within the bin (for boundary line analysis)
            y_tmp = data(j(i):length(data),2);
            y_tmp = sort(y_tmp);
            n_tmp = length(y_tmp);
            y_tmp2 = y_tmp(n_tmp- perc.*n_tmp:end);
            y_bin(i,:) = [mean(y_tmp) ...
                  median(y_tmp) ...
                  max(y_tmp) ...
                  min(y_tmp) ...
                  sum(y_tmp) ...
                  std(y_tmp) ...
                  std(y_tmp)./(length(y_tmp)).^0.5...
                  length(y_tmp)];               
         else     
            y_tmp = data(j(i):j(i)+bin-1,2);              
            y_bin(i,:) = [mean(y_tmp) ...
                  median(y_tmp) ...
                  max(y_tmp) ...
                  min(y_tmp) ...
                  sum(y_tmp) ...
                  std(y_tmp) ...
                  std(y_tmp)./(length(y_tmp)).^0.5...
                  length(y_tmp)];
         end       
         x_bin(i) = mean(data(j(i):j(i)+bin-1,1));
      end
   end
   
else
   %bin by limits on x data
   y_bin  = NaN .* ones(length(bin) - 1, n);
   
   for i = 1:length(bin)-1;
      ind = find(x >= bin(i) & x < bin(i+1));
      y_tmp = y(ind);
      cut_NaN = find(isnan(y_tmp));
      y_tmp_2 = clean(y_tmp,1,cut_NaN);
      if ~isempty(y_tmp_2);
         y_bin(i,:) = [mean(y_tmp_2) ...
               median(y_tmp_2) ...
               max(y_tmp_2) ...
               min(y_tmp_2) ...
               sum(y_tmp_2) ...
               std(y_tmp_2) ...
               std(y_tmp_2)./(length(y_tmp_2)).^0.5...
               length(y_tmp_2)];
      else
         y_bin(i,:) = NaN.*ones(1,n);
      end
   end
   
   bin = (bin(1:end-1) + bin(2:end)) / 2;
   x_bin = bin'; 
   
end

if nargin > 3
   y_bin     = y_bin(:,g);
end


%---------------------------------------------------------------------------
%compress
function[stacked_matrix] = compress(orig_matrix);

[L W] = size(orig_matrix);
Hi_mom = 0;
if L ==1;
   orig_matrix = orig_matrix';
   Hi_mom = 1;
end

      test_matrix = isnan(orig_matrix);
            [R,C] = find(test_matrix == 1);clear test_matrix
                R = unique(R);
              tmp = ones(L,1);   
           tmp(R) = NaN;   
             crit = find(isnan(tmp) == 0);   
             TMP2 = orig_matrix(crit,:); clear orig_matrix tmp R crit;                 
   
   
            [L W] = size(TMP2);
      test_matrix = isinf(TMP2);
            [R,C] = find(test_matrix == 1);clear test_matrix;
                R = unique(R);
              tmp = ones(L,1);   
           tmp(R) = NaN;   
             crit = find(isnan(tmp) == 0);   
   stacked_matrix = TMP2(crit,:); clear TMP2 tmp R crit ;                                   
   
if Hi_mom == 1;                  
   stacked_matrix = stacked_matrix';
end
