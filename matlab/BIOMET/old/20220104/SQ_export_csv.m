function SQ_export_csv(pth_dbtraces,pthOut);

lst_fn = dir(pth_dbtraces);
isDir = [lst_fn.isdir]';
indfn = find(~isDir);
fn = {lst_fn.name}';
fn = fn(indfn);
m=1;
n=1;
%GMToffset = 7/24; % UTC to MST (Edmonton, Alberta)
for kk=1:length(fn)
    fileNm=char(fn(kk));
    if strcmp(fileNm,'TimeVector')
        tv = read_bor(fullfile(pth_dbtraces,fileNm),8);
        continue
    else   
%         switch fileNm(1:3)
%             case {'co2'}
%                 if ~strcmp(fileNm(5:7),'std') 
%                     if m==1
%                       channelsTitles=[];
%                       dataOut=NaN.*ones(length(tv),3);
%                     end
%                     dataOut(:,m) = read_bor(fullfile(pth_dbtraces,fileNm));
%                     if m<3
%                       m=m+1;
%                       continue
%                     else
%                       channelsOut = size(dataOut,2);
%                       channelsTitles = {'co2_avg' 'co2_max' 'co2_min'};
%                       disp(sprintf('Exported %s',fullfile(pthOut,[fileNm(1:4) fileNm(9:end) '.csv'])));
%                       save_csv(fullfile(pthOut,[fileNm(1:4) fileNm(9:end) '.csv']),tv,dataOut,channelsOut,channelsTitles);
%                       clear dataOut
%                     end
%                 else
%                     dataOut = read_bor(fullfile(pth_dbtraces,fileNm));
%                     channelsTitles=fileNm;
%                     channelsOut = size(dataOut,2);
%                     disp(sprintf('Exported %s',fullfile(pthOut,[fileNm '.csv'])));
%                     save_csv(fullfile(pthOut,[fileNm '.csv']),tv,dataOut,channelsOut,channelsTitles);
%                     clear dataOut
%                 end
%             case {'h2o'}
%                 if ~strcmp(fileNm(5:7),'std') 
%                     if m==1
%                       channelsTitles=[];
%                       dataOut=NaN.*ones(length(tv),3);
%                     end
%                     dataOut(:,m) = read_bor(fullfile(pth_dbtraces,fileNm));
%                     if m<3
%                       m=m+1;
%                       continue
%                     else
%                       channelsOut = size(dataOut,2);
%                       channelsTitles = {'h2o_avg' 'h2o_max' 'h2o_min'};
%                       disp(sprintf('Exported %s',fullfile(pthOut,[fileNm(1:4) fileNm(9:end) '.csv'])));
%                       save_csv(fullfile(pthOut,[fileNm(1:4) fileNm(9:end) '.csv']),tv,dataOut,channelsOut,channelsTitles);
%                        clear dataOut
%                     end
%                 else
%                     dataOut = read_bor(fullfile(pth_dbtraces,fileNm));
%                     channelsTitles=fileNm;
%                     channelsOut = size(dataOut,2);
%                     disp(sprintf('Exported %s',fullfile(pthOut,[fileNm '.csv'])));
%                     save_csv(fullfile(pthOut,[fileNm '.csv']),tv,dataOut,channelsOut,channelsTitles);
%                     clear dataOut
%                 end 
%             otherwise
               dataOut = read_bor(fullfile(pth_dbtraces,fileNm));
               channelsTitles=fileNm;
               channelsOut = size(dataOut,2);
               disp(sprintf('Exported %s',fullfile(pthOut,[fileNm '.csv'])));
               save_csv(fullfile(pthOut,[fileNm '.csv']),tv,dataOut,channelsOut,channelsTitles);
               clear dataOut
         % end
       end
       
 end

%==============================================================
function save_csv(fileName,tv,dataOut,channelsOut,channelsTitles)
fid=fopen(fileName,'w');

fprintf(fid,'%s','Time (UTC)');
for i=1:length(channelsOut)
    %fprintf(fid,',%s',char(channelsTitles(i)));
    fprintf(fid,',%s',channelsTitles);
end
fprintf(fid,'\n');

for i=1:size(dataOut,1)
    oneLine = datestr(tv(i),31);
    for j=1:length(channelsOut)
        oneLine = [oneLine sprintf(',%6.2f',dataOut(i,j))]; %#ok<AGROW>
    end
    fprintf(fid,'%s\n',oneLine);
end
fclose(fid);
