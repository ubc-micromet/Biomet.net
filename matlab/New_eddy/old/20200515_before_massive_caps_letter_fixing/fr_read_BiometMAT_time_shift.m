function [EngUnits,Header] = fr_read_BiometMAT_time_shift(dateIn,configIn,instrumentNum)
% fr_read_BiometMat_time_shift - reads time-shifted data that is stored as a matlab file  
%
% The time shift is preset to 8 hours ahead. These files were collected
% using PST instead GMT at YF in 2017/18
%
% It passes the input parameter (with dateIn shifted by 8 hours) to
% the standard fr_read_BiometMat.m function
%
% (c) Zoran Nesic           File created:       Jan 5, 2020
%                           Last modification:  Jan 5, 2020

% Revisions
%

timeOffset = 7/24;
[EngUnits,Header] = fr_read_BiometMat(dateIn-timeOffset,configIn,instrumentNum);
