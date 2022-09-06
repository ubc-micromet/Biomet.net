function [pr, zn, z] = fr_profile_means(x,profile)
% fr_profile_means - returns various means for a profile-system trace
%
% Calculate profile system means.
%
% Inputs:
%   x   -   high-frequency data *vector*
%   profile - structure with the setup parameters (see below). 
%             This parameters are usually set in one of the ini files
%             (like fr_init_all.m)
% Outputs:
%    pr-|   (output structure)    
%       |-Avg      - mean values for each level (vector)
%       |-CycleAvg - mean values for each cycle at each level (matrix Cycles x Levels)
%       |-CycleMin - Min values for each cycle at each level (matrix Cycles x Levels)
%       |-CycleMax - Max values for each cycle at each level (matrix Cycles x Levels)
%       |-CycleStd - Std values for each cycle at each level (matrix Cycles x Levels)
%
%   zn,z    - intermediate results, used for debugging
%
%
% profile structure example:
%
% profile.Ts_profile =  45;                   % 45s for one sample level
% profile.Ts_DAQ = 20.83333;                  % samples per second
% profile.N = round(profile.Ts_DAQ * 60 * 30); % nominal number of points per half hour
% profile.Levels = 8;                         % 8 profile levels
% profile.Cycles = round(profile.N/profile.Ts_profile ...
%                        /profile.Levels/profile.Ts_DAQ);
% profile.SkipSec = 2;                        % skip this many seconds at both ends of each sample 45s-2s-2s
% profile.FlushingSec = 7;                    % seconds needed to flush the profile system between samples
% profile.MinPoints =  profile.N - 21;        % don't calculate profile means if fewer than this many point
% profile.MaxPoints = profile.N + 21;         % don't calculate profile means if more than this many point
%
%
% (c) Zoran Nesic           File created:       Feb 6, 2001
%                           Last modification:  Aug 5, 2001

% Revisions:
%
%   Aug 5, 2001
%       - sorted out the special case when n_cycles is 1


% Prepare default outputs
z_mean = NaN * zeros(1,profile.Levels);
z_meanHF = NaN * zeros(profile.Cycles,profile.Levels);
pr = NaN;
zn = NaN;
z = NaN;

% get the number of points in the input data
Nx = length(x);

% Don't calculate if the number of points is outside of the given limits
if Nx >= profile.MinPoints & Nx <= profile.MaxPoints
    Nn = floor(Nx / profile.Levels / profile.Cycles);
else
    disp('Too few points!')
    return
end
% calculate the closes number of points that will give
% an integer number of levels and cycles
N_round = Nn * profile.Levels * profile.Cycles;

% remove the data at the beginning and at the end
% of each cycle (transition junk)
skipP = floor(profile.SkipSec * profile.Ts_DAQ);        % sample equivalent of skipSec
flushingP = floor(profile.FlushingSec*profile.Ts_DAQ);  % sample equivalent of flushingSec

z = reshape(x(1:N_round),Nn,profile.Levels,profile.Cycles);
zn = z(skipP+flushingP:end-skipP+1,:,:);

if profile.Cycles == 1 
    pr.CycleAvg = mean(zn);
    pr.CycleMax = max(zn);
    pr.CycleMin = min(zn);
    pr.CycleStd = std(zn);
    pr.Avg      = pr.CycleAvg;
else
    pr.CycleAvg = squeeze(mean((zn)))';
    pr.CycleMax = squeeze(max((zn)))';
    pr.CycleMin = squeeze(min((zn)))';
    pr.CycleStd = squeeze(std((zn)))';
    pr.Avg      = mean(pr.CycleAvg);
end

