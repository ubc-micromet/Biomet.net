function [EngUnits,Header] = fr_read_BiometMat_file(fileName,assign_in,varName) 
%
% (c) Zoran Nesic               File created:      May   3, 2012
%                               Last modification: Aug  28, 2023
%
% Revisions:
%
%  Aug 28, 2023 (Zoran)
%   - Made is compatible with the output of other fr_read_* functions. It
%     can now pass to the caller a structure with the name given in varName.
%     

arg_default('assign_in','[]');
arg_default('varName','[]');
EngUnits = [];
Header = [];

% The following line will load up EngUnits and Header from 
% the file.
load(fileName,'-mat'); %#ok<LOAD>

if exist('DataHF','var')
    % this is a PICARRO file HF file
    EngUnits = DataHF;
end

% It is possible to ask the program to output, in addition to the
% matrix EngUnits, all the variables and to put them in the callers
% space.  The variable names are hard-coded in this program
% (see Header.var_names)
numOfChans = size(EngUnits,2); 
if strcmpi(assign_in,'CALLER') && ~isempty(varName)
    for cntChans=1:numOfChans
        strCmd=[varName '.' char(Header.var_names{cntChans}) '=EngUnits(:,cntChans);'];
        eval(strCmd);
    end
    strCmd = [varName '.tv=tv;'];
    eval(strCmd);
    strCmd = sprintf('assignin(%scaller%s,%s%s%s,%s)',39,39,39,varName,39,varName);
    eval(strCmd);
end