function fr_copy_biomet_dot_net(pth_out)
% fr_copy_biomet_dot_net(pth_out) 
% Copy \\paoa001\matlab to fullfile(pth_out,'biomet.net\matlab')

pth_dest   = fullfile(pth_out,'biomet.net\matlab');
pth_source = '\\paoa001\matlab';

mkdir(pth_out,'biomet.net\matlab');

copyfile(pth_source,pth_dest);
