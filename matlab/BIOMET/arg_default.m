function arg_default(arg_name,arg_default_val)
% ARG_DEFAULT Assign default value to argument if it does not exist
%
%    ARG_DEFAULT(ARG_NAME,ARG_DEFAULT_VAL) assign the variable named
%    ARG_NAME the value ARG_DEFAULT_VAL in the caller workspace if it 
%    does not exist in the caller workspace or if it is empty.
%    
%    ARG_DEFAULT(ARG_NAME) assign the empty matrix to the variable 
%    named ARG_NAME in the caller workspace if it does not exist in 
%    the caller workspace.

% kai* - Jun 2, 2004
%
% Revisions
%  Aug 26, 2022 (Zoran)
%   - Fixed a bug where the user wants to assign '' (empty char) and 
%     instead gets [] (empty double).
%   - cleaned up some syntax too (&&,||,'var',...)

% Test if argument exist or is empty
arg_exist      = evalin('caller',['exist(''' arg_name ''')==1']);
if arg_exist 
   arg_isempty = evalin('caller',['isempty(' arg_name ')']);
else
   arg_isempty = 1;
end

% Assign default value
if (exist('arg_default_val','var') && ~isempty(arg_default_val)) ...
        && (~arg_exist || arg_isempty)
    assignin('caller',arg_name,arg_default_val);
elseif (~exist('arg_default_val','var') || isempty(arg_default_val)) ...
        && (~arg_exist)
    if ischar(arg_default_val)
        assignin('caller',arg_name,arg_default_val);
    else
        assignin('caller',arg_name,[]);
    end
 end
