function varargout = view_sites(varargin)
% VIEW_SITES M-file for view_sites.fig
%      VIEW_SITES, by itself, creates a new VIEW_SITES or raises the existing
%      singleton*.
%
%      H = VIEW_SITES returns the handle to a new VIEW_SITES or the handle to
%      the existing singleton*.
%
%      VIEW_SITES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEW_SITES.M with the given input arguments.
%
%      VIEW_SITES('Property','Value',...) creates a new VIEW_SITES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before view_sites_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to view_sites_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help view_sites

% Last Modified by GUIDE v2.5 06-Apr-2005 18:07:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @view_sites_OpeningFcn, ...
                   'gui_OutputFcn',  @view_sites_OutputFcn, ...
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


% --- Executes just before view_sites is made visible.
function view_sites_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to view_sites (see VARARGIN)

% Choose default command line output for view_sites
handles.output = hObject;
set(hObject,'tag','View_sites')

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes view_sites wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = view_sites_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function lboxSites_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lboxSites (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in lboxSites.
function lboxSites_Callback(hObject, eventdata, handles)
% hObject    handle to lboxSites (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lboxSites contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lboxSites


% --- Executes during object creation, after setting all properties.
function lboxPlots_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lboxPlots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in lboxPlots.
function lboxPlots_Callback(hObject, eventdata, handles)
% hObject    handle to lboxPlots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lboxPlots contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lboxPlots


% --- Executes on button press in chkDiagnostics.
function chkDiagnostics_Callback(hObject, eventdata, handles)
% hObject    handle to chkDiagnostics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkDiagnostics


% --- Executes during object creation, after setting all properties.
function popYear_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popYear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in popYear.
function popYear_Callback(hObject, eventdata, handles)
% hObject    handle to popYear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popYear contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popYear


% --- Executes during object creation, after setting all properties.
function popDate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in popDate.
function popDate_Callback(hObject, eventdata, handles)
% hObject    handle to popDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popDate contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popDate
sContents = get(hObject,'String');
nValue = get(hObject,'Value');
if nValue == length(sContents)
    [h,startDate,endDate] = msgGetDataRange(hObject,char(sContents(nValue)));   % prompt for dates only if last option is selected in the popDate
    if ~isempty(startDate) & ~isempty(endDate)
        sContents(nValue) = {sprintf('From: %s To: %s',num2str(char(startDate)), num2str(char(endDate)))};
    else
        sContents(nValue) = {'Date Range'};
    end
    set(hObject,'String',sContents)
end

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_main_figure = get(hObject,'parent');
set(h_main_figure,'visible','off','handlevisibility','off')
view_selected_sites(h_main_figure)
set(h_main_figure,'visible','on','handlevisibility','callback')

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_main_figure = get(hObject,'parent');
delete(h_main_figure)


