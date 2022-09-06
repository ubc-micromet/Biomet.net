function Stats = fr_calc_rmy(SiteFlag,startDate,endDate)
% Calc RMY stats just like for the main eddy system
%
% (c) kai*           File created:       Jul 14, 2003
%                    Last modification:  -

%
% Revisions:

MAX_FLUXES      = 2;
MAX_MISC        = 4;
% c               = fr_get_init(SiteFlag,startDate);
% Define all neccessary c elements here
% Below canopy RMY
c.PC_name       = fr_get_pc_name;
[c.path,c.hhour_path] = fr_get_local_path;
c.ext           = '.DC6';
c.hhour_ext     = '.hc_rmy.mat';
c.site          = 'CR';
c.sonic       	= 'RMY';
c.covVector    = [1 2 3 4];
c.Orientation  = 93;
c.rotation     = 'N';

pth             = c.path;

currentDate     = startDate;
hhours          = floor( (endDate - startDate) * 48 + 1/480 ) + 1;

maxColumns      = 4;
maxCovColumns   = length(c.covVector);

Stats.BeforeRot.AvgMinMax   = zeros(4,maxColumns,hhours);
Stats.BeforeRot.Cov.LinDtr  = zeros(maxCovColumns,maxCovColumns,hhours);
Stats.BeforeRot.Cov.AvgDtr  = zeros(maxCovColumns,maxCovColumns,hhours);

Stats.AfterRot.AvgMinMax    = zeros(4,maxColumns,hhours);
Stats.AfterRot.Cov.LinDtr   = zeros(maxCovColumns,maxCovColumns,hhours);
Stats.AfterRot.Cov.AvgDtr   = zeros(maxCovColumns,maxCovColumns,hhours);

Stats.Fluxes.LinDtr         = zeros(hhours,MAX_FLUXES);
Stats.Fluxes.AvgDtr         = zeros(hhours,MAX_FLUXES);

Stats.Misc                  = zeros(hhours,MAX_MISC);
Stats.Angles                = zeros(hhours,3);
Stats.TimeVector            = zeros(hhours,1);
Stats.DecDOY                = zeros(hhours,1);
Stats.Year                  = zeros(hhours,1);
Stats.RecalcTimeVector      = zeros(hhours,1);
Stats.Configuration(hhours+1) = c;                          % init array of structures 'c'
Stats.Configuration = Stats.Configuration(1:hhours);        % whith hhour elements. Looks bad but it works

