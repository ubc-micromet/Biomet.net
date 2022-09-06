function c = db_update(stats,pth,fileNamePrefix)
%
%
% (c) Zoran Nesic           File created:       Apr 18, 1998
%                           Last modification:  May 10, 1998
%

%
% Revisions:
%
%   May 10, 1998
%       -   

pth_out = fr_valid_path_name(pth);          % check the path and create
if isempty(pth_out)                         
    error 'Directory does not exist!'
else
    pth = pth_out;
end
FileNameMain = [pth fileNamePrefix];        % the full file name prefix

%
% Extract and save AvgMinMax values
%
OutputData = DB_matrix_to_vector(stats.BeforeRot.AvgMinMax);




%===============================================================
% LOCAL FUNCTIONS
%===============================================================
function x = file_err_chk(fid)
    if fid == -1
        error 'File opening error'
    end


function OutputData = DB_matrix_to_vector(matIn)

OutputData = [];
dims = size(matIn);
if length(dims) == 3
    for i=1:dims(2)
        OutputData((i-1)*dims(1)+1:i*dims(1),:) = squeeze(matIn(:,i,:));
    end
elseif length(dims) > 3
    error 'Too many dimensions!'
end