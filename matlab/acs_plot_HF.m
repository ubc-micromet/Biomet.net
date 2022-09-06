function acs_plot_HF(metdataPath, iniFilePath)

% find data path
folderIn = fullfile(metdataPath,'data');

% change folder to where the data is
oldPath = pwd;
cd(folderIn);


% Load ini file to get channel names and units only
% (the systemNumber and date do not matter)
configIn  = acs_read_init_all(iniFilePath, now, 1, metdataPath);

% Load high frequency data file 
[filename, pathname] = uigetfile( ...
       {'*.d*','ACS files (*.d*)'; ...
        '*.*',  'All Files (*.*)'}, ...
        'Pick a file');
fileNameOld = filename;

posScr = get(0,'screensize');
set(0,'defaultfigureposition',[8 posScr(4)/2-80 posScr(3)-20 posScr(4)/2-5], ...
      'defaultaxesfontsize',10, ...
      'defaulttextfontsize',10)

%while filename ~= 0 
    close all
    [EngUnits,Header] = fr_read_Digital2_file(fullfile(pathname,filename));
    timerX = EngUnits(:,6);
    if timerX(end)< timerX(end-1)
        timerX(end) = timerX(end-1)+1;
    end
    fileNameOld = filename;
    for countChan = Header.NumOfChans:-1:1
        chanName  = char(configIn.chanNames(countChan));
        chanUnits = char(configIn.chanUnits(countChan));        
        figure (countChan)
        set(countChan,'NumberTitle','off','Name',chanName)        
        clf
        plot(timerX,EngUnits(:,countChan))
        xlabel('Seconds')
        if isempty(chanUnits)
            ylabel(chanName)
        else
            ylabel([ chanName ' (' chanUnits ')'])
        end
        xxd = ['20' filename(1:6)];
        xxd = datenum(str2num(xxd(1:4)),str2num(xxd(5:6)),str2num(xxd(7:8)));
        xxt = str2double(filename(7:8))/4;
        if xxt == 24
            xxt = xxt-0.0001;
        end
        xxt=datenum(0,0,0,xxt,0,0);
        title(sprintf('Half hour ending at: %s (File: %s).',[datestr(xxd) ' ' datestr(xxt,'HH:MM:SS')],filename));
        zoom on
    end


%close all
cd (oldPath)
    
end % of function    
    
    
    
    
function ButtonName = cycleFigures(Question,Title,Btn1,Btn2,Btn3,Default,FigPos)
%cycleFigures dialog box.


if nargin<1
    error('MATLAB:questdlg:TooFewArguments', 'Too few arguments for QUESTDLG');
end

Interpreter='none';
if ~iscell(Question),Question=cellstr(Question);end

%%%%%%%%%%%%%%%%%%%%%
%%% General Info. %%%
%%%%%%%%%%%%%%%%%%%%%
Black      =[0       0        0      ]/255;
% LightGray  =[192     192      192    ]/255;
% LightGray2 =[160     160      164    ]/255;
% MediumGray =[128     128      128    ]/255;
% White      =[255     255      255    ]/255;

%%%%%%%%%%%%%%%%%%%%
%%% Nargin Check %%%
%%%%%%%%%%%%%%%%%%%%
if nargout>1
    error('MATLAB:questdlg:WrongNumberOutputs', 'Wrong number of output arguments for QUESTDLG');
end
if nargin==1,Title=' ';end
if nargin<=2, Default='Yes';end
if nargin==3, Default=Btn1 ;end
if nargin<=3, Btn1='Yes'; Btn2='No'; Btn3='Cancel';NumButtons=3;end
if nargin==4, Default=Btn2;Btn2=[];Btn3=[];NumButtons=1;end
if nargin==5, Default=Btn3;Btn3=[];NumButtons=2;end
if nargin>6, NumButtons=3;end
if nargin>7
    error('MATLAB:questdlg:TooManyInputs', 'Too many input arguments');NumButtons=3; %#ok
end

if isstruct(Default),
    Interpreter=Default.Interpreter;
    Default=Default.Default;
end


%%%%%%%%%%%%%%%%%%%%%%%
%%% Create QuestFig %%%
%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('FigPos','var') || isempty(FigPos)
    FigPos    = get(0,'DefaultFigurePosition');
    FigPos(3) = 267;
    FigPos(4) =  70;
    FigPos    = getnicedialoglocation(FigPos, get(0,'DefaultFigureUnits'));
end

QuestFig=dialog(                                    ...
    'Visible'         ,'off'                      , ...
    'Name'            ,Title                      , ...
    'Pointer'         ,'arrow'                    , ...
    'Position'        ,FigPos                     , ...
    'KeyPressFcn'     ,@doFigureKeyPress          , ...
    'IntegerHandle'   ,'off'                      , ...
    'WindowStyle'     ,'normal'                   , ...
    'HandleVisibility','callback'                 , ...
    'CloseRequestFcn' ,@doDelete                  , ...
    'Tag'             ,Title                        ...
    );

%%%%%%%%%%%%%%%%%%%%%
%%% Set Positions %%%
%%%%%%%%%%%%%%%%%%%%%
DefOffset  =10;