for i = 1:hhours
    tic;
    Stats.TimeVector(i) = currentDate;                      % store hhour's time vector 
    FileName_p = FR_DateToFileName(currentDate);         % create file name for given hhour
    FileName = fullfile(c.path,FileName_p(1:6),FileName_p);
       
    Stats.Configuration(i) = c;                             % store the configuration for this hhour
    Stats.RecalcTimeVector(i)= now;                         % store when calculation has taken place
    
    if exist([FileName '.bin'])
       try
          [a1,b1,c1,d1] = textread([FileName '.bin'],' %f %f %f %f','headerlines',1); % in case first line is crap.
       catch
          a1 = 0; b1 = 0; c1 = 0; d1 = 0;
		    disp(['Could not read ' FileName_p]);    
       end
       len_data = min([length(a1) length(b1) length(c1) length(d1)]);
       EngUnits_RMY = [a1(1:len_data) b1(1:len_data) c1(1:len_data) d1(1:len_data)];
    elseif  exist([FileName '.DC6'])
       EngUnits_RMY = fr_read_Digital2_file([FileName '.DC6']);
       len_data = length(EngUnits_RMY);
    else
       disp(['No data for ' FileName]);
    end
    
    if len_data>1
       StatsIn = fr_calc_stats([EngUnits_RMY],c);
    else
       StatsIn = [];
    end
                 
    k = 1;                                                          % get misc stats for the half hour
    Stats.Misc(i,k)  =   length(EngUnits_RMY);                    % the number of samples collected from GillR2
    k = k + 1;
    Stats.Misc(i,k)  =   0;                       % the number of samples collected from DAQ

    if ~isempty(StatsIn)
        [n,m]                       = size(StatsIn.Cov.LinDtr);
        [n1,m1]                     = size(StatsIn.AvgMinMax);                                       

        Stats.BeforeRot.Cov.LinDtr(1:n,1:m,i)       = StatsIn.Cov.LinDtr;
        Stats.BeforeRot.Cov.AvgDtr(1:n,1:m,i)       = StatsIn.Cov.AvgDtr;
        Stats.BeforeRot.AvgMinMax(1:n1,1:m1,i)      = StatsIn.AvgMinMax;    
            
        MiscX = additional_calc(c,EngUnits_RMY');        % calculate additional stuff from high freq. data

        k = k+1 : length(MiscX)+k;
        Stats.Misc(i,k) = MiscX;                                        % (cup wind speed, wind direction, ...)
        k = max(k);

        StatsInTmp.Cov = StatsIn.Cov.LinDtr;                             % do hhour calculations on
        StatsInTmp.AvgMinMax = StatsIn.AvgMinMax;                        % linearly detrended data
        [StatsRotatedX, FluxesX,angles] = hhour_calc(c,StatsInTmp);      % Do rotation, flux and misc. other calculations
        Stats.AfterRot.Cov.LinDtr(1:n,1:m,i)  = StatsRotatedX.Cov;
        Stats.AfterRot.AvgMinMax(1:n1,1:m1,i) = StatsRotatedX.AvgMinMax;
        Stats.Fluxes.LinDtr(i,1:length(FluxesX)) = FluxesX;              % Store flux values
        
        StatsInTmp.Cov = StatsIn.Cov.AvgDtr;                             % do hhour calculations on
        [StatsRotatedX, FluxesX,angles]       = hhour_calc(c,StatsInTmp);% block-average detrended data
        Stats.AfterRot.Cov.AvgDtr(1:n,1:m,i)  = StatsRotatedX.Cov;       % Do rotation, flux and misc. other calculations
        Stats.Fluxes.AvgDtr(i,1:length(FluxesX)) = FluxesX;              % Store flux values
                   
        Stats.Angles(i,:) = angles;                                      % store angles of rotation
    end
    
    currentDate     = FR_nextHHour(currentDate);
    disp(sprintf('%s,  (%d/%d), time = %4.2f (s)',FileName_p,i,hhours,toc));    
end

[Stats.DecDOY,Stats.Year] = fr_get_doy(Stats.TimeVector);            % calculate dec.time

return

%=====================================================================================
% Functions
%=====================================================================================

%===============================================================
function  [StatsIn]  = fr_calc_stats(EngUnits,c);

covVector               = c.covVector;
[n,m]                   = size(EngUnits);
m1                      = length(covVector);
StatsIn.AvgMinMax       = zeros(4,m);

StatsIn.AvgMinMax(1,:)  = mean(EngUnits);
StatsIn.AvgMinMax(2,:)  = min(EngUnits);
StatsIn.AvgMinMax(3,:)  = max(EngUnits);
StatsIn.AvgMinMax(4,:)  = std(EngUnits);

covData                 = EngUnits(:,covVector);                % extract data whose covariances need to be calculated
detrendVal              = detrend(covData);                     % linear detrending (only on selected vars.!)
StatsIn.Cov.LinDtr      = cov(detrendVal);
detrendVal              = detrend(covData,0);                   % block-average detrending (only on selected vars.!)
StatsIn.Cov.AvgDtr      = cov(detrendVal);

%===============================================================
function  MiscX = ...
                   additional_calc(c,EngUnits_RMY)
%===============================================================

MiscX       =   zeros(1,4);
[n1,m1]     =   size(EngUnits_RMY);

MiscX(1)    =   mean(sum(EngUnits_RMY(1:2,:).^2)'.^0.5);     % cup wind speed GillR2
MiscX(2)    =   mean(sum(EngUnits_RMY(1:3,:).^2)'.^0.5);     % wind speed 3D vector GillR2
direction   =   fr_Sonic_wind_direction(EngUnits_RMY([1 2],:), ...
   c.sonic) + c.Orientation;
direction   =   rem(direction,360);   
MiscX(3)    =   mean(direction+180)-180;
MiscX(4)    =   std(direction);


%===============================================================
function [StatsRotated, FluxesX,angles] = hhour_calc(c,StatsIn);
%===============================================================

%
% Rotation:----------------------
%
n               = length(c.covVector);

meansS          = StatsIn.AvgMinMax(1,[1:3]);           % get u,v,w bar
statsS          = StatsIn.Cov;                          % extract covariances
if strcmp(c.rotation,'N')
   [meansSr,statsSr,angles] = ...
      fr_rotatn(meansS,statsS);             % perform rotation
else
   [meansSr,statsSr,angles] = ...
      fr_rotatn(meansS,statsS);             % perform rotation
end
StatsRotated.AvgMinMax    = StatsIn.AvgMinMax;
StatsRotated.AvgMinMax(1,[1:3]) = meansSr;              % change only vector mean values
StatsRotated.Cov  = statsSr;                            % and all the covariances

% extract all the flux-calculation variables
%
Tair = StatsIn.AvgMinMax(1,4)+273.15;                   % absolute air temp. (degK) from sonic

uw      = StatsRotated.Cov(1,3);                            % covariance u^w
vw      = StatsRotated.Cov(2,3);                            % covariance v^w   
wT      = StatsRotated.Cov(3,4);                            % covariance w^T (sonic temp)

%
% Sensible heat calculations
%

SensibleSonic  = wT * 101.3 * 1000 / Tair / 8.314 * 1.004;             % Sensible heat (Sonic)

%
% Flux calculation -----------------------------
%

Ustar   = ( uw.^2 + vw.^2 ) ^ 0.25;                         % Ustar

%
% Store fluxes in the output array
%
FluxesX = [ SensibleSonic Ustar ];



