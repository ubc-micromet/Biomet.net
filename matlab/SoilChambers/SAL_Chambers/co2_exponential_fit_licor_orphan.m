function [fitOut,fCO2,gof] = co2_exponential_fit_licor(timeIn,co2_in,optionsIn,useLicorMethod, flagGasType,flagVerbose)
%
%  This function calculates dcdt for soil CO2 data. It is supposed to replicate  
%  LI-COR LI-8100A procedure (manual: year 2015). 
%  In addition to replicating LI-COR's procedure, there is an option to use
%  a modified method (Biomet method). The difference
%  between the Biomet method used here and the LI-COR one given in the manual is in the
%  calculations of t0 and co2_0.  The Biomet method does multiple exponential
%  fits, moving one point in time until it finds the best (lowest) RMSE.
%  The t0 for each iterration is assumed to be the first point of the
%  trace that for that iteration. The co2_0 is the previous 10 points
%  averaged.  If there are no 10 points to average 
%
%  For the given time and co2 signals the program fits an exponential curve
%  through the data and then calculates the dcdt at the initial point t0.  The
%  best fit is calculated repeatedly over a few (pointsToTest) points. All
%  calculated dcdt-s are returned (all pointsToTest of them) and the one
%  with the smallest error of fit is indicated (N_optimum). The full fit
%  model and the associated "goodness of the fit" (gof) for the optimal fit
%  are returned too.
%
%  The input data should be selected after the transitional chamber closure
%  period (bad period/skip points removed). The progam input data starts from the
%  moment just before chamber started closing until it started opening again 
%  (it should contain only one slope!).   
%
%  Input parameters:
%    timeIn             - time vector (Matlab time vector)
%    co2_in             - co2 concentrations (mixing ratios!) in ppm
%
%   optionsIn.
%    deadBand           - # of points to skip before grabing points for
%                         interpolation
%    timePeriodToFit    - the length of the co2 trace to consider (in seconds)
%    pointsToTest       - the range of possible delay times (t0 guesses) over which
%                         the best fit will be calculated
%    skipPoints         - points to skip from the begining of the co2_in
%
%
arg_default('flagGasType','co2');
arg_default('flagVerbose',false);

deadBand        = optionsIn.deadBand;
timePeriodToFit = optionsIn.timePeriodToFit;
pointsToTest    = optionsIn.pointsToTest;
skipPoints      = optionsIn.skipPoints;

% Exponetial fit model (as per LI-COR LI-8100A theory of operation)
co2fitType = fittype('cs+(c0-cs)*exp(A*(t-t0))','problem',{'t0','c0'},'independent','t');
% Exponential fit options (differ by the gas choice)
switch upper(flagGasType)
    case 'CO2'
        co2fitOptions = fitoptions('Method','NonlinearLeastSquares',...
                                'Robust','off',...
                                'StartPoint',[400 -0.01],...
                                'Lower',[-Inf 0],...
                                'Upper',[0 5000],...
                                'TolFun',1e-8,...
                                'TolX',1e-8,...
                                'MaxIter',600,...
                                'DiffMinChange',1e-8,...
                                'DiffMaxChange',0.1,...
                                'MaxFunEvals',600);   %1600
    case 'CH4'
        co2fitOptions = fitoptions('Method','NonlinearLeastSquares',...
                                'Robust','off',...
                                'StartPoint',[2 -0.01],...
                                'Lower',[-Inf 0],...
                                'Upper',[0 5],...
                                'TolFun',1e-8,...
                                'TolX',1e-8,...
                                'MaxIter',600,...
                                'DiffMinChange',1e-8,...
                                'DiffMaxChange',0.1,...
                                'MaxFunEvals',600);   %1600
end

% Skip a predetermined # of points (avoid chamber transition/purging period)
timeIn =timeIn(skipPoints:end,1);
co2_in = co2_in(skipPoints:end,1);

% Convert time to seconds. The first point starts at T = 0s
t =(timeIn - timeIn(1))*24*60*60;    % time starts at 0s

% Calculate the fit for 
dcdt= NaN*zeros(pointsToTest,1);
rmse_exp= NaN*zeros(pointsToTest,1);
t0= NaN*zeros(pointsToTest,1);
c0= NaN*zeros(pointsToTest,1);


%The x,y points to fit (t,co2) stay the same for the entire range of t0
% being tested. They go (in seconds) from deadBand to deadBand+timePeriodToFit.
% Here they are:
ind_curvefit = find(t>=deadBand & t< deadBand+timePeriodToFit);
t_curvefit = t(ind_curvefit);
co2_curvefit = co2_in(ind_curvefit);

