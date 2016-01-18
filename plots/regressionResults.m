% This script creates plots to give an overview over quality of calculated
% regression parabolas.
%
% rSquared plot is saved to: ../results/plots/rSquaredEX#MAX#.pdf
% change span plot is saved to: ../results/plots/changeSpanEX#MAX#.pdf
%
% path of main.m has to be current matlab folder!
%
% Author: Johann Roth
% Date: 06.01.2016


EXCLUDEBEATS = 3;
MAXBEATS = 8;

Results = load(['../results/matlab/Results_MAX' num2str(MAXBEATS) '_EX' num2str(EXCLUDEBEATS) '.mat']);

maxChangeSpan = 0;
minChangeSpan = 0;
% threshold for rSquared value to calculate changespan.
changeSpanThreshold = 0.3;

listParameters = Results.Info.parameters;
listBsParameters = Results.Info.bsParameters;
listParameterLatexNames = Results.Info.parameterLatexNames;
listBsParameterLatexNames = Results.Info.bsParameterLatexNames;
nParameters = length(listParameters);
nBsParameters = length(listBsParameters);
patient = 1:6;
nPatients = length(patient);

listStimModes = [{'AV'},{'VV'}];

% Cell array to save ax handles of subplots
rSquaresAx = cell(1,2);
changeSpanAx = cell(1,2);

rSquaresFigure = figure;
changeSpanFigure = figure;

