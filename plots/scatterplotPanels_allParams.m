% This script creates a total of 12 figures with plots for each Mode and
% Patient displaying scatterplots and regression curves for all 18
% parameters
%
% rSquared plot is saved to: ....
%
% path of main.m has to be current matlab folder!
%
% Author: Johann Roth
% Date: 08.01.2016

%% Parameters and data import
EXCLUDEBEATS = 0;
MAXBEATS = 8;

% Limits for scatterplots
yLimit = [0.5 1.5];

%% Data import
Results = load(['../results/matlab/Results_MAX' num2str(MAXBEATS) '_EX' num2str(EXCLUDEBEATS) '.mat']);

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


%% Create panel with subplots

%example for one plot
cMode = 'AV';
iPatient = 4;
patientId = ['Pt0' num2str(patient(iPatient))];
figure;
subplot1(3,6);

%% Loop through all parameters
% first row: PpgClip parameters
cSignal = 'PpgClip';
for iParameter = 1:nParameters
    cParameter = char(listParameters{iParameter});
    subplot1(iParameter);
    singleScatterplotForPanel;
end

cSignal = 'PpgCuff';
for iParameter = 1:nParameters
    cParameter = char(listParameters{iParameter});
    subplot1(6+iParameter);
    singleScatterplotForPanel;
end

cSignal = 'BsBp';
for iParameter = 1:nBsParameters
    cParameter = char(listBsParameters{iParameter});
    subplot1(12+iParameter);
    singleScatterplotForPanel;
end

