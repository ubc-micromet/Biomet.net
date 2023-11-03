function [fitOut,fCO2,gof] = UdeM_polynomial_fit_fast(timeIn,c_in,optionsIn,polyType,flagVerbose)
%
%  This function calculates dcdt for soil CO2 data using iterative quadratic fit method
%  (Biomet method, quad_B). 
%
%  For the given time and gas concentration the program fits a quadratic curve
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
%    timePeriodToFit    - the length of the gas trace to consider (in seconds)
%    pointsToTest       - the range of possible delay times (t0 guesses) over which
%                         the best fit will be calculated
%    skipPoints         - points to skip from the begining of the c_in
%
%

%arg_default('flagGasType','co2');
arg_default('flagVerbose',false);

% deadBand        = optionsIn.deadBand;
timePeriodToFit = optionsIn.timePeriodToFit;
pointsToTest    = optionsIn.pointsToTest;
skipPoints      = optionsIn.skipPoints;

% Calculate the fit for 
coeffAll = NaN*zeros(pointsToTest,3);
dcdt= NaN*zeros(pointsToTest,1);
rmse_exp= NaN*zeros(pointsToTest,1);
t0= NaN*zeros(pointsToTest,1);
c0= NaN*zeros(pointsToTest,1);
a = NaN*zeros(pointsToTest,1);
N_optimum = 1;

try

    % Skip a predetermined # of points (avoid chamber transition/purging period)
    timeIn =timeIn(skipPoints:end,1);
    c_in = c_in(skipPoints:end,1);

    % Convert time to seconds. The first point starts at T = 0s
    t =(timeIn - timeIn(1))*24*60*60;    % time starts at 0s


    for i=pointsToTest:-1:1
        ind_curvefit = find(t>=t(i) & t < t(i)+timePeriodToFit); 
        t_curvefit = t(ind_curvefit);
        c_curvefit = c_in(ind_curvefit);
        % --------------------------------------
        % Find t0, c0, and the x,y points to fit
        %---------------------------------------
        t0(i) = t(i);              % a range of t0 is being considered. This is the current one. 

        %-----------------
        % Fit the function
        %-----------------
        [polynomialCoefficients,S] = polyfit(t_curvefit,c_curvefit,polyType);
        %--------------------
        % Calc dcdt and RMSE
        %--------------------
        switch polyType
            case 1
                dcdt(i) = polynomialCoefficients(1);
                c0(i) = polynomialCoefficients(1)*t0(i) + polynomialCoefficients(2);                                      %  c0 needs to be normalized to t0 location to match other fits
                rmse_exp(i) = rmse(c_curvefit,polyfit(polynomialCoefficients,t_curvefit));          %sqrt(gof{i}.sse/length(t_curvefit));                
            case 2
                % 
                dcdt(i) = 2*polynomialCoefficients(1)*t0(i)+polynomialCoefficients(2);                                    % slope of the tangent at t0 for quadratic eq is: 2*a*t0+b 
                c0(i)   = polyval(polynomialCoefficients,t0(i));                                     %  c0 needs to be normalized to t0 location to match other fits
                rmse_exp(i) = rmse(c_curvefit,polyval(polynomialCoefficients,t_curvefit));           %sqrt(gof{i}.sse/length(t_curvefit));
                a(i) = polynomialCoefficients(1);                                                    % highest order poly coeff (needed below)
                coeffAll(i,:)=polynomialCoefficients;
% figure(22)
% plot(t_curvefit,c_curvefit,t_curvefit,polyval(p,t_curvefit))
% pause
            otherwise
                error('Wrong polynomial type: %d. Valid values: 1 and 2.\n',polyType)
        end

        %------------------
        % Print estimates
        %------------------
        if flagVerbose
            fprintf('Biomet: %d  dcdt: %6.4f rmse: %10.4f\n',i,dcdt(i),rmse_exp(i))
        end
    end

    % find the optimum fit (min rmse)
    switch polyType
        case 1
            [~, N_optimum] = min(rmse_exp);
        case 2
            tmp = rmse_exp;
            tmp(a>=1e-5) = 1e38;
%             indTmp = find(tmp
%             N_optimum = find(tmp
            [~,N_optimum] = min(tmp);                          % find the minimum rmse for the "open-bottom" parabolas (p1<=0) only
    end
catch
    if flagVerbose
        fprintf('*** Error in UdeM_polynomial_fit_fast.m\n');
    end
end

% figure(22)
% ind_curvefit = find(t>=t0(N_optimum) & t < t0(N_optimum)+timePeriodToFit);
% t_curvefit = t;%(ind_curvefit);
% c_curvefit = c_in;%(ind_curvefit);
% plot(t_curvefit,c_curvefit,t_curvefit,polyval(p,t_curvefit-t0(N_optimum)),[1 1] * t0(N_optimum),[min(c_curvefit) max(c_curvefit)])
% pause

% keep these for compability reasons only 
fCO2 = struct([]);
gof = struct([]);

% create an output structure
fitOut.coeffAll = coeffAll;
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



    