%% Create cell array containing rSquared values (AV, FromRef AND ToRef, PPGClip)
for iMode = 1:length(listStimModes)
    cMode = char(listStimModes(iMode));
    
    rSquaredTable = cell(2*nParameters + nBsParameters + 1, nPatients + 1);
    changeSpan = zeros(2*nParameters + nBsParameters, nPatients);
    
    for iPatient = 1:nPatients                      % Pt01 / ... / Pt06
        patientId = ['Pt0' num2str(patient(iPatient))];
        rSquaredTable{1,iPatient+1} = ['Pt. ' num2str(patient(iPatient))];
        %% Loop through PPG-parameters (Clip signal)
        for iParameter = 1:nParameters
            cParameter = char(listParameters(iParameter));
            cParameterLatexName = char(listParameterLatexNames(iParameter));
            rSquaredTable{1+iParameter,1} = [cParameterLatexName ' (Clip)'];
            fromRefScatterplotData = Results.(patientId).(cMode).FromRef.('PpgClip').ScatterplotData.(cParameter);
            toRefScatterplotData = Results.(patientId).(cMode).ToRef.('PpgClip').ScatterplotData.(cParameter);
            scatterplotData = [fromRefScatterplotData; toRefScatterplotData];
            if isempty(scatterplotData)
                rSquaredTable{1+iParameter,iPatient + 1} = 0;
                changeSpan(iParameter,iPatient) = 0;
            else
                x = scatterplotData(:,1);
                y = scatterplotData(:,3);
                [~,yReg,rSquared,quadraticCoeff] = calculateRegression(x,y);
                rSquaredTable{1+iParameter,iPatient + 1} = rSquared;
                %% If rSquared value is over a certain value, the span of percentual change is saved
                if rSquared > changeSpanThreshold
                    [maxChange, ~] = max(yReg);
                    [minChange, ~] = min(yReg);
                    cChangeSpan = 100*(maxChange-minChange);
                    %% changeSpan is always positive so far (maximum
                    % change and mimimum change are percentage values from
                    % 0 to inf)
                    %% Sign of changeSpan is to show the direction
                    % of the parabola (positive -> max in the middle,
                    % negative -> min in the middle)
                    if quadraticCoeff(1) > 0
                        cChangeSpan = -cChangeSpan;
                    end                    
                    changeSpan(iParameter,iPatient) = cChangeSpan;
                else
                    changeSpan(iParameter,iPatient) = 0;
                end
            end
        end
        %% Loop through PPG-parameters (Cuff signal)
        for iParameter = 1:nParameters
            cParameter = char(listParameters(iParameter));
            cParameterLatexName = char(listParameterLatexNames(iParameter));
            rSquaredTable{1+nParameters+iParameter,1} = [cParameterLatexName ' (Cuff)'];
            fromRefScatterplotData = Results.(patientId).(cMode).FromRef.('PpgCuff').ScatterplotData.(cParameter);
            toRefScatterplotData = Results.(patientId).(cMode).ToRef.('PpgCuff').ScatterplotData.(cParameter);
            scatterplotData = [fromRefScatterplotData; toRefScatterplotData];
            if isempty(scatterplotData)
                rSquaredTable{1+nParameters+iParameter,iPatient + 1} = 0;
                changeSpan(nParameters+iParameter,iPatient) = 0;
            else
                x = scatterplotData(:,1);
                y = scatterplotData(:,3);
                [~,yReg,rSquared,quadraticCoeff] = calculateRegression(x,y);
                rSquaredTable{1+nParameters+iParameter,iPatient + 1} = rSquared;
                %% If rSquared value is over a certain value, the span of percentual change is saved
                if rSquared > changeSpanThreshold
                    [maxChange, ~] = max(yReg);
                    [minChange, ~] = min(yReg);
                    cChangeSpan = 100*(maxChange-minChange);
                    %% changeSpan is always positive so far (maximum
                    % change and mimimum change are percentage values from
                    % 0 to inf)
                    %% Sign of changeSpan is to show the direction
                    % of the parabola (positive -> max in the middle,
                    % negative -> min in the middle)
                    if quadraticCoeff(1) > 0
                        cChangeSpan = -cChangeSpan;
                    end
                    
                    changeSpan(nParameters+iParameter,iPatient) = cChangeSpan;
                else
                    changeSpan(nParameters+iParameter,iPatient) = 0;
                end
            end
        end
        %% Loop through BeatScope parameters
        for iParameter = 1:nBsParameters
            cParameter = char(listBsParameters(iParameter));
            cParameterLatexName = char(listBsParameterLatexNames(iParameter));
            rSquaredTable{1+2*nParameters+iParameter,1} = [cParameterLatexName ' (BP)'];
            fromRefScatterplotData = Results.(patientId).(cMode).FromRef.BsBp.ScatterplotData.(cParameter);
            toRefScatterplotData = Results.(patientId).(cMode).ToRef.BsBp.ScatterplotData.(cParameter);
            scatterplotData = [fromRefScatterplotData; toRefScatterplotData];
            if isempty(scatterplotData)
                rSquaredTable{1+2*nParameters+iParameter,iPatient + 1} = 0;
                changeSpan(2*nParameters + iParameter,iPatient) = 0;
            else
                x = scatterplotData(:,1);
                y = scatterplotData(:,3);
                [~,yReg,rSquared,~] = calculateRegression(x,y);
                rSquaredTable{1+2*nParameters+iParameter,iPatient + 1} = rSquared;
                %% If rSquared value is over 50%, the span of percentual change is saved
                if rSquared > changeSpanThreshold
                    [maxChange,  iMax] = max(yReg);
                    [minChange, iMin] = min(yReg);
                    % abs, 100 times and minus 1 to convert to percentual
                    % change.
                    cChangeSpan = 100*(maxChange-minChange);
                    %% changeSpan is always positive so far (maximum
                    % change and mimimum change are percentage values from
                    % 0 to inf)
                    %% Sign of changeSpan is to show the direction
                    % of the parabola (positive -> max in the middle,
                    % negative -> min in the middle)
                    
                    if (iMax == 1) || (iMax == length(yReg))
                        % Maximum is either first or last available
                        % sample of parabola
                        % Minimum thus has to be in the middle
                        cChangeSpan = -cChangeSpan;
                    end
                    
                    changeSpan(2*nParameters + iParameter,iPatient) = cChangeSpan;
                else
                    changeSpan(2*nParameters + iParameter,iPatient) = 0;
                end
            end
        end
    end
    %% create subplot of rSquares HeatMap
    
    rSquares = cell2mat(rSquaredTable(2:end,2:end));
    set(groot,'CurrentFigure',rSquaresFigure);
    subplot(1,2,iMode);
    rSquaresAx{1,iMode} = gca;
    imagesc(rSquares);
    colormap hot;
    if iMode == 1   % left diagram
        ylabel('Parameter');
        parameterList = rSquaredTable(2:end,1);
        set(gca,'YtickLabel', parameterList);
        set(gca,'YTick', 1:length(parameterList));
    else            % right diagram
        c = colorbar;
        c.Label.String = '\it R^2\rm-Wert der quadratischen Regression';
        set(gca,'YtickLabel', []);
        set(gca,'YTick', 1:length(parameterList));
    end
    
    xlabel('Patient');
    set(gca,'XTick', 1:length(patient));
    caxis([0 1]);
    title({[cMode]});
    %% create subplot of change span HeatMap
    
    set(groot,'CurrentFigure',changeSpanFigure);
    subplot(1,2,iMode);
    changeSpanAx{1,iMode} = gca;

    maxChangeSpan = max(maxChangeSpan, ceil(max(changeSpan(:))));
    minChangeSpan = min(minChangeSpan, ceil(min(changeSpan(:))));
    imagesc(changeSpan);
    

