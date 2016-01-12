% This script creates a single scatterplot for a selected
% - patient,
% - stimulation mode (AV / VV)
% - signal (PPGCuff / PPGClip / BsBp)
% - parameter (see lists of parameters)
%
% scatterplot is saved to: ....
%
% path of main.m has to be current matlab folder!
%
% Author: Johann Roth
% Date: 06.01.2016

EXCLUDEBEATS = 0;
MAXBEATS = 8;

% Limits for scatterplots
yLimit = [-50 50];

Results = load(['../results/matlab/Results_MAX' num2str(MAXBEATS) '_EX' num2str(EXCLUDEBEATS) '.mat']);

%% Selected parameter, mode, signal and patient
% Good Example
cPatient = 6;
cMode = 'AV';
cSignal = 'PpgClip';
cParameter = 'pulseArea';
legendOutliers = false;

% % bad example
% cPatient = 3;
% cMode = 'AV';
% cSignal = 'PpgCuff';
% cParameter = 'pulseHeight';
% legendOutliers = true;

%% Available parameters, modes and patients
listParameters = Results.Info.parameters;
listBsParameters = Results.Info.bsParameters;

listParameterLatexNames = Results.Info.parameterLatexNames;
listBsParameterLatexNames = Results.Info.bsParameterLatexNames;

listParameterLatexScatterplotNames = Results.Info.parameterLatexScatterplotNames;
listBsParameterLatexScatterplotNames = Results.Info.bsParameterLatexScatterplotNames;

listParameterUnits = Results.Info.parameterUnits;
listBsParameterUnits = Results.Info.bsParameterUnits;

nParameters = length(listParameters);
nBsParameters = length(listBsParameters);
patient = 1:6;
nPatients = length(patient);
listStimModes = [{'AV'},{'VV'}];
listSignals = [{'PpgClip'},{'PpgCuff'},{'BsBp'}];



patientId = ['Pt0' num2str(cPatient)];

%% Find Latex name, unit and scatterplot name to current parameter
switch cSignal
    case 'PpgCuff'
        cParamList = listParameters;
        cLatexNameList = listParameterLatexNames;
        cUnitList = listParameterUnits;
        cScatterplotNameList = listParameterLatexScatterplotNames;
    case 'PpgClip'
        cParamList = listParameters;
        cLatexNameList = listParameterLatexNames;
        cUnitList = listParameterUnits;
        cScatterplotNameList = listParameterLatexScatterplotNames;
    case 'BsBp'
        cParamList = listBsParameters;
        cLatexNameList = listBsParameterLatexNames;
        cUnitList = listBsParameterUnits;
        cScatterplotNameList = listBsParameterLatexScatterplotNames;
end
iParameter = find(strcmp(cParamList,cParameter));
cNameString = char(cLatexNameList(iParameter));
cScatterplotName = char(cScatterplotNameList(iParameter));
cUnit = char(cUnitList(iParameter));


%% Load scatterplot data
fromRefData = Results.(patientId).(cMode).FromRef.(cSignal).ScatterplotData.(cParameter);
toRefData   = Results.(patientId).(cMode).ToRef.(cSignal).ScatterplotData.(cParameter);
refInterval = Results.(patientId).(cMode).refInterval;

%% Convert to percentage values
fromRefData(:,3) = 100*fromRefData(:,3);
toRefData(:,3) = 100*toRefData(:,3);

%% Create scatterplot
figure;
hold on;
grid on;
box on;
grid minor;
p1 = plot(fromRefData(:,1),fromRefData(:,3),'rx');
p2 = plot(toRefData(:,1),toRefData(:,3),'bo');
plot([-500 500],[0 0],'k:');
p3 = plot(refInterval,0,'ks');

%% Find outliers in plot (more than 1.5 or less than 0.5 change)
% and mark them in plot

% value higher than margin to display (marked with ^)
outlierIndices = find(fromRefData(:,3) > yLimit(2));
if isempty(outlierIndices)
    p7 = plot(1000,1000,'^k','MarkerSize',4);
else
    p7 = plot(fromRefData(outlierIndices,1),yLimit(2),'^k','MarkerSize',4);
end
outlierIndices = find(toRefData(:,3) > yLimit(2));
if isempty(outlierIndices)
else
    plot(toRefData(outlierIndices,1),yLimit(2),'^k','MarkerSize',4);
end

% value lower than margin to display (marked with v)
outlierIndices = find(fromRefData(:,3) < yLimit(1));
if isempty(outlierIndices)
    p8 = plot(1000,1000,'vk','MarkerSize',4);
else
    p8 = plot(fromRefData(outlierIndices,1),yLimit(1),'vk','MarkerSize',4);
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
    p4 = plot(xReg,yReg,'r-.', 'LineWidth', 1);
end
% for ToRef values
if length(toRefData(:,3)) > 3
    [ xReg, yReg, rSquaredToRef, ~] = ...
        calculateRegression( toRefData(:,1), toRefData(:,3) );
    p5 = plot(xReg,yReg,'b-.', 'LineWidth', 1);
end
% for combined values
if length(toRefData(:,3)) +  length(fromRefData(:,3)) > 3
    [ xReg, yReg, rSquared, ~] = ...
        calculateRegression( [ toRefData(:,1) ; fromRefData(:,1) ],...
        [ toRefData(:,3) ; fromRefData(:,3) ]);
    p6 = plot(xReg,yReg,'g-', 'LineWidth', 1.5);
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
    title({['\fontsize{9}' cNameString] ['\rm R^2 = N/A']});
else
    title({['\fontsize{9}' cScatterplotName ] [' über dem ' cMode '-Intervall'] ['\rm R^2 = ' num2str(rSquared,'%1.3f')]});
end

%% Define axis labels
xlabel(['\fontsize{9}' cMode '-Interval (ms)']);
ylabel({['\fontsize{9} \bf' cScatterplotName] ['\rm bzgl. Referenzwert (in %)'] ['Signal: \bf PPG_{Clip}']});

%% Insert a legend
if legendOutliers
plotLegend = legend([p1, p2, p3, p4, p5, p6, p7(1), p8(1)],...
    'Übergang: Referenz \rightarrow Testintervall',...
    'Übergang: Testintervall \rightarrow Referenz',...
    'Keine Änderung (0) für Referenzintervall',...
    'Regression für Übergang: Referenz \rightarrow Testintervall',...
    'Regression für Übergang: Testintervall \rightarrow Referenz',...
    'Regression über alle Datenpunkte',...
    'Datenpunkte oberhalb des Diagrammausschnitts',...
    'Datenpunkte unterhalb des Diagrammausschnitts');
else
    plotLegend = legend([p1, p2, p3, p4, p5, p6],...
    'Übergang: Referenz \rightarrow Testintervall',...
    'Übergang: Testintervall \rightarrow Referenz',...
    'Keine Änderung (0) für Referenzintervall',...
    'Regression für Übergang: Referenz \rightarrow Testintervall',...
    'Regression für Übergang: Testintervall \rightarrow Referenz',...
    'Regression über alle Datenpunkte');

end
% plotLegend.Units = 'pixels';
plotLegend.Location = 'southoutside';
plotLegend.FontSize = 8;

%% Print figure to file
set(gcf, 'PaperPosition', [0.1 -0.8 9 14]);
set(gcf, 'PaperSize', [8.7 13.3]);
print(gcf, ['../results/plots/Scatterplots/SingleScatterplot' patientId '_' cMode '_' cParameter '_' cSignal '_EX' num2str(EXCLUDEBEATS) 'MAX' num2str(MAXBEATS)], '-dpdf', '-r600');
close(gcf);