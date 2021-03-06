function [figure1,figure2]=kurFigWindows2
load /home/yuval/Data/kurtosis/b024/vsLR
X=[1:9];%lat;
Xlabels=[0.125 0.25 0.5 1 2 4 8 16 32];
%% summary
YMatrix1=[sumG2L;sumG2R];
%CREATEFIGURE(X,YMATRIX1)
%  X:  vector of x data
%  YMATRIX1:  matrix of y data

%  Auto-generated by MATLAB on 09-Jan-2013 14:58:11

% Create figure
figure1 = figure('XVisual',...
    '0x29 (TrueColor, depth 24, RGB mask 0xff0000 0xff00 0x00ff)',...
    'PaperSize',[20.98404194812 29.67743169791],...
    'Position',[1,1,700,800],...
    'InvertHardcopy','off',...
    'Color',[1 1 1]);

% Create axes
% axes1 = axes('Parent',figure1,'XTick',[0.125 0.25 0.5 1 2 4 8 16 32],...
%     'XScale','log',...
%     'XMinorTick','on',...
%     'LineWidth',2,...
%     'FontSize',20,...
%     'FontName','Times');
% Uncomment the following line to preserve the Y-limits of the axes
%ylim(axes1,[0 50]);
% Uncomment the following line to preserve the Z-limits of the axes
%zlim(axes1,[-1 1]);
% hold(axes1,'all');

% Create multiple lines using matrix input to semilogx
axes1 = axes('Parent',figure1,'XTick',X,'XTickLabel',Xlabels);
hold(axes1,'all');
xlim([0 10])
subplot(2,1,1)
plot1=plot(Xlabels,YMatrix1,'LineWidth',2,...
    'LineStyle','none',...
    'Color',[0 0 0]);

set(plot1(1),'MarkerSize',30,'Marker','.','DisplayName','Rare Spike');
set(plot1(2),'MarkerFaceColor',[0 0 0],'MarkerSize',10,'Marker','^',...
    'DisplayName','Frequent Spike');

% Create xlabel
% xlabel('Time Window (Seconds)','FontSize',20,'FontName','Times');

% Create ylabel
ylabel('Summary g2','FontSize',20,'FontName','Times');

% Create legend
legend1 = legend('Rare Spike','Frequent spike');
set(legend1,...
    'Position',[0.55 0.75 0.3 0.15],...
    'LineWidth',2,...
    'FontSize',20,'FontName','Times');

title ({'Window length effect on g2 for','sources with different frequencies'},...
    'FontSize',20,'FontName','Times');
%% maximum
YMatrix2=[maxG2L;maxG2R];
% figure2 = figure('XVisual',...
%     '0x29 (TrueColor, depth 24, RGB mask 0xff0000 0xff00 0x00ff)',...
%     'PaperSize',[20.98404194812 29.67743169791],...
%     'Position',[1,1,700,400],...
%     'InvertHardcopy','off',...
%     'Color',[1 1 1]);
% axes2 = axes('Parent',figure2,'XTick',[0.125 0.25 0.5 1 2 4 8 16 32],...
%     'XScale','log',...
%     'XMinorTick','on',...
%     'LineWidth',2,...
%     'FontSize',20,...
%     'FontName','Times');
% hold(axes2,'all');
subplot(2,1,2)
semilogx2 = semilogx(X,YMatrix2,'Parent',axes1,'LineWidth',2,...
    'LineStyle','none',...
    'Color',[0 0 0]);
set(semilogx2(1),'MarkerSize',30,'Marker','.','DisplayName','Rare Spike');
set(semilogx2(2),'MarkerFaceColor',[0 0 0],'MarkerSize',10,'Marker','^',...
    'DisplayName','Frequent Spike');
xlabel('Time Window (Seconds)','FontSize',20,'FontName','Times');

% Create ylabel
ylabel('Maximum g2','FontSize',20,'FontName','Times');

% Create legend
% legend2 = legend(axes2,'show');
% set(legend2,...
%     'Position',[0.5 0.6 0.3 0.15],...
%     'LineWidth',2);
legend('Rare Spike','Frequent Spike')
xlim([0.1 35])
title ({'Window length effect on g2 for','sources with different frequencies'})
