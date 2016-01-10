%% This script creates a plot for visualisation of mean waveforms
%
% plot for ppg clip is saved to ../results/plots/meanWaveform.pdf
%
% path of main.m has to be current matlab folder!
%
% Author: Johann Roth
% Date: 09.01.2016

% Results.Pt01.AV.FromRef.PpgClip

%% Parameters and data import
EXCLUDEBEATS = 0;
MAXBEATS = 8;

fs = 200;

Results = load(['../results/matlab/Results_MAX' num2str(MAXBEATS) '_EX' num2str(EXCLUDEBEATS) '.mat']);

patient = 1:6;
nPatients = length(patient);

iPatient = 1;
figure;
for iPatient = 1:nPatients
    patientId = ['Pt0' num2str(patient(iPatient))];
    %% Plot errorbar subplot
    subplot(3,2,iPatient);
    hold on;
    
    %% for Clip
    cSignal = 'PpgClip';
    AvFromRefBeats  = Results.(patientId).AV.FromRef.(cSignal).beats(:,1,:);
    AvToRefBeats    = Results.(patientId).AV.ToRef.(cSignal).beats(:,2,:);
    VvFromRefBeats  = Results.(patientId).VV.FromRef.(cSignal).beats(:,1,:);
    VvToRefBeats    = Results.(patientId).AV.ToRef.(cSignal).beats(:,2,:);
    
    cBeats = [  cell2mat(AvFromRefBeats(:)') ...
        cell2mat(AvToRefBeats(:)') ...
        cell2mat(VvFromRefBeats(:)') ...
        cell2mat(VvToRefBeats(:)') ];
    
    meanBeat = mean(cBeats,2);
    maxValue = max(meanBeat);
    meanBeat = meanBeat/maxValue;
    sdBeat = std(cBeats/maxValue,0,2);
    t = 0:1/fs:(size(cBeats,1)-1)/fs;
    errorbar(t(1:6:end)*1000,meanBeat(1:6:end),sdBeat(1:6:end),'LineWidth',1);
    
    %% for Cuff
    cSignal = 'PpgCuff';
    AvFromRefBeats  = Results.(patientId).AV.FromRef.(cSignal).beats(:,1,:);
    AvToRefBeats    = Results.(patientId).AV.ToRef.(cSignal).beats(:,2,:);
    VvFromRefBeats  = Results.(patientId).VV.FromRef.(cSignal).beats(:,1,:);
    VvToRefBeats    = Results.(patientId).AV.ToRef.(cSignal).beats(:,2,:);
    
    cBeats = [  cell2mat(AvFromRefBeats(:)') ...
        cell2mat(AvToRefBeats(:)') ...
        cell2mat(VvFromRefBeats(:)') ...
        cell2mat(VvToRefBeats(:)') ];
    
    meanBeat = mean(cBeats,2);
    maxValue = max(meanBeat);
    meanBeat = meanBeat/maxValue;
    sdBeat = std(cBeats/maxValue,0,2);
    t = 0:1/fs:(size(cBeats,1)-1)/fs;
    errorbar(t(4:6:end)*1000,meanBeat(4:6:end),sdBeat(4:6:end),'LineWidth',1);
    
    %% Adjust labels
    title(['Patient ' num2str(patient(iPatient))]);
    xlabel('Zeit (ms)');
    ylabel('Volumenpuls (a.u.)');

    axis([0 800 -0.1 1.5]);
    grid on;
    grid minor;
    box on;
    
    %% Insert Title for the whole panel figure at patient 1
    if iPatient == 1
        text(0.6,1.3,...
            {['\fontsize{12}Volumenpulsverläufe']},...
            'Clipping','off',...
            'Fontweight','bold',...
            'Units','normalized');
    end
end

%% Adapt position of the legend
plotLegend = legend('PPG-Clip','PPG-Manschette');
plotLegend.FontSize = 8;
plotLegend.Units = 'centimeters';
plotLegend.Position = [7.5,0.1,0.8,0.3];
plotLegend.Orientation = 'horizontal';
plotLegend.Box = 'off';

%% Print figure to file
set(gcf, 'PaperPosition', [-0.3 0 12 16]);
set(gcf, 'PaperSize', [11.1 16]);
print(gcf, ['../results/plots/meanWaveform'], '-dpdf', '-r600');
close(gcf);




