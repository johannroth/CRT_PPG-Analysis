% This script creates a plot to give an overview over overall signal
% quality and over the amount of beats excluded by the beat evaluation
% algorithm.
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
Metadata = importPatientMetadata('..\data\raw\Patient_data.xlsx');

listSignals = [{'PpgClip'}, {'PpgCuff'}];
listModes = [{'AV'}, {'VV'}];
patient = 1:6;

nSignals = length(listSignals);
nModes = length(listModes);
nPatients = length(patient);

% Matrix to save qualities for both signals
meanQuality = zeros(nModes,nPatients,nSignals);

% Matrix to save axes handles for all subplots
ax = cell(nPatients,nModes);

figure('Units', 'pixels','OuterPosition',[0, 0, 600, 800]);
for iPatient = 1:nPatients
    patientId = ['Pt0' num2str(patient(iPatient))];
    for iMode = 1:nModes
        cMode = char(listModes(iMode));
        
        cSubplot = subplot(nPatients,nModes,(iPatient - 1) * nModes + iMode);
        cPos = get(cSubplot,'Position');
        set(cSubplot,'Position',[cPos(1) cPos(2) cPos(3)*0.9 cPos(4)*0.85]); % , 'Position', [0.13 0.11 0.775 0.815]
        grid on;
        hold on;
        box on;
        grid minor;
        ax{iPatient,iMode} = gca;
        
        for iSignal = 1:nSignals
            cSignal = char(listSignals(iSignal));
            % List of Intervals for current patient
            interval = Results.(patientId).(cMode).interval;
            % Initialize matrix of qualities for every interval (every column is an
            % interval)
            quality = zeros(3*2*2,length(interval));
            % Extract mean quality for every interval
            for iInterval = 1:length(interval)
                qualityValuesFromRef = Results.(patientId).(cMode).FromRef.(cSignal).quality(:,:,iInterval);
                qualityValuesToRef = Results.(patientId).(cMode).ToRef.(cSignal).quality(:,:,iInterval);
                qualityValues = [qualityValuesFromRef(:) ; qualityValuesToRef(:)];
                quality(:,iInterval) = qualityValues;
            end
            
            meanQuality(iMode, iPatient,iSignal) = 100*(1 - mean(quality(:)));
            
            if iSignal == 1     % Clip
                plot(interval, 100*(1-mean(quality)),'bs-.');
            else                % Cuff
                plot(interval, 100*(1-mean(quality)),'ro-.');
            end
            
            if iMode == 1       % AV
                axis([0, 360, 0, 50]);
                set(gca,'XTick',0:60:360);
                ylabel({['Patient ' num2str(patient(iPatient))] ['\fontsize{9pt} Ausgeschlossene'] ['\fontsize{9pt}Schläge (%)']});
                
                
            else                % VV
                axis([-100, 100, 0, 50]);
                set(gca,'XTick',-80:40:80);
                ylabel({['\fontsize{9pt} Ausgeschlossene'] ['\fontsize{9pt}Schläge (%)']});
                
                
            end
            xlabel(['\fontsize{9pt}' cMode '-Intervall (ms)']);
            set(gca,'YTick',0:10:100);
            
            
            
            
            
            
        end
        
    end
end

%% Display overall quality for each Signal
clipQuality = meanQuality(:,:,1);
cuffQuality = meanQuality(:,:,2);
fprintf(['Durchschnittlich aussortierte Schläge (über alle Patienten, Signal: Clip): ' num2str(mean(clipQuality(:))) ' Prozent\n']);
fprintf(['Durchschnittlich aussortierte Schläge (über alle Patienten, Signal: Cuff): ' num2str(mean(cuffQuality(:))) ' Prozent\n']);

% %% Adapt position of the legend
% plotLegend = legend(ax{6,2},'PPG_{Clip}','PPG_{Cuff}');
% plotLegend.Units = 'pixels';
% plotLegend.Position = [255,6,100,50];
%% Adapt position of the legend
plotLegend = legend('PPG-Fingerclip','PPG-Manschette');
plotLegend.FontSize = 8;
plotLegend.Units = 'centimeters';
plotLegend.Position = [6.5,0.5,0.8,0.3];
plotLegend.Orientation = 'horizontal';
plotLegend.Box = 'off';


%% Print to pdf
set(gcf, 'PaperPosition', [0.4 -0.3 14 20.5]);
set(gcf, 'PaperSize', [13 18.9]);
print(gcf, '../results/plots/qualityOverview', '-dpdf', '-r600'); % -painters for alternative renderer

%
% subplot(2,1,2);
% boxplot(quality,interval, 'color', 'k');
% % axis([-inf, inf, 0, 1]);
% % set(gca, axes
close(gcf);

