function stack_subplots(axN)
% figure(figNum)
% clf
nPlt = length(axN);
pOld = zeros(nPlt,4);
% axN = zeros(nPlt);
yAxisLoc = 'left';
for cnt1 = 1:nPlt
    pOld(cnt1,:) = get(axN(cnt1),'position');
    if cnt1 < nPlt
        set(axN(cnt1),'XTickLabel',[]);
    end
    set(axN(cnt1),'fontsize',8,'YAxisLocation',yAxisLoc);
    if strcmp(yAxisLoc,'left')
        yAxisLoc = 'right';
    else
        yAxisLoc = 'left';
    end
end

% deltaSpace = (nPlt-1)*(pOld(1,2)-(pOld(2,2)+pOld(2,4)))/(nPlt);% - 0.07 ;
% if deltaSpace < 0
%     deltaSpace = 0;
% end
% pNew = pOld;
% for cnt1 = 1:nPlt
%     pNew(cnt1,4) = pOld(cnt1,4) + deltaSpace;
%     set(axN(cnt1),'position',pNew(cnt1,:))
% end

%
% calculate your own spacing
%
topMargin = 0.01;
bottomMargin = 0.08;
axSpacing = 0.002;
figHeight = 1 - topMargin - bottomMargin;
axHeight = figHeight/nPlt-axSpacing;
pNew = pOld;
for cnt1 = 1:nPlt
    pNew(cnt1,:) = [pOld(cnt1,1) 1-(topMargin+cnt1*axHeight+(cnt1-1)*axSpacing) pOld(cnt1,3) axHeight];
    set(axN(cnt1),'position',pNew(cnt1,:))
end




