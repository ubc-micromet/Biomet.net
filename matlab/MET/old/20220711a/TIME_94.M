function [time_94, data_94] = time_94(t, data);
%*****************************************************************%
% THIS MATLAB FUNCTION CONVERTS TIME O = AUG 1 1993 TO            %
% TIME 0 = JAN 1 1994                                             %
%                                                                 %
%                function time_94 = time_94(t,data);              %
%                                                                 %
%                 t = vector containing the decimal DOY you       %
%                     wish to convert                             %
%                 data = vector containing the data you wish      %
%                        to shift along with time                 %
%*****************************************************************%        

time_94 = t - 153; 
ind = find(time_94 >= 0);
time_94 = time_94(ind);
data_94 = data(ind);