if useLicorMethod
    % This is the original Licor method where we grab 10 points starting from the
    % middle of pointToTest (assuming that t(pointsToTest/2) = t0) find C0 
    % by finding the intercept of the line fit through the 10 points and then 
    % do the exponential fit.
    indFirstPoint = round(pointsToTest/2); 
    t0 = t(indFirstPoint);
    p1 = polyfit(t(indFirstPoint+(0:9))-t(indFirstPoint),co2_in(indFirstPoint+(0:9)),1);
    c0 = p1(2);
    %-----------------
    % Fit the function
    %-----------------
    [fCO2{1},gof{1}] = fit(t_curvefit,co2_curvefit,co2fitType,co2fitOptions,'problem',{t0,c0}); %#ok<*AGROW>
    %--------------------
    % Calc dcdt and RMSE
    %--------------------
    dcdt = -fCO2{1}.A*(fCO2{1}.cs-c0);
    rmse_exp = gof{1}.rmse;               %sqrt(gof{i}.sse/length(t_curvefit));
    N_optimum = 1;
    %------------------
    % Print estimates
    %------------------
    if flagVerbose
        fprintf('Licor original: %d  dcdt: %6.4f rmse: %10.4f  r2: %6.4f\n',1,dcdt,gof.rmse,gof.rsquare)
    end
    
else
    % use Biomet modified Licor method where t0 and C0 are found by doing multiple
    % exponential fits and looking for the minimal rmse
    % This method is slow but is seems to work better
    for i=pointsToTest:-1:1

        % --------------------------------------
        % Find t0, c0, and the x,y points to fit
        %---------------------------------------
        t0(i) = t(i);              % a range of t0 is being considered. This is the current one. 

        % Based on the current t0, find c0
        % Note: currently just averaging the preceeding nn points. The assumption is that
        %       the system is controlled using Biomet algorithm when we measure CO2_0 for
        %       30 seconds before we close the chamber.
        % May want to do linefit as Licor does.
        % 
        nn=10;
        if i < nn
            c0(i) = mean(co2_in(1:nn));     % just average the first nn points
    %         p = polyfit(t(1:nn)-t(1),co2_in(1:nn),1);
    %         c0(i) = p(2);
        else
            c0(i) = mean(co2_in(i-nn+1:i));   % just average the previous nn points
    %         p = polyfit(t(i-nn+1:i)-t(i-nn+1),co2_in(i-nn+1:i),1);
    %         c0(i) = p(2);
        end
        p = polyfit(t(i:i+nn-1)-t(i),co2_in(i:i+nn-1),1);
        c0(i) = p(2);
    %figure(4);plot(t(i:i+nn-1)-t(i),co2_in(i:i+nn-1),t(i:i+nn-1)-t(i),polyval(p,t(i:i+nn-1)-t(i)));pause
        %-----------------
        % Fit the function
        %-----------------
        [fCO2{i},gof{i}] = fit(t_curvefit,co2_curvefit,co2fitType,co2fitOptions,'problem',{t0(i),c0(i)}); %#ok<*AGROW>
        %--------------------
        % Calc dcdt and RMSE
        %--------------------
        dcdt(i) = -fCO2{i}.A*(fCO2{i}.cs-c0(i));
        rmse_exp(i) = gof{i}.rmse;               %sqrt(gof{i}.sse/length(t_curvefit));

        %------------------
        % Print estimates
        %------------------
        if flagVerbose
            fprintf('Biomet: %d  dcdt: %6.4f rmse: %10.4f  r2: %6.4f\n',i,dcdt(i),gof{i}.rmse,gof{i}.rsquare)
        end
    end

    % find the optimum fit (min rmse)
    [~, N_optimum] = min(rmse_exp);

end

% create an output structure
fitOut.dcdtAll = dcdt;
fitOut.rmseAll = rmse_exp;
fitOut.c0All = c0;
fitOut.t0All = t0;
fitOut.N_optimum = N_optimum;
fitOut.dcdt = dcdt(N_optimum);
fitOut.rmse = rmse_exp(N_optimum);
fitOut.c0 = c0(N_optimum);
fitOut.t0 = t0(N_optimum);
%
%fprintf('\n ### Do not forget to calculate confidence intervals for dcdt! ###\n\n');
%plot(fCO2{N_optimum},t_curvefit,co2_curvefit)



    