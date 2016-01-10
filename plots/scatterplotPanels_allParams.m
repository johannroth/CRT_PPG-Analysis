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
yLimit = [-50 50];

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
nModes = length(listStimModes);
listSignals = [{'PpgClip'},{'PpgCuff'},{'BsBp'}];

%% Loop through all patients (1:6) and Modes (AV and VV)

for iPatient = 1:nPatients
    for iMode = 1:nModes
        cMode = char(listStimModes(iMode));
        %% Create panel with subplots
        patientId = ['Pt0' num2str(patient(iPatient))];
        figure;
        subplot1(3,6,'Gap',[0.01 0.05],'XTickL','Margin','YTickL','Margin');
        
        %% Loop through all parameters to create subplots
        % first row: PpgClip parameters
        cSignal = 'PpgClip';
        for iParameter = 1:nParameters
            cParameter = char(listParameters{iParameter});
            cNameString = char(listParameterLatexNames{iParameter});
            subplot1(iParameter);
            singleScatterplotForPanel;
        end
        
        cSignal = 'PpgCuff';
        for iParameter = 1:nParameters
            cParameter = char(listParameters{iParameter});
            cNameString = char(listParameterLatexNames{iParameter});
            subplot1(6+iParameter);
            singleScatterplotForPanel;
        end
        
        cSignal = 'BsBp';
        for iParameter = 1:nBsParameters
            cParameter = char(listBsParameters{iParameter});
            cNameString = char(listBsParameterLatexNames{iParameter});
            subplot1(12+iParameter);
            singleScatterplotForPanel;
            xlabel(['\fontsize{8}' cMode '-Interval (ms)']);
        end
        
        %% Insert labels for y-axis
        
        subplot1(1);
        ylabel({['\fontsize{8}' 'Änderung des Parameters'] ['bzgl. Referenzwert (in %)'] ['Signal: \bf PPG_{Clip}']});
        subplot1(6+1);
        ylabel({['\fontsize{8}' 'Änderung des Parameters'] ['bzgl. Referenzwert (in %)'] ['Signal: \bf PPG_{Cuff}']});
        subplot1(12+1);
        ylabel({['\fontsize{8}' 'Änderung des Parameters'] ['bzgl. Referenzwert (in %)'] ['Signal: \bf BP']});
        
        %% Insert Title for the figure
        subplot1(2);
        text(0,1.23,...
            ['\fontsize{14} Patient ' num2str(patient(iPatient)) ' (Variation des ' cMode '-Intervalls)'],...
            'Clipping','off',...
            'Fontweight','bold',...
            'Units','normalized');
        
        
        %% Print figure to file
        set(gcf, 'PaperPosition', [0.25 -1.1 20 25]);
        set(gcf, 'PaperSize', [19.4 23.2]);
        print(gcf, ['../results/plots/Scatterplots/Scatterplots_' patientId '_' cMode '_EX' num2str(EXCLUDEBEATS) 'MAX' num2str(MAXBEATS)], '-dpdf', '-r600');
        close(gcf);
        
    end
end
