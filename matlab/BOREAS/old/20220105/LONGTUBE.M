%
% longtube.m
%
%   Long tube experiment. Test file
%
%
%
%
% (c) Zoran Nesic 		File created:		Aug 23, 1996
%       				Last Modification:	Dec  5, 1996

%pth = 'd:\cd-rom\tmp\07-31-96\'; 
pth = 'h:\zoran\07-31-96\'; 
%FN = '60730082';
FN = '60730182';
%
% Short tube system:  Solent 2   (*.n2)
%
FileName = [pth FN '.n2'];
[RawData2,header2] = read_met(FileName);
EngUnits2 = eng_met1(RawData2,header2);
   %[meansS, covsS,meansS1, covsS1,meansS2, covsS2] =  met_calc(EngUnits2, header2);
   

%
% Long tube system:  Solent 1   (*.n1)
%
FileName = [pth FN '.n1']
[RawData1,header1] = read_met(FileName);
RawData1([1:4 7 8],:) = RawData2([1:4 7 8],:);
header1(5) = 145;                                         % correct time delay
EngUnits1 = eng_met1(RawData1,header1);
   %[meansL, covsL,meansL1, covsL1,meansL2, covsL2] =  met_calc(EngUnits1, header1);
   




           %header(5) = 23;                         % correct time delay


%================== CO2 ===========================================
%
% Delay time calculation
%

N1 = 12;                % 2^N is the length of the delay time sample
L = 100 + [1:2^N1];     % find the index
figure(1)
clg
delay(EngUnits1(5,L),EngUnits2(5,L),[-200,200]);


N1 = 14;                % 2^N1 is the length of the FFT sample
L = 100 + [1:2^N1];     % find the index
N2 = 1024*8;            % window length (larger N2 <=> more low freq.)
Fs = 20.83;             % Sampling frequency

%
% Spectra calculation
%
L = 100 + [1:2^N1];     % find the index
[Pxx1,F1]= PSD(EngUnits1(5,L),N2,Fs);
[Pxx2,F2]= PSD(EngUnits2(5,L),N2,Fs);
figure(2)
clg
semilogx(F1,Pxx1/max(Pxx1),'--',F2,Pxx2/max(Pxx2));  % Plot Normalized values
legend('Long','Short')
title(['Long tube experiment: CO2   @' FN])
xlabel('Frequency (Hz)')
ylabel('Normalized power')

%================== H2O ===========================================
%
% Delay time calculation
%

L = 100 + [1:2^N1];     % find the index
figure(3)
clg
delay(EngUnits1(6,L),EngUnits2(6,L),[-200,200]);

%
% Spectra calculation
%
L = 100 + [1:2^N1];     % find the index
[Pxx1,F1]= PSD(EngUnits1(6,L),N2,Fs);
[Pxx2,F2]= PSD(EngUnits2(6,L),N2,Fs);
figure(4)
clg
semilogx(F1,Pxx1/max(Pxx1),'--',F2,Pxx2/max(Pxx2(2:length(Pxx2))));  % Plot Normalized values
legend('Long','Short')
%title('Long tube experiment: H2O')
title(['Long tube experiment: H2O   @' FN])
xlabel('Frequency (Hz)')
ylabel('Normalized power')


%
% Co-spectra calculation CO2
%
[Pxx1,F1]= CSD(EngUnits1(3,L),EngUnits1(5,L),N2,Fs);
Pxx1 = real(Pxx1);
[Pxx2,F2]= CSD(EngUnits2(3,L),EngUnits2(5,L),N2,Fs);
Pxx2 = real(Pxx2);
wc1 = cov(EngUnits1(3,L),EngUnits1(5,L));
wc2 = cov(EngUnits2(3,L),EngUnits2(5,L));

figure(5)
clg
semilogx(F1,Pxx1/max(abs(Pxx1)),'--',F2,Pxx2/max(abs(Pxx2)));  % Plot Normalized values
legend('Long','Short')
title(['Long tube experiment: CO2   @' FN])
xlabel('Frequency (Hz)')
ylabel('Normalized co-spectra power')
ax = axis;
axis([.001 10 ax(3:4)])

%
% Co-spectra calculation H2O
%
[Pxx1,F1]= CSD(EngUnits1(3,L),EngUnits1(6,L),N2,Fs);
Pxx1 = real(Pxx1);
[Pxx2,F2]= CSD(EngUnits2(3,L),EngUnits2(6,L),N2,Fs);
Pxx2 = real(Pxx2);
wh1 = cov(EngUnits1(3,L),EngUnits1(6,L));
wh2 = cov(EngUnits2(3,L),EngUnits2(6,L));
figure(6)
clg
semilogx(F1,Pxx1/max(abs(Pxx1)),'--',F2,Pxx2/max(abs(Pxx2)));  % Plot Normalized values
legend('Long','Short')
title(['Long tube experiment: H2O   @' FN])
xlabel('Frequency (Hz)')
ylabel('Normalized co-spectra power')
ax = axis;
axis([.001 10 ax(3:4)])
