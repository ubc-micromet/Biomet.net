function fig = fileStatus()
% fileStatus: Site file status on \\PAOA001
%   fileStatus() plots the presence or absence of pertinent site files on
%   the \\PAOA001 PC. It looks for:
%
%       (1) zip file for each site in the \\PAOA001\Sites\"SITE"\dailyzip\old\ folder
%       (2) hhour files for each site in the \\PAOA001\Sites\"SITE"\hhour\old\ folder
%       (3) CSI_net files for each site in the \\PAOA001\Sites\"SITE"\CSI_net\old\ folder
%
%   "SITE" is the site acronym as specified on \\PAOA001\ (eg. CR or PAOA)
%
%   The presence/absence of each file (or group of files) is plotted on a
%   sub plot of the main plot. Currently three sub plots will show the
%   results.

sites=['CR   '; 'OY   '; 'YF   '; 'PAOA '; 'PAOB '; 'HJP02'; 'HJP75'; 'PAOJ ']; %current UBC sites
zipOK=zipStatus(sites); %function to search \\PAOA001 for the presence of the site zip files
hhourOK=hhourStatus(sites); %function to search \\PAOA001 for the presence of the site hhour files
CSI_netOK=CSI_netStatus(sites); %function to search \\PAOA001 for the presence of the site CSI_net files

h0=figure(1); %figure handle 

Sites = [0.5 1.5 2.5 3.5 4.5 5.5 6.5 7.5];  % Vector to set the position of the plotting points.
                                            % as the axis has custom text written to it in place.                                      
h0=subplot(3,1,1), plot(Sites,zipOK, 'o');   % subplot showing the zip file status
axis([0 8 0 1.2])                           % x-axis plots 8 sites, y-axis plots 0/1 range
set(gca,'YTickLabel',[  'absent';           % custon tick labels for the y-axis
                        'zip   '; 
                        'in    ']);
set(gca,'XTickLabel',[ '                     '; % custom tick labels for the x-axis. In this case blanks.
                       '                     ';
                       '                     ';
                       '                     ';
                       '                     ';
                       '                     ';
                       '                     ';
                       '                     ';
                       '                     ']) %each label must have same length
h0=subplot(3,1,2), plot(Sites,hhourOK, 'o');         % subplot showing the hhour file status
axis([0 8 0 1.2])                                   % x-axis plots 8 sites, y-axis plots 0/1 range
set(gca,'YTickLabel',[  'absent';                   % custon tick labels for the y-axis
                        'hhour '; 
                        'in    ']);
set(gca,'XTickLabel',[ '                     '; % custom tick labels for the x-axis. In this case blanks.     
                       '                     ';
                       '                     ';
                       '                     ';
                       '                     ';
                       '                     ';
                       '                     ';
                       '                     ';
                       '                     ']) %each label must have same length
h0=subplot(3,1,3), plot(Sites,CSI_netOK, 'o');       % subplot showing the CSI_net file status
axis([0 8 0 1.2])                                   % x-axis plots 8 sites, y-axis plots 0/1 range
set(gca,'YTickLabel',[  'absent ';                  % custon tick labels for the y-axis
                        'CSI_net';                 
                        'in     ']);                
set(gca,'XTickLabel',[ '                     '; % custom tick labels for the x-axis. In this case site acronyms.
                       'CR                   ';
                       'OY                   ';
                       'YF                   ';
                       'PAOA                 ';
                       'PAOB                 ';
                       'HJP02                ';
                       'HJP75                ';
                       'PAOJ                 ']) %each label must have same length

if nargout > 0, fig = h0; end