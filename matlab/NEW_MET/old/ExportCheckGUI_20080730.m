function varargout = ExportCheckGUI(varargin)
% EXPORTCHECKGUI M-file for ExportCheckGUI.fig
%      EXPORTCHECKGUI, by itself, creates a new EXPORTCHECKGUI or raises the existing
%      singleton*.
%
%      H = EXPORTCHECKGUI returns the handle to a new EXPORTCHECKGUI or the handle to
%      the existing singleton*.
%
%      EXPORTCHECKGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXPORTCHECKGUI.M with the given input arguments.
%
%      EXPORTCHECKGUI('Property','Value',...) creates a new EXPORTCHECKGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ExportCheckGUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ExportCheckGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ExportCheckGUI

% Last Modified by GUIDE v2.5 19-Jun-2008 15:44:47

% Revisions by BIOMET
%
% Feb 28, 2008
%   - made this function a stand alone (it can be called directly without
%   any input parameters.  This also made it compatible with Matlab 7.
%   - fixed plotting of NaN values 
%   - added GUI for SiteID, Year, dataBaseFlag
%  


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ExportCheckGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ExportCheckGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before ExportCheckGUI is made visible.
function ExportCheckGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ExportCheckGUI (see VARARGIN)

% Choose default command line output for ExportCheckGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using ExportCheckGUI.
if strcmp(get(hObject,'Visible'),'off')
    trace_str = get(hObject,'UserData');
    plot_data(trace_str,1);
elseif ~isempty(get(hObject,'UserData'))
    trace_str = get(hObject,'UserData');
    
    for i = 1:length(trace_str)
        varName(i) = {trace_str(i).variableName};
    end
    set(findobj(hObject,'Tag','popupmenu1'),'String',varName);
    trace_str = get(hObject,'UserData');
    plot_data(trace_str,1);
end


% UIWAIT makes ExportCheckGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ExportCheckGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
cla;

trace_str = get(get(hObject,'Parent'),'UserData');

popup_sel_index = get(handles.popupmenu1, 'Value');
if popup_sel_index == 1 
   set(handles.pushbutton2, 'ForegroundColor',[0 0 0]);
   popup_sel_index = mod(popup_sel_index-1+1,length(trace_str))+1;
   set(handles.popupmenu1, 'Value',popup_sel_index);
   plot_data(trace_str,popup_sel_index);
elseif popup_sel_index > 1 & popup_sel_index < length(trace_str)
   popup_sel_index = mod(popup_sel_index-1+1,length(trace_str))+1;
   set(handles.popupmenu1, 'Value',popup_sel_index);
   plot_data(trace_str,popup_sel_index);
else
   plot_data(trace_str,length(trace_str));
   set(handles.pushbutton1, 'ForegroundColor',[0.584 0.584 0.584]); % grey out the button
end


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

trace_str = get(get(hObject,'Parent'),'UserData');
for i = 1:length(trace_str)
    varName(i) = {trace_str(i).variableName};
end
set(findobj(hObject,'Tag','popupmenu1'),'String',varName);
%set(hObject, 'String', 'No data');

% --- Executes on selection change in popupmenu3.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes1);
cla;

trace_str = get(get(hObject,'Parent'),'UserData');
popup_sel_index = get(handles.popupmenu1, 'Value');
plot_data(trace_str,popup_sel_index);
% Hints: contents = get(hObject,'String') returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3



% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% load d:\kai\current\trace_str
% trace_str = trace_str(7:end-2);
% set(hObject,'UserData',trace_str);

% if exist('export_selections_tmp.mat','file')
%    load export_selections_tmp;
%    SiteId = Selection.Site;
%    Year = str2double(char(Selection.Year));
%    ftype = Selection.ftype;
%    pathFlag = Selection.Path;
% else % run ExportCheckGUI as before
%     prompt={'SiteID:','Year:','Path (0 - to DIS, 1 - Current'};
%     name='Input Site/year';
%     numlines=1;
%     defaultanswer={'cr','2007','0'};
%     answer=inputdlg(prompt,name,numlines,defaultanswer);
%     SiteId = char(answer(1));
%     Year = str2double(answer(2));
%     pathFlag = str2double(answer(3));
%     ftype = {'all'};
% end

try
   Selection = get(999,'UserData');
   SiteId = Selection.Site;
   Year = str2double(char(Selection.Year));
   ftype = Selection.ftype;
   pathFlag = Selection.Path;
catch % run ExportCheckGUI as before
    prompt={'SiteID:','Year:','Path (0 - to DIS, 1 - Current'};
    name='Input Site/year';
    numlines=1;
    defaultanswer={'cr','2007','0'};
    answer=inputdlg(prompt,name,numlines,defaultanswer);
    SiteId = char(answer(1));
    Year = str2double(answer(2));
    pathFlag = str2double(answer(3));
    ftype = {'all'};
end

out_inf = fcrnexport_dir(SiteId,pathFlag,ftype);
trace_str = [];

for i = 1:length(out_inf)
    trace_str_tmp = readDISCSV(Year,out_inf(i).pth);
    if ~isempty(trace_str_tmp)
        trace_str = [trace_str trace_str_tmp(7:end-2)];
    end
end

for i=1:length(trace_str)
    trace_str(i).SiteId = SiteId;
end
set(hObject,'UserData',trace_str);

for i = 1:length(trace_str)
    varName(i) = {trace_str(i).variableName};
end
set(findobj(hObject,'Tag','popupmenu1'),'String',varName);

