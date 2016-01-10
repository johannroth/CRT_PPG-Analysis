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

% Matrix to save axes handles for all subplots
ax = cell(nPatients,nModes);

figure('Units', 'pixels','OuterPosition',[0, 0, 600, 800]);
for iPatient = 1:nPatients
    patientId = ['Pt0' num2str(patient(iPatient))];
    for iMode = 1:nModes
        cMode = char(listModes(iMode));
        
        subplot(nPatients,nModes,(iPatient - 1) * nModes + iMode);
        grid on;
        hold on;
        box on;
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
            end
            if iPatient == 1     % first patient
                title([cMode '-Interval']);
            elseif iPatient == 6
                xlabel([cMode '-Intervall (ms)']);
            end
            set(gca,'YTick',0:10:100);
            
            
            %             title(['Patient ' num2str(patient(iPatient)) ' ' cMode]);
            
        end
        
    end
end

%% Adapt position of the legend
plotLegend = legend(ax{6,2},'PPG_{Clip}','PPG_{Cuff}');
plotLegend.Units = 'pixels';
plotLegend.Position = [255,6,100,50];


%% Print to pdf
set(gcf, 'PaperPosition', [0 0 15 20]);
set(gcf, 'PaperSize', [14 19.5]);
print(gcf, '../results/plots/qualityOverview', '-dpdf', '-r600'); % -painters for alternative renderer

%
% subplot(2,1,2);
% boxplot(quality,interval, 'color', 'k');
% % axis([-inf, inf, 0, 1]);
% % set(gca, axes
close(gcf);

