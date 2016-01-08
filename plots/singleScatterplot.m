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
yLimit = [0.5 1.5];

Results = load(['../results/matlab/Results_MAX' num2str(MAXBEATS) '_EX' num2str(EXCLUDEBEATS) '.mat']);

%% Selected parameter, mode, signal and patient
cPatient = 4;
cMode = 'AV';
cSignal = 'PpgCuff';
cParameter = 'pulseArea';

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

%% Load scatterplot data
fromRefData = Results.(patientId).(cMode).FromRef.(cSignal).ScatterplotData.(cParameter);
toRefData   = Results.(patientId).(cMode).ToRef.(cSignal).ScatterplotData.(cParameter);
refInterval = Results.(patientId).(cMode).refInterval;

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
cLatexName = char(cLatexNameList(iParameter));
cScatterplotName = char(cScatterplotNameList(iParameter));
cUnit = char(cUnitList(iParameter));

%% Create scatterplot
figure;
hold on;
grid on;
plot(fromRefData(:,1),fromRefData(:,3),'rx');
plot(toRefData(:,1),toRefData(:,3),'bo');
plot([-500 500],[1 1],'k:');
plot(refInterval,1,'ks');

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
[ xReg, yReg, rSquaredFromRef, ~] = ...
    calculateRegression( fromRefData(:,1), fromRefData(:,3) );
plot(xReg,yReg,'r-.');
% for ToRef values
[ xReg, yReg, rSquaredToRef, ~] = ...
    calculateRegression( toRefData(:,1), toRefData(:,3) );
plot(xReg,yReg,'b-.');
% for combined values
[ xReg, yReg, rSquared, ~] = ...
    calculateRegression( [ toRefData(:,1) ; fromRefData(:,1) ],...
                         [ toRefData(:,3) ; fromRefData(:,3) ]);
plot(xReg,yReg,'g-', 'LineWidth', 1.5);

%% Put text for rSquared values in corner of plot
switch cMode
    case 'AV'
        xText = 350;
    case 'VV'
        xText = 100;
end
yText = yLimit(1)*1.05;
text(xText,yText,['R^2 = ' num2str(rSquared)], ...
    'VerticalAlignment','bottom',...
    'HorizontalAlignment','right');


%% Scaling depending on stimulation mode (AV or VV)
switch cMode
    case 'AV'
        axis([ 0 360 yLimit(1) yLimit(2)]);
    case 'VV'
        axis([ -100 100 yLimit(1) yLimit(2)]);
end

%% Labelling of axis
xlabel([cMode '-Interval (ms)']);
ylabel([cScatterplotName ' (' cUnit '/' cUnit ')']);
