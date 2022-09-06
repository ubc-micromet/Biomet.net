function arg_not_exist = not_exist_arg(arg_name)

arg_exist      = evalin('caller',['exist(''' arg_name ''')']);
if arg_exist 
   arg_isempty = evalin('caller',['isempty(' arg_name ')']);
else
   arg_isempty = 1;
end

arg_not_exist= ~arg_exist | arg_isempty;