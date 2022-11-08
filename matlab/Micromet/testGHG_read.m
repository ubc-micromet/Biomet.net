clear
%%
pathToHF = fullfile(tempdir,'MatlabTemp');
if ~exist(pathToHF,'dir')
    mkdir(pathToHF);
end
%datein = datetime('2021-11-19T143000','inputformat','yyyy-MM-dd''T''HHmmss');
dateStart = datetime(2021,11,27,0,30,0);
instrumentSN = 'AIU-1696';
for dateIn = dateStart:1/48:dateshift(dateStart,'end','day')
    pathToGHGfile = fullfile('P:\Sites\BB2\HighFrequencyData\2021_Flux\20211220','raw',...
                         datestr(dateIn,'yyyy'),datestr(dateIn,'mm'),...
                         datestr(dateIn,''),...
                         [datestr(dateIn,'yyyy-mm-dd') 'T' datestr(dateIn,'hhMM') '00_' instrumentSN '.ghg']);
    [EngUnits,Header,tv,outputMat] = fr_read_GHG_gile(pathToGHGfile);
    
nPlt = 6;
fig = 1;
    figure(fig);
    clf
    ax(1)=subplot(nPlt,1,1);
    plot(ax(1),outputMat.data.dtv,outputMat.data.CO2_dry);
    ylabel(ax(1),'CO_{2-dry}')
    set(ax(1),'XTickLabel',[]); %remove Xaxis tick labels
    grid(ax(1),'on');
    ax(2)=subplot(nPlt,1,2);
    plot(ax(2),outputMat.data.dtv,outputMat.data.CH4_1);
    ylabel(ax(2),'CH_{4}')
    set(ax(2),'XTickLabel',[]); %remove Xaxis tick labels
    grid(ax(2),'on');
    ax(3)=subplot(nPlt,1,3);
    plot(ax(3),outputMat.data.dtv,outputMat.data.Aux_3_W);
    ylabel(ax(3),'W')
    set(ax(3),'XTickLabel',[]); %remove Xaxis tick labels
    grid(ax(3),'on');
    ax(4)=subplot(nPlt,1,4);
    plot(ax(4),outputMat.data.dtv,outputMat.data.Aux_4_SOS);
    grid(ax(4),'on');
    ylabel(ax(4),'SOS')
    ax(5)=subplot(nPlt,1,5);
    plot(ax(5),outputMat.data.dtv,outputMat.data.H2O_dry);
    ylabel(ax(5),'H_2O')
    grid(ax(5),'on');
    ax(6)=subplot(nPlt,1,6);
    plot(ax(6),outputMat.data.dtv,[outputMat.data.Temperature_In outputMat.data.Temperature_Out]);
    grid(ax(6),'on');
    ylabel(ax(6),'Tlicor');
    legend(ax(6),'T_{in}','T_{out}')
    % stack subplots
    stack_subplots(ax);
% han=axes('visible','off'); 
% han.Title.Visible='on';
% han.XLabel.Visible='on';
% han.YLabel.Visible='on';
% ylabel(han,'yourYLabel');
% xlabel(han,'yourXLabel');
% title(han,'yourTitle');
    linkaxes(ax,'x');
    zoom on;
    
    pause
    if exist(pathToHF,'dir')
        rmdir(pathToHF,'s');
    end
end




