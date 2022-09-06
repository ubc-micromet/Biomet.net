function varargout = view_export(varargin)
% VIEW_EXPORT M-file for view_export.fig
%      VIEW_EXPORT, by itself, creates a new VIEW_EXPORT or raises the existing
%      singleton*.
%
%      H = VIEW_EXPORT returns the handle to a new VIEW_EXPORT or the handle to
%      the existing singleton*.
%
%      VIEW_EXPORT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEW_EXPORT.M with the given input arguments.
%
%      VIEW_EXPORT('Property','Value',...) creates a new VIEW_EXPORT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before view_export_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to view_export_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help view_export

% Last Modified by GUIDE v2.5 08-Oct-2010 12:54:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @view_export_OpeningFcn, ...
                   'gui_OutputFcn',  @view_export_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before view_export is made visible.
function view_export_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to view_export (see VARARGIN)

% Choose default command line output for view_export
handles.output = hObject;
handles.pathFlag = 0;

% connect to Fluxnet03
disp('net use \\Fluxnet03\FCRN_DIS_archive arctic /user:biomet');
dos('net use \\Fluxnet03\FCRN_DIS_archive arctic /user:biomet');

cwdir = pwd;
% dir_path = '\\Fluxnet03\FCRN_DIS_archive\';
% cd (dir_path)
% dir_struct = dir(dir_path);
% is_dir = [dir_struct.isdir];
% fnames = {dir_struct.name};
% ind_dir=[];
% for k=1:length(fnames), 
%     if is_dir(k)==1 & strfind(char(fnames{k}),'20'), 
%         ind_dir = [ind_dir; k]; 
%     end; 
% end
% dir_names = {dir_struct(ind_dir).name};
% [sorted_names,sorted_index] = sortrows(dir_names');
% handles.dir_names = sorted_names;
% handles.is_dir = [dir_struct.isdir];
% handles.sorted_index = sorted_index;
% %guidata(handles.figure1,handles)
% guidata(hObject,handles);
% set(handles.DIS_dir_listbox,'String',handles.dir_names,...
%     'Value',1)
% cd(cwdir);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes view_export wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = view_export_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in site_listbox.
function site_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to site_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns site_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from site_listbox

% ind_site = get(hObject,'Value');
% sitelst = get(hObject,'String');
% handles.SiteId = sitelst{ind_site};
% guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function site_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to site_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in year_listbox.
function year_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to year_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns year_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        year_listbox

% ind_year = get(hObject,'Value');
% yearlst = get(hObject,'String');
% handles.year = yearlst{ind_year};
% guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function year_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to year_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in filetype_listbox.
function filetype_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to filetype_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns filetype_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        filetype_listbox

% ind_ftype = get(hObject,'Value');
% ftypelst = get(hObject,'String');
% handles.ftype = ftypelst{ind_ftype};
% guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function filetype_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filetype_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in viewbutton.
function viewbutton_Callback(hObject, eventdata, handles)
% hObject    handle to viewbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% from ExportCheckGUI
% SiteId = varargin{1};
% Year = str2double(varargin{2});
% ftype = varargin{3};
% pathFlag = str2double(varargin{4});

% handles
% ExportCheckGUI(handles.SiteId,handles.year,handles.ftype,handles.pathFlag);

h_main_figure = get(hObject,'parent');
set(h_main_figure,'visible','off','handlevisibility','off')

sites = get_gui_string(h_main_figure,'site_listbox');
years = get_gui_string(h_main_figure,'year_listbox');
ftype = get_gui_string(h_main_figure,'filetype_listbox');
DISmirrorloc = get_gui_string(h_main_figure,'DIS_mirror_textbox');
userloc = get_gui_string(h_main_figure,'user_directory_textbox');
pthflag_dis = handles.pathFlag;

for i=1:length(sites)
    for j=1:length(years)
        Selection.Site = sites{i};
        Selection.Year = years{j};
        Selection.ftype = ftype;
        Selection.Path = pthflag_dis;
        fr_set_site(sites{i},'n');
        config = fr_get_init(sites{i},now);
        Selection.GMTshift = config.gmt_to_local;
        if pthflag_dis==2
            %Selection.DISmirrorloc = DISmirrorloc;
            if ~exist(DISmirrorloc,'dir')
                uiwait(errordlg('DIS mirror not found: please re-enter selection','view_export','modal'));
                set(h_main_figure,'visible','on','handlevisibility','callback');
                return
            else
                Selection.DISmirrorloc = DISmirrorloc;
            end
        end
        if pthflag_dis==3
            if ~exist(userloc,'dir')
                uiwait(errordlg('User directory does not exist: please re-enter selection','view_export','modal'));
                set(h_main_figure,'visible','on','handlevisibility','callback');
                return
            else
                Selection.DISmirrorloc = userloc;
            end
        end
        %save export_selections_tmp Selection;
        figure(999);
        set(999,'HandleVisibility','off','Visible','off','UserData',Selection)
        try
           ExportCheckGUI;
        catch
           disp(['ExportCheckGUI failed for ' Selection.Site ' ' Selection.Year]);
        end
        set(h_main_figure,'visible','on','handlevisibility','callback');
    end
end


% --- Executes on button press in exitbutton.
function exitbutton_Callback(hObject, eventdata, handles)
% hObject    handle to exitbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h_main_figure = get(hObject,'parent');
h_top = get(h_main_figure,'parent');
delete(h_top)
%dos('del export_selections_tmp.mat');

% --------------------------------------------------------------------
function DIS_fileloc_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to DIS_fileloc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

switch get(hObject,'Tag')   % Get Tag of selected object
    case 'radio_toDIS'
        handles.pathFlag = 0;
        set(handles.DIS_mirror_textbox,'BackgroundColor',[0.584 0.584 0.584]);
        set(handles.user_directory_textbox,'BackgroundColor',[0.584 0.584 0.584]);
        set(handles.site_listbox,'BackgroundColor','white');
        set(handles.year_listbox,'BackgroundColor','white');
        set(handles.filetype_listbox,'BackgroundColor','white');
        set(handles.user_directory_textbox,'String','');
        set(handles.DIS_mirror_textbox,'String','');
    case 'radio_biometcurrent'
        handles.pathFlag = 1;
        set(handles.DIS_mirror_textbox,'BackgroundColor',[0.584 0.584 0.584]);
        set(handles.user_directory_textbox,'BackgroundColor',[0.584 0.584 0.584]);
        set(handles.site_listbox,'BackgroundColor','white');
        set(handles.year_listbox,'BackgroundColor','white');
        set(handles.filetype_listbox,'BackgroundColor','white');
        set(handles.user_directory_textbox,'String','');
        set(handles.DIS_mirror_textbox,'String','');
    case 'radio_DISmirror'
        handles.pathFlag = 2;
        % highlight the DIS dir listbox entries 
        set(handles.DIS_mirror_textbox,'BackgroundColor','white');
        set(handles.DIS_mirror_textbox,'String','<Enter DIS mirror directory>');
        set(handles.user_directory_textbox,'BackgroundColor',[0.584 0.584 0.584]);
        set(handles.site_listbox,'BackgroundColor','white');
        set(handles.year_listbox,'BackgroundColor','white');
        set(handles.filetype_listbox,'BackgroundColor','white');
        set(handles.user_directory_textbox,'String','');
    case 'radio_customdir'
        handles.pathFlag = 3;
        set(handles.DIS_mirror_textbox,'BackgroundColor',[0.584 0.584 0.584]);
        set(handles.site_listbox,'BackgroundColor',[0.584 0.584 0.584]);
        set(handles.year_listbox,'BackgroundColor',[0.584 0.584 0.584]);
        set(handles.filetype_listbox,'BackgroundColor',[0.584 0.584 0.584]);
        set(handles.user_directory_textbox,'BackgroundColor','white');
        set(handles.user_directory_textbox,'String','<Enter user directory>');
        set(handles.DIS_mirror_textbox,'String','');
        %uiwait(warndlg('.CSV files must be DIS format','view_export','modal'));
end
guidata(hObject,handles);

% --- Executes on selection change in DIS_dir_listbox.
function DIS_dir_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to DIS_dir_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns DIS_dir_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DIS_dir_listbox


% --- Executes during object creation, after setting all properties.
function DIS_dir_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DIS_dir_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[0.584 0.584 0.584]);
end


function user_directory_textbox_Callback(hObject, eventdata, handles)
% hObject    handle to user_directory_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of user_directory_textbox as text
%        str2double(get(hObject,'String')) returns contents of user_directory_textbox as a double

%set(hObject,'String','<Enter user directory>');

% --- Executes during object creation, after setting all properties.
function user_directory_textbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to user_directory_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
 set(hObject,'BackgroundColor',[0.584 0.584 0.584]);
%end

function [sString,indSelection] = get_gui_string(hObject,tagValue)

hNew = findobj(hObject,'tag',tagValue);        % get the handle to Site listbox
indSelection = get(hNew,'value');
sString = get(hNew,'String');
if indSelection > 0
    %sString = char(sString(indSelection));
    sString = sString(indSelection); % leave as cellstr array
% else
%     sString = [];
end
return



function DIS_mirror_textbox_Callback(hObject, eventdata, handles)
% hObject    handle to DIS_mirror_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DIS_mirror_textbox as text
%        str2double(get(hObject,'String')) returns contents of DIS_mirror_textbox as a double



% --- Executes during object creation, after setting all properties.
function DIS_mirror_textbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DIS_mirror_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor',[0.584 0.584 0.584]);
%end


