% Prepare input data for slope identification tests (UdeM)


% Created: Feb 5, 2020 (Zoran)
%
% Notes:
%
% testCaseNum - select different traces 1,2 are real data, 
%               3 is a simple linear model
%               4 is based on licor exponential model c(t) = Cx + (Co-Cx)*exp(-a*(t-t0))
%                 (ref. LI-8100 manual)
%                  It has different options for 
%                  the coefficient a:
%                              1 - the smalles dcdt (almost linear)
%                              3 - largest dcdt
% 
%  Data can be "poluted" by noise.  Standard deviation of the noise
%               set by variable: extra_noise_sigma
%  Different polynomials can be used to fit the data to test the robustness
%  of the calculations.  The poly order is selected via: N_poly. 
%  N_poly = 2 is what people use. N_poly = 4 may also provide some insight.
%
%
optionX = 0;
testCaseNum = 4;
true_slope_const = NaN;
switch testCaseNum
    case 1
        slope_length = 60;
        co2fit_c0_const = 405;
        load test_data_1
        % Parameters for exponential fit
        skipPoints = 50;              %
        deadBand = 40;                %
        timePeriodToFit = 100;        % (s) length of exp fit starting from t0
        pointsToTest      = 20;       % (samples) number of samples over which to test t0
    case 2
        slope_length = 60;
        co2fit_c0_const = 380;
        load 'Test_Data_ch3_20190720.mat'
        ch3 = TestData_CH3_20190720;
        % Parameters for exponential fit
        skipPoints = 60;              %
        deadBand = 40;                %
        timePeriodToFit = 120;        % (s) length of exp fit starting from t0
        pointsToTest      = 10;       % (samples) number of samples over which to test t0
        
    case 3
        slope_length = 60;
        co2fit_c0_const = 380;
        ch3 =[(0:199)' [co2fit_c0_const*ones(1,50) co2fit_c0_const+linspace(0,450,150)]'];
        true_slope_const = 450/150;
        % Parameters for exponential fit
        skipPoints = 40;              %
        deadBand = 40;                %
        timePeriodToFit = 100;        % (s) length of exp fit starting from t0
        pointsToTest      = 20;       % (samples) number of samples over which to test t0        
    case 4
        slope_length = 60;
        t = linspace(0,200,200)';
        t0 = t(50);
        Co = 434;
        co2fit_c0_const =Co;
        Cx_options = [1016 1016 1016 1016 563.6];
        a_options=[0.0003 0.001 0.003 0.01 0.0015];
        optionX = 1;
        a = a_options(optionX);
        Cx = Cx_options(optionX);
        co2 = [Co * ones(50,1) ;Cx + (Co - Cx)*exp(-a*(t(51:end)-t0))];
        ch3 = [t co2]; 
        true_slope_const = a*(Cx-Co);
        % Parameters for exponential fit
        skipPoints = 40              %
        deadBand = 40;                %
        timePeriodToFit = 150;        % (s) length of exp fit starting from t0
        pointsToTest      = 20;       % (samples) number of samples over which to test t0
end
% Setup:
N_poly = 2;  % 2,4 is good, 8 too wavy
extra_noise_sigma = 0.6;
rng('default')


% Calcs

numOfPoints = size(ch3,1);
true_slope = true_slope_const*ones(numOfPoints,1);

t_sec = ch3(:,1);
t_sec = t_sec-t_sec(1);
co2 = ch3(:,2)+extra_noise_sigma*randn(numOfPoints,1);

% parameters

numOfSlopes= numOfPoints-slope_length-1;
