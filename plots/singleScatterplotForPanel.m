%% Plot scatterplot into currently active subplot
% This script has to be called to plot a scatterplot and regression curves
% into a predefined subplot.
%
% Variables to be set beforehand:
%   patientId
%   cMode
%   cSignal
%   cParameter
%   cNameString
%
% plots are saved to ....
%
% path of main.m has to be current matlab folder!
%
% Author: Johann Roth
% Date: 08.01.2016

%% Load scatterplot data
fromRefData = Results.(patientId).(cMode).FromRef.(cSignal).ScatterplotData.(cParameter);
toRefData   = Results.(patientId).(cMode).ToRef.(cSignal).ScatterplotData.(cParameter);
refInterval = Results.(patientId).(cMode).refInterval;

%% Convert to percentage values
fromRefData(:,3) = 100*fromRefData(:,3);
toRefData(:,3) = 100*toRefData(:,3);

%% Create scatterplot
hold on;
grid on;
grid minor;
plot(fromRefData(:,1),fromRefData(:,3),'rx');
plot(toRefData(:,1),toRefData(:,3),'bo');
plot([-500 500],[0 0],'k:');
plot(refInterval,0,'ks');

%% Find outliers in plot (more than 1.5 or less than 0.5 change)
% and mark them in plot

% value higher than margin to display (marked with ^)
outlierIndices = find(fromRefData(:,3) > yLimit(2));
if isempty(outlierIndices)
else
    plot(fromRefData(outlierIndices,1),yLimit(2),'^k','MarkerSize',4);
end
outlierIndices = find(toRefData(:,3) > yLimit(2));
if isempty(outlierIndices)
else
    plot(toRefData(outlierIndices,1),yLimit(2),'^k','MarkerSize',4);
end

% value lower than margin to display (marked with v)
outlierIndices = find(fromRefData(:,3) < yLimit(1));
if isempty(outlierIndices)
else
    plot(fromRefData(outlierIndices,1),yLimit(1),'vk','MarkerSize',4);
end
outlierIndices = find(toRefData(:,3) < yLimit(1));
if isempty(outlierIndices)
else
    plot(toRefData(outlierIndices,1),yLimit(1),'vk','MarkerSize',4);
end

%% Create Regression plots

% for FromRef values
if length(fromRefData(:,3)) > 3
    [ xReg, yReg, rSquaredFromRef, ~] = ...
        calculateRegression( fromRefData(:,1), fromRefData(:,3) );
    plot(xReg,yReg,'r-.', 'LineWidth', 1);
end
% for ToRef values
if length(toRefData(:,3)) > 3
    [ xReg, yReg, rSquaredToRef, ~] = ...
        calculateRegression( toRefData(:,1), toRefData(:,3) );
    plot(xReg,yReg,'b-.', 'LineWidth', 1);
end
% for combined values
if length(toRefData(:,3)) +  length(fromRefData(:,3)) > 3
    [ xReg, yReg, rSquared, ~] = ...
        calculateRegression( [ toRefData(:,1) ; fromRefData(:,1) ],...
        [ toRefData(:,3) ; fromRefData(:,3) ]);
    plot(xReg,yReg,'g-', 'LineWidth', 1.5);
else
    rSquared = 0;
end

%% Put rectangle under rSquared value in corner
% switch cMode
%     case 'AV'
%         rectangle('Position',[ 100 0.535 250 0.035],...
%             'FaceColor', 'w',...
%             'EdgeColor', 'none');
%     case 'VV'
%         rectangle('Position',[ 100 0.52 250 0.07 ])
% end

%
% %% Put text for rSquared values in corner of plot
% switch cMode
%     case 'AV'
%         xText = 340;
%     case 'VV'
%         xText = 100;
% end
% yText = yLimit(1)*1.05;
% text(xText,yText,['R^2 = ' num2str(rSquared,'%1.3f')], ...
%     'VerticalAlignment','bottom',...
%     'HorizontalAlignment','right');

%% Scaling depending on stimulation mode (AV or VV)
switch cMode
    case 'AV'
        axis([ 0 350 yLimit(1) yLimit(2)]);
        set(gca,'XTick',0:100:350);
    case 'VV'
        axis([ -100 100 yLimit(1) yLimit(2)]);
        set(gca,'XTick',-80:40:80);
end
set(gca,'YTick',yLimit(1):25:yLimit(2));

%% Input title
if rSquared == 0
    title({['\fontsize{8}' cNameString] ['\rm R^2 = N/A']});
else
title({['\fontsize{8}' cNameString] ['\rm R^2 = ' num2str(rSquared,'%1.3f')]});
end

