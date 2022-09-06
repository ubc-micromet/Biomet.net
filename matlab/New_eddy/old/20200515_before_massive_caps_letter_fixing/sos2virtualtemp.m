function [Tv] = sos2virtualtemp(sos);

% Inputs:  sos = sonic anemometer derived speed of sound (m/s)
% Outputs: Tv  = virtual temperature in deg C

% E. Humphreys  Oct 1, 2001

% Ref: Kaimal, J.C. and Gaynor, J.E. (1991) Another look at sonic thermometry, 
%         BLM. 56, 401-410.


%read in constants
constants;

Tv          = sos .^ 2 ./403 - ZeroK;        % virtual air temp.
