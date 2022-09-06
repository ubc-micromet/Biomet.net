function [wc1, wc2, wh1, wh2] = longflux(pth,FN)
%
% longflux.m
%
%   [wc1, wc2, wh1, wh2] = longflux(pth,FN)
%   
%
%   Long tube experiment. Flux comparison
%
%
%
%
% (c) Zoran Nesic 		File created:		Dec  5, 1996
%       				Last Modification:	Dec  5, 1996


%pth = 'h:\zoran\07-31-96\'; 
%FN = '60730182';

N2 = 37400;                                     % common file size

%
% Short tube system:  Solent 2   (*.n2)
%
FileName = [pth FN '.n2'];
[RawData2,header2] = read_met(FileName);
N2 = length(RawData2);
%
% Long tube system:  Solent 1   (*.n1)
%
FileName = [pth FN '.n1'];
[RawData1,header1] = read_met(FileName);
N1 = length(RawData1);
DataLength = min(N1,N2);                    % calculate common file length



EngUnits2 = eng_met1(RawData2(:,1:DataLength),header2);
   %[meansS, covsS,meansS1, covsS1,meansS2, covsS2] =  met_calc(EngUnits2, header2);

nn = 100;
delay2 = header2(5);

L2 = nn + [1:DataLength-nn-delay2];     % find the index
w2 = EngUnits2(3,L2);
c2 = EngUnits2(5,L2+delay2);
h2 = EngUnits2(6,L2+delay2);




RawData1([1:4 7 8],1:DataLength) = RawData2([1:4 7 8],1:DataLength);
header1(5) = 145;                                         % correct time delay
EngUnits1 = eng_met1(RawData1(:,1:DataLength),header1);
   %[meansL, covsL,meansL1, covsL1,meansL2, covsL2] =  met_calc(EngUnits1, header1);
   
delay1 = header1(5);
L1 = nn + [1:DataLength-nn-delay1];     % find the index
w1 = EngUnits1(3,L1);
c1 = EngUnits1(5,L1+delay1);
h1 = EngUnits1(6,L1+delay1);


wc1 = cov(w1,c1);
wc1 = wc1(1,2);
wc2 = cov(w2,c2);
wc2 = wc2(1,2);

wh1 = cov(w1,h1);
wh1 = wh1(1,2);
wh2 = cov(w2,h2);
wh2 = wh2(1,2);
