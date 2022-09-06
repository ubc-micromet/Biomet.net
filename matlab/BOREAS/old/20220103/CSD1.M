%function [ Px, Fx] = csd1(x, y, nfft, Fs,noverlap)
%============================================================
%
%
%
%   function [ Px,Pxyc,F] = csd1(x, y, nfft, Fs,noverlap)
%
%
%   This function does preprocessing of the long data arrays so
%   the csd can be used without any problems. It chopes the input
%   arrays into small chunks so the memory problems can be avoided.
%
%   LOAD w INTO x BEFORE START  (AND AJUST ITS SIZE TO BE EQUAL ArrayLength)!!!!
%
ArrayLength = 2^17;
loglogFlag = 0;                                    % -1 - loglog, 0 - semilogx
detrendType = 'linear';
TraceNum = 5;
TraceTime = 'Jun 7, 1994, 18:30 - 20:30';
xx = '_z2';
TraceNames = 'uvwtchrpg';
TraceUnits = [  '(m/s)^2         '
                '(m/s)^2         '
                '(m/s)^2         '
                '(m/s)*degC      '
                '(m/s)*ppm       '
                '(m/s)*mmol/mol  '
                'g/sec/m^2       '
                '(m/s)*kPa       '
                '(m/s)*kPa       ' ];
FullNames = [   'f * W^U    '
                'f * W^V    '
                'f * W^W    '
                'f * W^T    '
                'f * W^CO2  '
                'f * W^H2O  '
                'f * W^Rho  '
                'f * W^Pb   '
                'f * W^Pg   ' ];
TraceDelays = [ 0 0 0 0 19 19 0 0 0];
y = loadzip(['sum' TraceNames(TraceNum) xx]);
y = y( 1 + TraceDelays(TraceNum) : ArrayLength + TraceDelays(TraceNum) );
pack
Fs = 20.83;
nfft = 2^14;
noverlap = 0;
maxLen = nfft                           % max size of an chunk
NcMax = fix(maxLen/nfft);               % max. possible number of chunks
N = min(NcMax,fix(ArrayLength/nfft))      % number of chinks per csd call
DataLen =  N * nfft ;                   % length of data transfered to csd per call
index=1:DataLen;
k = fix(ArrayLength/DataLen)              % number of csd calls

Psum = 0;                   % init the result vector
for i = 1:k
    i    
    [P, F] = csd(x(index), y(index), nfft, Fs,noverlap, detrendType);
    Psum = Psum + P;
    index = index + DataLen;
end
Px = Psum / k;              % do the average
Px = Px * 2 / Fs;           % Correct the units     (Zoran, Aug 25, 1995)
Fx = F;
clear Psum F
pack

% average to plot
Nlog = 50;              % number of intervals to average
Flog=logspace(log10(min(Fx(2:length(Fx)))),log10(max(Fx)),Nlog);

% do the averaging
Pxd = [];
Pxd(1)=Px(1);for i=1:Nlog-1;ind=find( Fx >= Flog(i) & Fx < Flog(i+1) );Pxd(i+1) = mean(Px(ind));end
% remove NaN's
ind=find(isnan(Pxd));

% plot real data and the averaged data
figure(1);
if loglogFlag == 0
    semilogx(Flog,Flog.*real(Pxd),Flog,Flog.*real(Pxd),'o')
else
    loglog(Flog,Flog.*abs(real(Pxd)),Flog,Flog.*abs(real(Pxd)),'o')    
end
index = 1;
for i=1:length(ind)-1
    if ( ind(i+1) - ind(i) ) > 1
        index = [index (ind(i) + 1) ];
    end
end
index = [index (max(ind)+1)];
line(Flog(index),Flog(index).*real(Pxd(index)))
line([.001 100],[0 0]) 

figure(2);semilogx(Fx, Fx.*real(Px))
line([.001 100],[0 0])

t = TraceTime;                  

figure(2);title([t])
a=axis;
axis([.001 100 a(3:4)])
xlabel('Frequency [Hz]')
ylabel([FullNames(TraceNum,:) ' ' TraceUnits(TraceNum,:)])
set(get(get(gcf,'children'),'title'),'FontSize',20)
set(get(gcf,'CurrentAxes'),'FontSize',20)
set(get(get(gcf,'children'),'xlabel'),'FontSize',20)
set(get(get(gcf,'children'),'ylabel'),'FontSize',20)

figure(1);title([t ' (N = ' num2str(Nlog) ' intervals)'])
a=axis;
axis([.001 100 a(3:4)])
xlabel('Frequency [Hz]')
ylabel([FullNames(TraceNum,:) ' ' TraceUnits(TraceNum,:)])
set(get(get(gcf,'children'),'title'),'FontSize',20)
set(get(gcf,'CurrentAxes'),'FontSize',20) 
set(get(get(gcf,'children'),'xlabel'),'FontSize',20)
set(get(get(gcf,'children'),'ylabel'),'FontSize',20)
if loglogFlag == -1
    %line([.01  10], [0.01 0.01 * 10^(-2/3*3)])
    line([.01  10], [0.01 0.01 * 10^(-4/3*3)])
    % text(.1, .3*10^(-2/3*3),'-2/3')
    text(.13, .4*10^(-1*3),'-4/3')
end    

