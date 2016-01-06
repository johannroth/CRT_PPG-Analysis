% This script creates plots to give an overview over quality of calculated
% regression parabolas.
%
% Plot is saved to: ../results/plots/qualityOverview.pdf
%
% path of main.m has to be current matlab folder!
%
% Author: Johann Roth
% Date: 06.01.2016


EXCLUDEBEATS = 0;
MAXBEATS = 8;

Results = load(['../results/matlab/Results_MAX' num2str(MAXBEATS) '_EX' num2str(EXCLUDEBEATS) '.mat']);

listParameters = Results.Info.parameters;
listBsParameters = Results.Info.bsParameters;
nParameters = length(listParameters);
nBsParameters = length(listBsParameters);
patient = 1:6;
nPatients = length(patient);

listStimModes = [{'AV'},{'VV'}];
relDelta = 3; % 3 for rel, 2 for delta

% Cell array to save ax handles of subplots
ax = cell(1,2);

figure;

%% Create cell array containing rSquared values (AV, FromRef AND ToRef, PPGClip)
for iMode = 1:length(listStimModes)
    cMode = char(listStimModes(iMode));
    
    rSquaredTable = cell(2*nParameters + nBsParameters + 1, nPatients + 1);
    for iPatient = 1:nPatients                      % Pt01 / ... / Pt06
        patientId = ['Pt0' num2str(patient(iPatient))];
        rSquaredTable{1,iPatient+1} = ['Pt. ' num2str(patient(iPatient))];
        % Loop through PPG-parameters
        for iParameter = 1:nParameters
            cParameter = char(listParameters(iParameter));
            rSquaredTable{1+iParameter,1} = [cParameter ' (Clip)'];
            fromRefScatterplotData = Results.(patientId).(cMode).FromRef.('PpgClip').ScatterplotData.(cParameter);
            toRefScatterplotData = Results.(patientId).(cMode).ToRef.('PpgClip').ScatterplotData.(cParameter);
            scatterplotData = [fromRefScatterplotData; toRefScatterplotData];
            if isempty(scatterplotData)
                rSquaredTable{1+iParameter,iPatient + 1} = 0;
            else
                x = scatterplotData(:,1);
                y = scatterplotData(:,relDelta);
                [~,~,rSquared,~] = calculateRegression(x,y);
                rSquaredTable{1+iParameter,iPatient + 1} = rSquared;
            end
        end
        for iParameter = 1:nParameters
            cParameter = char(listParameters(iParameter));
            rSquaredTable{1+nParameters+iParameter,1} = [cParameter ' (Cuff)'];
            fromRefScatterplotData = Results.(patientId).(cMode).FromRef.('PpgCuff').ScatterplotData.(cParameter);
            toRefScatterplotData = Results.(patientId).(cMode).ToRef.('PpgCuff').ScatterplotData.(cParameter);
            scatterplotData = [fromRefScatterplotData; toRefScatterplotData];
            if isempty(scatterplotData)
                rSquaredTable{1+nParameters+iParameter,iPatient + 1} = 0;
            else
                x = scatterplotData(:,1);
                y = scatterplotData(:,relDelta);
                [~,~,rSquared,~] = calculateRegression(x,y);
                rSquaredTable{1+nParameters+iParameter,iPatient + 1} = rSquared;
            end
        end
        % Loop through BeatScope parameters
        for iParameter = 1:nBsParameters
            cParameter = char(listBsParameters(iParameter));
            rSquaredTable{1+2*nParameters+iParameter,1} = [cParameter ' (Fino)'];
            fromRefScatterplotData = Results.(patientId).(cMode).FromRef.BsBp.ScatterplotData.(cParameter);
            toRefScatterplotData = Results.(patientId).(cMode).ToRef.BsBp.ScatterplotData.(cParameter);
            scatterplotData = [fromRefScatterplotData; toRefScatterplotData];
            if isempty(scatterplotData)
                rSquaredTable{1+2*nParameters+iParameter,iPatient + 1} = 0;
            else
                x = scatterplotData(:,1);
                y = scatterplotData(:,relDelta);
                [~,~,rSquared,~] = calculateRegression(x,y);
                rSquaredTable{1+2*nParameters+iParameter,iPatient + 1} = rSquared;
            end
        end
    end
    % create HeatMap for the table
    
    rSquares = cell2mat(rSquaredTable(2:end,2:end));
    subplot(1,2,iMode);
    ax{1,iMode} = gca;
    imagesc(rSquares);
    colormap hot;
    if iMode == 1   % left diagram
        ylabel('Parameter');
        parameterList = rSquaredTable(2:end,1);
        set(gca,'YtickLabel', parameterList);
        set(gca,'YTick', 1:length(parameterList));
    else            % right diagram
        c = colorbar;
        c.Label.String = 'R^2-Wert der quadratischen Regression';
        set(gca,'YtickLabel', []);
    end
    
    xlabel('Patient');
    set(gca,'XTick', 1:length(patient));
    caxis([0 1]);
    title({[cMode '-Intervall']});
    
    %    set(gcf, 'PaperPosition', [0 0 10 15]);
    %    set(gcf, 'PaperSize', [10 15]);
    %    print(gcf, ['../results/plots/rSquared' cMode 'EX' num2str(EXCLUDEBEATS) 'MAX' num2str(MAXBEATS)], '-dpdf', '-r600');
end
pos1 = get(ax{1}, 'Position');
pos2 = get(ax{2}, 'Position');
set(ax{1}, 'Position', [0.3 0.1 0.2 0.8]);
set(ax{2}, 'Position', [0.53 0.1 0.2 0.8]);