return

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes1);
cla;

trace_str = get(get(hObject,'Parent'),'UserData');

popup_sel_index = get(handles.popupmenu1, 'Value');
if popup_sel_index == length(trace_str)
    set(handles.pushbutton1, 'ForegroundColor',[0 0 0]);
    popup_sel_index = mod(popup_sel_index-1-1,length(trace_str))+1;
    set(handles.popupmenu1, 'Value',popup_sel_index);
    plot_data(trace_str,popup_sel_index);
elseif  popup_sel_index > 1 & popup_sel_index <= length(trace_str)-1
    popup_sel_index = mod(popup_sel_index-1-1,length(trace_str))+1;
    set(handles.popupmenu1, 'Value',popup_sel_index);
    plot_data(trace_str,popup_sel_index);
else
    plot_data(trace_str,1);
    set(handles.pushbutton2, 'ForegroundColor',[0.584 0.584 0.584]);
end

% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1

function plot_data(trace_str,ind)

if ~isempty(trace_str) & ~iscell(trace_str(ind).data)
    ind_999   = find(trace_str(ind).data == -999);
    ind_nan   = find(isnan(trace_str(ind).data));
    ind_nonan = find(trace_str(ind).data ~= -999 & ~isnan(trace_str(ind).data));
    if length(ind_nonan)> 0
        data_mean = mean(trace_str(ind).data(ind_nonan));
    else
        data_mean = 0;
    end
%     if isnan(data_mean)
%         data_mean = 0;
%     end

    
%     trace_str(ind).data(ind_nan) = data_mean;
%     trace_str(ind).data(ind_999) = data_mean;
    trace_str(ind).data(ind_999) = NaN; % knock out the -999's with NaNs
    data_nangaps = NaN.*ones(length(trace_str(ind).data),1);
    data_999gaps = NaN.*ones(length(trace_str(ind).data),1);
    data_nangaps(ind_nan)=data_mean;
    data_999gaps(ind_999)=data_mean;
    
    colordef('white');
%    plot(trace_str(ind).DOY(ind_nonan),trace_str(ind).data(ind_nonan));
    plot(trace_str(ind).DOY,trace_str(ind).data,'b-');
      line(trace_str(ind).DOY(ind_999),data_999gaps(ind_999),...
          'LineStyle','none','Marker','.','Color','r');
      line(trace_str(ind).DOY(ind_nan),data_nangaps(ind_nan),...
          'LineStyle','none','Marker','.','Color','c');
    set(gca,'XLim',[trace_str(ind).DOY(1) trace_str(ind).DOY(end)]);
    xlabel('DOY')
    ylabel(trace_str(ind).ini.units);
    
    un = get(gca,'Units');
    set(gca,'Units','centimeter');
    pos = get(gca,'Position');
    set(gca,'Units',un);
    
    SiteId = trace_str(1).SiteId;
    text(0,0,SiteId,...
        'VerticalA','top',...
        'Units','centimeter',...
        'Position',[1 pos(4)-0.4 0],...
        'Interpreter','none','Color',[0 0.502 0],'FontSize',16,...
        'FontWeight','bold');
    text(0,0,trace_str(ind).variableName,...
        'VerticalA','top',...
        'Units','centimeter',...
        'Position',[1 pos(4)-1 0],...
        'Interpreter','none','Color',[0 0 0]);
    text(0,0,['Number of NaNs: ' num2str(length(ind_nan)+length(ind_999))],...
        'VerticalA','top',...
        'Units','centimeter',...
        'Position',[1 pos(4)-1.5 0],...
        'Interpreter','none','Color',[1 0 0]);
    
    text(0,0,['Avg: ' num2str(mean(trace_str(ind).data(ind_nonan)))],...
        'VerticalA','top',...
        'Units','centimeter',...
        'Position',[1 pos(4)-2.5 0],...
        'Interpreter','none');
    text(0,0,['Max: ' num2str(max(trace_str(ind).data(ind_nonan)))],...
        'VerticalA','top',...
        'Units','centimeter',...
        'Position',[1 pos(4)-3.0 0],...
        'Interpreter','none');
    text(0,0,['Min: ' num2str(min(trace_str(ind).data(ind_nonan)))],...
        'VerticalA','top',...
        'Units','centimeter',...
        'Position',[1 pos(4)-3.5 0],...
        'Interpreter','none');
    if (~isempty(strfind(char(trace_str(ind).variableName),'GapFilled')) |...
        ~isempty(strfind(char(trace_str(ind).variableName),'GF')) |...
        ~isempty(strfind(char(trace_str(ind).variableName),'Modelled')))  & ...
            (~isempty(strfind(char(trace_str(ind).variableName),'NEP')) |...
            ~isempty(strfind(char(trace_str(ind).variableName),'GEP')) | ...
            ~isempty(strfind(char(trace_str(ind).variableName),'R')))
        text(0,0,['Sum of trace: ' num2str(12e-6.*1800.*FCRN_nansum(trace_str(ind).data(ind_nonan))) ' g m^-2 y^-1'],...
            'VerticalA','top',...
            'Units','centimeter',...
            'Position',[1 pos(4)-2.0 0],...
            'Interpreter','none','Color',[0 0 0.5]);
    end
    zoom on;
end



% --- Executes on button press in Exitbutton.
function Exitbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Exitbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    hfig999=clf(999);
    delete(hfig999);
end
h_main_figure = get(hObject,'parent');
delete(h_main_figure);