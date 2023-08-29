function [fitOut,fCO2,gof] = UdeM_polynomial_fit(timeIn,co2_in,optionsIn,useOnePointMethod,polyType,flagVerbose)
%
%  This function calculates dcdt for soil CO2 data using iterative linear fit method
%  (Biomet method, lin_B). 
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
%    deadBand           - not used
%    timePeriodToFit    - the length of the co2 trace to consider (in seconds)
%    pointsToTest       - the range of possible delay times (t0 guesses) over which
%                         the best fit will be calculated
%    skipPoints         - points to skip from the begining of the co2_in
%
%

%arg_default('flagGasType','co2');
arg_default('flagVerbose',false);

% deadBand        = optionsIn.deadBand;
timePeriodToFit = optionsIn.timePeriodToFit;
pointsToTest    = optionsIn.pointsToTest;
skipPoints      = optionsIn.skipPoints;

% Calculate the fit for 
dcdt= NaN*zeros(pointsToTest,1);
rmse_exp= NaN*zeros(pointsToTest,1);
t0= NaN*zeros(pointsToTest,1);
c0= NaN*zeros(pointsToTest,1);
N_optimum = 1;

try
    % Polynomial fit options (same forboth gas choice)
    co2fitOptions = fitoptions('Method','LinearLeastSquares');   %1600

    % Skip a predetermined # of points (avoid chamber transition/purging period)
    timeIn =timeIn(skipPoints:end,1);
    co2_in = co2_in(skipPoints:end,1);

    % Convert time to seconds. The first point starts at T = 0s
    t =(timeIn - timeIn(1))*24*60*60;    % time starts at 0s

    if useOnePointMethod
        % Assume that the t0 point is = t(pointsToTest/2)
        indFirstPoint = round(pointsToTest/2); 
        t0 = t(indFirstPoint);
        ind_curvefit = find(t>=t0 & t < t0+timePeriodToFit); 
        t_curvefit = t(ind_curvefit);
        co2_curvefit = co2_in(ind_curvefit);
        %-----------------
        % Fit the function
        %-----------------
        [fCO2{1},gof{1}] = fit(t_curvefit,co2_curvefit,polyType,co2fitOptions); %#ok<*AGROW>
        %--------------------
        % Calc dcdt and RMSE
        %--------------------
        dcdt = fCO2{1}.A;
        rmse_exp = gof{1}.rmse;               %sqrt(gof{i}.sse/length(t_curvefit));
        N_optimum = 1;
        %------------------
        % Print estimates
        %------------------
        if flagVerbose
            fprintf('Licor original: %d  dcdt: %6.4f rmse: %10.4f  r2: %6.4f\n',1,dcdt,gof.rmse,gof.rsquare)
        end

    else
        % do a number of iterations looking for the best start point (lowest rmse)
        for i=pointsToTest:-1:1
            ind_curvefit = find(t>=t(i) & t < t(i)+timePeriodToFit); 
            t_curvefit = t(ind_curvefit);
%            t_curvefit = t_curvefit;% - t_curvefit(1);  % set the start time always to 0s for the fitting purpose
            co2_curvefit = co2_in(ind_curvefit);
            % --------------------------------------s
            % Find t0, c0, and the x,y points to fit
            %---------------------------------------
            t0(i) = t(i);              % a range of t0 is being considered. This is the current one. 

            %-----------------
            % Fit the function
            %-----------------
        %[fCO2{i},gof{i}] = fit(t_curvefit-t_curvefit(1),co2_curvefit,polyType,co2fitOptions); %#ok<*AGROW>
            [fCO2{i},gof{i}] = fit(t_curvefit,co2_curvefit,polyType,co2fitOptions); %#ok<*AGROW>        
            %--------------------
            % Calc dcdt and RMSE
            %--------------------
            dcdt(i) = fCO2{i}.p1;
            c0(i) = fCO2{i}.p2 + dcdt(i)*t0(i);      %  c0 needs to be normalized to t0 location to match other fits
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
catch
    if flagVerbose
        fprintf('*** Error in UdeM_polynomial_fit.m\n');
    end
    fCO2 = struct([]);
    gof = struct([]);
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



    