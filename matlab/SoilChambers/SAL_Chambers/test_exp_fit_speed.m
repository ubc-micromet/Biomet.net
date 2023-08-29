%% Speed testing of the original UdeM_exponetial_fit function vs lsqcurvefit

% first run 
% >> setup_UdeM_calc
% Put a break point in UdeM_exponential_fit at the line 
% (around line 113, after: "if useLicorMethod" ):
%     [fCO2{1},gof{1}] = fit(t_curvefit,co2_curvefit,co2fitType,co2fitOptions,'problem',{t0,c0}); %#ok<*AGROW>
%
% Then run this
% >> dataStruct = UdeM_ACS_calc_one_day(datenum(2019,8,1),'UdeM',0,1,1,1)
% When the program stops at the break point
% execute this program:
%   test_exp_fit_speed;


%% Test the speed of N regular speed fit() lines
N=10;

co2fitOptions = fitoptions('Method','NonlinearLeastSquares',...
                        'Robust','off',...
                        'StartPoint',[-0.01 400 ],...
                        'Lower',[-Inf 0],...
                        'Upper',[0 5000],...
                        'TolFun',1e-8,...
                        'TolX',1e-8,...
                        'MaxIter',600,...
                        'DiffMinChange',1e-8,...
                        'DiffMaxChange',0.1,...
                        'MaxFunEvals',600);   %1600
tic;
    for cntN = 1:N
        [fCO2{1},gof{1}] = fit(t_curvefit,co2_curvefit,co2fitType,co2fitOptions,'problem',{t0,c0});
    end
timeSlow = toc/N;

%% Test the speed of N lsqcurvefit-s
gasC = co2_curvefit;
%'cs+(c0-cs)*exp(A*(t-t0))'
fun_str = sprintf('fun=@(x,t)(x(1)+(%d-x(1))*exp(x(2)*(t-%d)));',c0,t0);
eval(fun_str);
lb = [300 -Inf];
ub = [5000 0];
x0 = [400 -0.1];
% FunctionTolerance of 0.01 seems to be 50% faster than 0.001
opt = optimoptions('lsqcurvefit','MaxFunctionEvaluations',1000,...
                                'FunctionTolerance',0.01,...
                                'Display','off');
tic;
    for cntN = 1:N
        [x,resnorm,residual,exitflag,output] = lsqcurvefit(fun,x0,t_curvefit,co2_curvefit,lb,ub,opt);
    end
timeFast = toc/N;
    
A = x(2);
cs = x(1);

dcdt1 = -fCO2{1}.A*(fCO2{1}.cs-c0);
dcdt2 = -A*(cs-c0);
tType = {'Slow';'Fast'};
tDCDT = [dcdt1; dcdt2];
tSpeed = [timeSlow; timeFast];
T=table(tType,tDCDT,tSpeed);
disp(T)
%fprintf('\n\ndcdt:   Slow = %8.5f (in %5.1f s), Fast = %8.5f (in %5.1f s)\n',dcdt1,timeSlow,dcdt2,timeFast);

%% Plot and compare results
figure(1)
clf
subplot(2,1,1)
plot(t_curvefit,co2_curvefit,'o',t_curvefit,fun(x,t_curvefit),t_curvefit,fun([fCO2{1}.cs fCO2{1}.A],t_curvefit))
legend('True','Slow','Fast')
subplot(2,1,2)
plot(t_curvefit,co2_curvefit- fun(x,t_curvefit),t_curvefit,co2_curvefit-fun([fCO2{1}.cs fCO2{1}.A],t_curvefit))
legend('true-slowFit','true-fastFit')
