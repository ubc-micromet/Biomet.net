function varargout = msgGetDataRange(varargin)
% MSGGETDATARANGE M-file for msgGetDataRange.fig
%      MSGGETDATARANGE, by itself, creates a new MSGGETDATARANGE or raises the existing
%      singleton*.
%
%      H = MSGGETDATARANGE returns the handle to a new MSGGETDATARANGE or the handle to
%      the existing singleton*.
%
%      MSGGETDATARANGE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MSGGETDATARANGE.M with the given input arguments.
%
%      MSGGETDATARANGE('Property','Value',...) creates a new MSGGETDATARANGE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before msgGetDataRange_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to msgGetDataRange_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help msgGetDataRange

% Last Modified by GUIDE v2.5 14-Apr-2005 12:12:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @msgGetDataRange_OpeningFcn, ...
                   'gui_OutputFcn',  @msgGetDataRange_OutputFcn, ...
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


% --- Executes just before msgGetDataRange is made visible.
function msgGetDataRange_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to msgGetDataRange (see VARARGIN)

% Choose default command line output for msgGetDataRange
handles.output = hObject;
dateRange = char(varargin(2));
handles.output_StartDate = [];
handles.output_EndDate = [];
if ~strcmp(dateRange,'Date Range')
    x = findstr('From:',dateRange);
    if x > 0
        y = findstr('To:',dateRange);
        if y > 0
            handles.output_StartDate = deblank(dateRange(x+6:y-1));
            dateRange = deblank(dateRange(y+4:end));
            handles.output_EndDate = dateRange;
        end
    end
end

h = findobj('Tag','edit1');
set(h,'String',handles.output_StartDate);
h = findobj('Tag','edit2');
set(h,'String',handles.output_EndDate);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes msgGetDataRange wait for user response (see UIRESUME)
 uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = msgGetDataRange_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if ~isempty(handles)
	varargout{1} = handles.output;
	varargout{2} = handles.output_StartDate;
	varargout{3} = handles.output_EndDate;
else
    varargout{1} = [];
    varargout{2} = [];
    varargout{3} = [];    
end
uiresume 
if ishandle(hObject)
    delete(hObject)
end


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
%get(hObject)
%disp('You just changed the first date')
h = findobj('Tag','edit1');
handles.output_StartDate = get(h,'String');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
%set(hObject,'string',handles.output_StartDate)


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
%disp('You just changed the second date')
h = findobj('Tag','edit2');
handles.output_EndDate = get(h,'String');
guidata(hObject,handles);

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%msgGetDataRange

if isfield(handles,'output_StartDate') & isfield(handles,'output_EndDate')
    uiresume
end


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