IconWidth  =54;
IconHeight =54;
IconXOffset=DefOffset;
IconYOffset=FigPos(4)-DefOffset-IconHeight;  %#ok
IconCMap=[Black;get(QuestFig,'Color')];  %#ok

DefBtnWidth =56;
BtnHeight   =22;

BtnYOffset=DefOffset;

BtnWidth=DefBtnWidth;

ExtControl=uicontrol(QuestFig   , ...
    'Style'    ,'pushbutton', ...
    'String'   ,' '          ...
    );

btnMargin=1.4;
set(ExtControl,'String',Btn1);
BtnExtent=get(ExtControl,'Extent');
BtnWidth=max(BtnWidth,BtnExtent(3)+8);
if NumButtons > 1
    set(ExtControl,'String',Btn2);
    BtnExtent=get(ExtControl,'Extent');
    BtnWidth=max(BtnWidth,BtnExtent(3)+8);
    if NumButtons > 2
        set(ExtControl,'String',Btn3);
        BtnExtent=get(ExtControl,'Extent');
        BtnWidth=max(BtnWidth,BtnExtent(3)*btnMargin);
    end
end
BtnHeight = max(BtnHeight,BtnExtent(4)*btnMargin);

delete(ExtControl);

MsgTxtXOffset=IconXOffset+IconWidth;

FigPos(3)=max(FigPos(3),MsgTxtXOffset+NumButtons*(BtnWidth+2*DefOffset));
set(QuestFig,'Position',FigPos);

BtnXOffset=zeros(NumButtons,1);

if NumButtons==1,
    BtnXOffset=(FigPos(3)-BtnWidth)/2;
elseif NumButtons==2,
    BtnXOffset=[MsgTxtXOffset
        FigPos(3)-DefOffset-BtnWidth];
elseif NumButtons==3,
    BtnXOffset=[MsgTxtXOffset
        0
        FigPos(3)-DefOffset-BtnWidth];
    BtnXOffset(2)=(BtnXOffset(1)+BtnXOffset(3))/2;
end

MsgTxtYOffset=DefOffset+BtnYOffset+BtnHeight;
MsgTxtWidth=FigPos(3)-DefOffset-MsgTxtXOffset-IconWidth;
MsgTxtHeight=FigPos(4)-DefOffset-MsgTxtYOffset;
MsgTxtForeClr=Black;
MsgTxtBackClr=get(QuestFig,'Color');

CBString='uiresume(gcbf)';
DefaultValid = false;
DefaultWasPressed = false;
BtnHandle = [];
DefaultButton = 0;

% Check to see if the Default string passed does match one of the
% strings on the buttons in the dialog. If not, throw a warning.
for i = 1:NumButtons
    switch i
        case 1
            ButtonString=Btn1;
            ButtonTag='Btn1';
            if strcmp(ButtonString, Default)
                DefaultValid = true;
                DefaultButton = 1;
            end

        case 2
            ButtonString=Btn2;
            ButtonTag='Btn2';
            if strcmp(ButtonString, Default)
                DefaultValid = true;
                DefaultButton = 2;
            end
        case 3
            ButtonString=Btn3;
            ButtonTag='Btn3';
            if strcmp(ButtonString, Default)
                DefaultValid = true;
                DefaultButton = 3;
            end
    end

    BtnHandle(end+1)=uicontrol(QuestFig            , ...
        'Style'              ,'pushbutton', ...
        'Position'           ,[ BtnXOffset(1) BtnYOffset BtnWidth BtnHeight ]           , ...
        'KeyPressFcn'        ,@doControlKeyPress , ...
        'CallBack'           ,CBString    , ...
        'String'             ,ButtonString, ...
        'HorizontalAlignment','center'    , ...
        'Tag'                ,ButtonTag     ...
        );
end

if ~DefaultValid
    warnstate = warning('backtrace','off');
    warning('MATLAB:QUESTDLG:stringMismatch','Default string does not match any button string name.');
    warning(warnstate);
end

MsgHandle=uicontrol(QuestFig            , ...
    'Style'              ,'text'         , ...
    'Position'           ,[MsgTxtXOffset MsgTxtYOffset 0.95*MsgTxtWidth MsgTxtHeight ]              , ...
    'String'             ,{' '}          , ...
    'Tag'                ,'Question'     , ...
    'HorizontalAlignment','left'         , ...
    'FontWeight'         ,'bold'         , ...
    'BackgroundColor'    ,MsgTxtBackClr  , ...
    'ForegroundColor'    ,MsgTxtForeClr    ...
    );

[WrapString,NewMsgTxtPos]=textwrap(MsgHandle,Question,75);

% NumLines=size(WrapString,1);

% The +2 is to add some slop for the border of the control.
MsgTxtWidth=max(MsgTxtWidth,NewMsgTxtPos(3)+2);
MsgTxtHeight=NewMsgTxtPos(4)+2;

