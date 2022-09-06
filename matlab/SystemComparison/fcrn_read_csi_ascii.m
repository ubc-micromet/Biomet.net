function [x,Header,tv] = fcrn_read_csi_ascii(fileName,time_string_flag,headerlines,assign_in,strbuffsize)
% [x,Header,tv] = fcrn_read_csi_ascii(fileName,time_string_flag,headerlines,asign_flag)
%
% Read CR5000 ascii output tables
% 
% filename is the name and path of the input file, time_string_flag should
% be 1 if the first column is an string formated time, headerlines is the
% number of headerlines before the data starts, assign_in can be 'caller'
% or 'base' and will lead to the variables being assigned in the given
% workspace with names as given in the second line of the header. If not present, no assigning is done.
% (c) Kai Morgenstern/Zoran Nesic           File created:              ~2005
%                                           Last modification:  Oct 21, 2011
%

% Revisions
% Oct 21, 2011 (Zoran)
%   - switched to fr_read_TOA5_file.
% May 27, 2011 (Nick)
%   -introduced user definable string buffer size (default was 4095 and
%   this was exceeded for MPB3).
%  Oct 17, 2007 (Zoran)
%       - Added 'INF' to the list of variables with special processing(-999)

arg_default('headerlines',4)
arg_default('assign_in',0)
arg_default('strbuffsize',10000)

defaultNaN = '-999';
time_string_flag = 1; % needed to replicate the bug that exsisted in the original fcrn_read_csi_ascii function

disp('Function: fcrn_read_csi_ascii.m is obsolete.  Please use fr_read_TOA5_file.m instead for all new programs.');
[x,Header,tv] = fr_read_TOA5_file(fileName,time_string_flag,headerlines,defaultNaN,assign_in,strbuffsize);


% 
% % Find no of variables in file
% s_read = textread(fileName,'%q',1,'headerlines',headerlines,'bufsize',strbuffsize);
% N = length(split_line(char(s_read)));
% 
% 
% 
% % Read header
% if headerlines > 0
%     for i = 1:headerlines
%         s_read = textread(fileName,'%q',1,'headerlines',i-1,'bufsize',strbuffsize);
%         eval(['Header.line' num2str(i) ' = split_line(char(s_read));']);
%     end
%     var_names = Header.line2;
%     var_names = regexprep(var_names,'\(','');
%     var_names = regexprep(var_names,'\)','');
%     var_names = regexprep(var_names,'[','');
%     var_names = regexprep(var_names,']','');
% else
%     for i = 1:N
%         var_names(i) = {['x_' num2str(i)]};
%     end
% end
% 
% % Create format string
% if time_str_flag==1
%     formatStr = '%q';
%     formatStr2 = char(ones(N-1,1)*' %f')';
%     var_names_numbers = {'TIMESTAMP'};
% else
%     formatStr = '';
%     formatStr2 = char(ones(N,1)*' %f')';
% end
% 
% if headerlines == 4 % 4th line contain variable type
%     for i = 2:N
%         % Only export any variables that are numbers
%         switch char(Header.line4(i))
%             case {'TMx','TMn'}
%                 formatStr = [formatStr ' %*s'];
%             otherwise
%                 formatStr = [formatStr ' %f'];
%                 var_names_numbers = [var_names_numbers var_names(i)];
%         end
%     end
%     var_names = var_names_numbers;
%     N = length(var_names);
% else
%     formatStr = [formatStr formatStr2(:)'];
%     formatStr = formatStr(:)';
%     formatStr = [formatStr];
% end
% Header.var_names = var_names(2:end);
% 
% outStr = ['['];
% for i = 1:N
%     outStr = [outStr char(var_names(i)) ' '];
% end
% outStr = [outStr ']'];    
% 
% try
%     eval([outStr ' = textread(fileName,formatStr,-1,''delimiter'','','',''headerlines'',headerlines,''bufsize'',strbuffsize);']);    
% catch
% %   q_read = textread(fileName,'%q','headerlines',headerlines);
% % load everything as a big char array
%     fid=fopen(fileName,'r');
%     q_read = char(fread(fid,inf,'uchar'))';
%     fclose(fid);
% 
%    q_read = regexprep(q_read,'-1.#IND','-999');
%    q_read = regexprep(q_read,'"NAN"','-999');
%    q_read = regexprep(q_read,'-1.#QNAN','-999');   
%    q_read = regexprep(q_read,'"INF"','-999');  
%    q_read = regexprep(q_read,'"-INF"','-999');
%     tempFileName = 'c:\temp.junk';
%     fid = fopen(tempFileName,'w');
%     fwrite(fid,q_read,'uchar');
%     %fprintf(fid,'%s',xx);
%     fclose(fid);
%     eval([outStr ' = textread(tempFileName,formatStr,-1,''delimiter'','','',''headerlines'',headerlines,''bufsize'',strbuffsize);']);    
%    %eval([outStr ' = strread(char(q_read)'',formatStr,-1,''delimiter'','','');']);    
% end
% 
% outStr = ['['];
% for i = 2:N
%     outStr = [outStr  char(var_names(i)) ' '];
%     if assign_in ~= 0
%         eval(['assignin(assign_in,char(var_names(i)),' char(var_names(i)) ');']);
%     end
% end
% outStr = [outStr ']'];    
% 
% eval(['x = ' outStr ';']);   
%     
% % Export time vector
% if time_str_flag
% %   "2005-05-26 01:30:00"
%     tv_char = char(TIMESTAMP);
%     tv = datenum(str2num(tv_char(:,1:4)),str2num(tv_char(:,6:7)),str2num(tv_char(:,9:10)),...
%         str2num(tv_char(:,12:13)),str2num(tv_char(:,15:16)),str2num(tv_char(:,18:19)));
%     % Deal with missing years in time stamp that happen in strread above
%     if isempty(tv)
%         for i = 1:length(tv_char)
%             tv_tmp = datenum(str2num(tv_char(i,1:4)),str2num(tv_char(i,6:7)),str2num(tv_char(i,9:10)),...
%                 str2num(tv_char(i,12:13)),str2num(tv_char(i,15:16)),str2num(tv_char(i,18:19)));
%             if ~isempty(tv_tmp)
%                 tv(i) = tv_tmp;
%             else
%                 tv(i) = NaN;
%             end
%         end
%         ind_nan = find(isnan(tv));
%         ind_nonan = find(~isnan(tv));
%         tv(ind_nan) = interp1(ind_nonan,tv(ind_nonan),ind_nan);
%         tv = tv';
%     end
% else
%     tv = NaN;
% end
% 
% if assign_in ~= 0
%     assignin(assign_in,'tv_csi',tv);
% end
% 
% return
% 
% function line_cell = split_line(line_str)
% 
% line_str = regexprep(line_str,'"','');
% ind = [0 strfind(line_str,',')];
% 
% for i = 1:length(ind)-1
%     line_cell(i) = {line_str(ind(i)+1:ind(i+1)-1)};
% end
% line_cell(i+1) = {line_str(ind(end)+1:end)};
