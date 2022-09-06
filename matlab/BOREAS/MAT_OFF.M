function x = mat_off( flag, size, Port, Page, Chan1, Chan2, MaxPorts, MaxPage, MaxChans )
% function x = mat_off( flag, size, Port, Page, Chan1, Chan2, MaxPorts, MaxPage, MaxChans )
%
%  This function is used by hhread.m It returns the exact address(offset) of a matrix element
% in the hhour.bin type of file. 
%
% Zoran Nesic, Biomet, UBC
%
if any(flag == [1 2])
    x = 0;
elseif any(flag == [3 4 5 6 9 10 11 12 13 14 15 16 17])
    x = (Port - 1) * size;
elseif flag == 8
    x = (Chan2 - 1) * MaxChans * MaxPage * MaxPorts;
    x = x + (Chan1 - 1) * MaxPage * MaxPorts;
    x = (x + (Page - 1) * MaxPorts + Port - 1) * size;
elseif flag == 7
    x = (Chan1 - 1) * MaxPage * MaxPorts;
    x = (x + (Page - 1) * MaxPorts + Port - 1) * size;
end