MsgTxtXOffset=IconXOffset+IconWidth+DefOffset;
FigPos(3)=max(NumButtons*(BtnWidth+DefOffset)+DefOffset, ...
    MsgTxtXOffset+MsgTxtWidth+DefOffset);


% Center Vertically around icon
if IconHeight>MsgTxtHeight,
    IconYOffset=BtnYOffset+BtnHeight+DefOffset;
    MsgTxtYOffset=IconYOffset+(IconHeight-MsgTxtHeight)/2;
    FigPos(4)=IconYOffset+IconHeight+DefOffset;
    % center around text
else
    MsgTxtYOffset=BtnYOffset+BtnHeight+DefOffset;
    IconYOffset=MsgTxtYOffset+(MsgTxtHeight-IconHeight)/2;
    FigPos(4)=MsgTxtYOffset+MsgTxtHeight+DefOffset;
end

if NumButtons==1,
    BtnXOffset=(FigPos(3)-BtnWidth)/2;
elseif NumButtons==2,
    BtnXOffset=[(FigPos(3)-DefOffset)/2-BtnWidth
        (FigPos(3)+DefOffset)/2
        ];

elseif NumButtons==3,
    BtnXOffset(2)=(FigPos(3)-BtnWidth)/2;
    BtnXOffset=[BtnXOffset(2)-DefOffset-BtnWidth
        BtnXOffset(2)
        BtnXOffset(2)+BtnWidth+DefOffset
        ];
end

%set(QuestFig ,'Position',getnicedialoglocation(FigPos, get(QuestFig,'Units')));

BtnPos=get(BtnHandle,{'Position'});
BtnPos=cat(1,BtnPos{:});
BtnPos(:,1)=BtnXOffset;
BtnPos=num2cell(BtnPos,2);
set(BtnHandle,{'Position'},BtnPos);

%if DefaultValid
%    setdefaultbutton(QuestFig, BtnHandle(DefaultButton));
%end

delete(MsgHandle);

AxesHandle=axes('Parent',QuestFig,'Position',[0 0 1 1],'Visible','off');

MsgHandle=text( ...  
    'Parent'              ,AxesHandle                      , ...
    'Units'               ,'pixels'                        , ...
    'Color'               ,get(BtnHandle(1),'ForegroundColor')   , ...
    'HorizontalAlignment' ,'left'                          , ...
    'FontName'            ,get(BtnHandle(1),'FontName')    , ...
    'FontSize'            ,get(BtnHandle(1),'FontSize')    , ...
    'VerticalAlignment'   ,'bottom'                        , ...
    'Position'            ,[MsgTxtXOffset MsgTxtYOffset 0] , ...
    'String'              ,WrapString                      , ...
    'Interpreter'         ,Interpreter                     , ...
    'Tag'                 ,'Question'                        ...
    );  %#ok

IconAxes=axes(                                      ...
    'Parent'      ,QuestFig              , ...
    'Units'       ,'Pixels'              , ...
    'Position'    ,[IconXOffset IconYOffset IconWidth IconHeight], ...
    'NextPlot'    ,'replace'             , ...
    'Tag'         ,'IconAxes'              ...
    );

set(QuestFig ,'NextPlot','add');

load dialogicons.mat questIconData questIconMap;
IconData=questIconData;
questIconMap(256,:)=get(QuestFig,'color');
IconCMap=questIconMap;

Img=image('CData',IconData,'Parent',IconAxes);
set(Img,'visible','off');
set(QuestFig, 'Colormap', IconCMap);
set(IconAxes, ...
    'Visible','off'           , ...
    'YDir'   ,'reverse'       , ...
    'XLim'   ,get(Img,'XData'), ...
    'YLim'   ,get(Img,'YData')  ...
    );

% make sure we are on screen
movegui(QuestFig)


set(QuestFig ,'WindowStyle','normal','Visible','on');
drawnow;
if DefaultButton ~= 0
    uicontrol(BtnHandle(DefaultButton));
end

uiwait(QuestFig);

if isscalar(QuestFig) && ishandle(QuestFig)
    if DefaultWasPressed
        ButtonName=Default;
    else
        ButtonName=get(get(QuestFig,'CurrentObject'),'String');
    end
    doDelete;
else
    ButtonName='';
end

    function doFigureKeyPress(obj, evd)  %#ok
        switch(evd.Key)
            case {'return','space'}
                if DefaultValid
                    DefaultWasPressed = true;
                    uiresume(gcbf);
                end
            case 'escape'
                doDelete
        end
    end

    function doControlKeyPress(obj, evd)  %#ok
        switch(evd.Key)
            case {'return'}
                if DefaultValid
                    DefaultWasPressed = true;
                    uiresume(gcbf);
                end
            case 'escape'
                doDelete
        end

    end

    function doDelete(varargin)  %#ok
        delete(QuestFig);
    end
end

function c = acs_read_init_all(iniFilePath,dateRange, SysNbr, metdataPath)

c =[];
fid = fopen(iniFilePath);
if fid < 0
    error(['Init file: ' iniFilePath ' not found!'])
end

while 1
    s = fgetl(fid);
    if ~ischar(s),break,end
    eval(s)
end

fclose(fid);

end