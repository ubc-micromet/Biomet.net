x = fr_read_digital2_file('D:\kai\Projects\XSITE\05041492.DX8');

figure('Name','Licor pressure during muffler test');
plot(x(:,5));

figure('Name','Power spectra with and without muffler');
% Extract data with muffler in the line
psd(detrend(x(1.76e4:3.52e4+2^10-1,1)),2^10,20.345,'hamming',0)
hold on
% Extract data without muffler
psd(detrend(x(2.8e4:2.8e4+2^11-1,5)),2^11,20,'hamming',0)

h = get(gca,'Children');
set(h(1),'Color','r')
legend('with muffler','1/2'' line only')