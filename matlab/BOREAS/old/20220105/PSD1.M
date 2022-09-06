
%============================================================
%
%
%   Ploting of (f, f.* Sx) loglog, semilogx
%
%   This function does preprocessing of the long data arrays so
%   the psd can be used without any problems. It chops the input
%   arrays into small chunks so the memory problems can be avoided.
%
%
clear
loglogFlag = -1;            % -1 - loglog, 0 - semilogx
TraceNum = 3;
TraceTime = 'Jul 21, 1994, 17:30 - 19:30';
xx = '03';
TraceNames = 'uvwtchrpg';
TraceUnits = [  '[m/s]^2     '
                '[m/s]^2     '
                '[m/s]^2     '
                '[degC]^2    '
                '[ppm]^2     '
                '[mmol/mol]^2'
                '[g/m^3]^2   '
                '[kPa]^2     '
                '[kPa]^2     ' ];
FullNames = [   'f * Su   '
                'f * Sv   '
                'f * Sw   '
                'f * St   '
                'f * Sco2 '
                'f * Sh2o '
                'f * Srho '
                'f * Sp   '
                'f * Sg   ' ];
TraceDelays = [ 0 0 0 0 19 19 0 0 0];
y = loadzip(['sum' TraceNames(TraceNum) xx]);
y = y( 1 + TraceDelays(TraceNum) : 2^17 + TraceDelays(TraceNum) );
pack
Fs = 20.83;
nfft = 2^14;
noverlap = 0;
maxLen = 2^14                           % max size of an chunk
NcMax = fix(maxLen/nfft);               % max. possible number of chunks
N = min(NcMax,fix(length(y)/nfft))      % number of chinks per csd call
DataLen =  N * nfft ;                   % length of data transfered to csd per call
index=1:DataLen;
k = fix(length(y)/DataLen)              % number of csd calls

Psum = 0;                   % init the result vector
for i = 1:k
    i    
    [P, F] = psd(y(index), nfft, Fs,noverlap,'linear');
    Psum = Psum + P;
    index = index + DataLen;
end
Px = Psum / k;
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
ind=finite(Pxd);
Pxd = Pxd(ind);
Flog = Flog(ind);

% plot real data and the averaged data
figure(1);
if loglogFlag == 0
    semilogx(Flog,Flog.*real(Pxd),Flog,Flog.*real(Pxd),'o')
else
    loglog(Flog,Flog.*abs(real(Pxd)),Flog,Flog.*abs(real(Pxd)),'o')    
end

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

figure(1);title([t]) % ' (N = ' num2str(Nlog) ' intervals)'])
a=axis;
axis([.001 100 a(3:4)])
xlabel('Frequency [Hz]')
ylabel([FullNames(TraceNum,:) ' ' TraceUnits(TraceNum,:)])
set(get(get(gcf,'children'),'title'),'FontSize',20)
set(get(gcf,'CurrentAxes'),'FontSize',20) 
set(get(get(gcf,'children'),'xlabel'),'FontSize',20)
set(get(get(gcf,'children'),'ylabel'),'FontSize',20)
if loglogFlag == -1
    pow = 10^(log10(abs(max(Pxd)))-3);
    %line([.01  10], [0.01 0.01 * 10^(-2/3*3)])
    line([.01  10], [pow pow * 10^(-2/3*3)])
    % text(.1, .3*10^(-2/3*3),'-2/3')
    text(.1, 400*pow*10^(-1*3),'-2/3')
end    