%     colormap(flipud(hot));
%     colormap(hot);
    
    if iMode == 1   % left diagram (AV)
        ylabel('Parameter');
        parameterList = rSquaredTable(2:end,1);
        set(gca,'YtickLabel', parameterList);
        set(gca,'YTick', 1:length(parameterList));
    else            % right diagram
        c = colorbar;
        c.Label.String = 'Änderungsspanne der Parameter in Prozentpunkten';
        set(gca,'YtickLabel', []);
        set(gca,'YTick', 1:length(parameterList));
    end
    
    xlabel('Patient');
    set(gca,'XTick', 1:length(patient));
    title({[cMode]});
    
end

%% Adjust rSquares heatmap plot
set(groot,'CurrentFigure',rSquaresFigure);
set(rSquaresAx{1}, 'Position', [0.3 0.1 0.2 0.8]);
set(rSquaresAx{2}, 'Position', [0.53 0.1 0.2 0.8]);
% and print it
set(gcf, 'PaperPosition', [0.5 0.3 12 10]);
set(gcf, 'PaperSize', [11.2 10]);
print(gcf, ['../results/plots/rSquared' 'EX' num2str(EXCLUDEBEATS) 'MAX' num2str(MAXBEATS)], '-dpdf', '-r600');
close(rSquaresFigure);

%% Adjust changeSpan heatmap plot
set(groot,'CurrentFigure',changeSpanFigure);

set(changeSpanAx{1}, 'Position', [0.3 0.1 0.2 0.8]);
set(changeSpanAx{2}, 'Position', [0.53 0.1 0.2 0.8]);
if minChangeSpan == maxChangeSpan
    maxChangeSpan = minChangeSpan + 10;
end
% set(changeSpanAx{1}, 'CLim', [minChangeSpan maxChangeSpan]);
% set(changeSpanAx{2}, 'Clim', [minChangeSpan maxChangeSpan]);
changeSpanMax = max(abs([minChangeSpan maxChangeSpan]));
set(changeSpanAx{1}, 'CLim', [-changeSpanMax changeSpanMax]);
set(changeSpanAx{2}, 'Clim', [-changeSpanMax changeSpanMax]);
colormap(bluewhitered);

% and print it
set(gcf, 'PaperPosition', [0.5 0.3 12 10]);
set(gcf, 'PaperSize', [11.2 10]);
print(gcf, ['../results/plots/changeSpan' 'EX' num2str(EXCLUDEBEATS) 'MAX' num2str(MAXBEATS)], '-dpdf', '-r600');
close(changeSpanFigure);