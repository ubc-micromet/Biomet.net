function [Ch, Det, PLL, Sync, AGC] = li7500_val2diag(Diag);

% Program to determine the diagnostic information from the 
% SDM output diagnostic value (a 1 byte unsigned integer)
%
% 1 = ok, 0 = not ok
% AGC = percent value ie. 65%
%
% E. Humphreys Sept 14, 2000

ind = find(Diag <0);
Diag(ind) = 0;

for i = 1:length(Diag);
   agc         = bitget(Diag(i),[4:-1:1]);
   for j = 1:size(agc,2);
      a(j) = num2str(agc(j));
   end
   AGC(i)      = bin2dec(a).*6.25;
   Ch(i)       = bitget(Diag(i),[8]);
   Det(i)      = bitget(Diag(i),[7]);
   PLL(i)      = bitget(Diag(i),[6]);
   Sync(i)     = bitget(Diag(i),[5]);
end