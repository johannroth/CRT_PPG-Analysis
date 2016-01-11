%% This script creates a plot for visualisation of a good signal
% and corresponding calculated parameters
%
% plot is saved to ../results/plots/signalBadExample.pdf
%
% path of main.m has to be current matlab folder!
%
% Author: Johann Roth
% Date: 11.01.2016

EXCLUDEBEATS = 0;
MAXBEATS = 8;

iPatient = 2;
patientId = ['Pt0' num2str(iPatient)];

Results = load(['../results/matlab/Results_MAX' num2str(MAXBEATS) '_EX' num2str(EXCLUDEBEATS) '.mat']);
Metadata = importPatientMetadata('..\data\raw\Patient_data.xlsx');

%% Good example
% Pt 04 1:06 - 2:53
% First part for good signal, no error in annotations, second part with
% error in annotation (as example)


%% Part of the signal
% Example for good signal
Data = load(['../data/matlab/' patientId '/' patientId '_processedDataStruct.mat']);
fs = Data.fs;

minuteStart = 1;
secondStart = 7;
minuteEnd = 2;
secondEnd = 3;
signalStart = fs * (60 * minuteStart + secondStart);
signalEnd = fs * (60 * minuteEnd + secondEnd);

%% Signals
ppgClip = Data.Signals.PpgClip.data();
ppgCuff = Data.Signals.PpgCuff.data();
bp = Data.Signals.Bp.data();

t = 0/fs:1/fs:(length(bp)-1)/fs;
tStart = signalStart/fs;
tEnd = signalEnd/fs;

%% AV intervals
intervalStamps = Data.StimulationModes.AV.samplestamp;
intervalValues = Data.StimulationModes.AV.value;
intervalStamps = (intervalStamps-1)/fs;

%% StrokeVolume from Beatscope
strokeVolume = Data.BsValues.StrokeVolume.value;
strokeVolumeStamps = Data.BsValues.StrokeVolume.samplestamp;
strokeVolumeStamps = (strokeVolumeStamps-1)/fs;

%% Pulsearea calculated from PPG
changeStamps = [Results.(patientId).AV.FromRef.stamps(:); ...
    Results.(patientId).AV.ToRef.stamps(:)];
% for each change there is one value before and one value after the change.
% the value will be plotted in the middle of the amount of beats included
% to calculation
heartRate = Metadata.heartRate(iPatient);
beatLength = 60/heartRate * fs;
changeStampsBefore = changeStamps - beatLength * round((MAXBEATS-EXCLUDEBEATS)/2);
changeStampsBefore = (changeStampsBefore-1)/fs;
changeStampsAfter = changeStamps + beatLength * round((MAXBEATS-EXCLUDEBEATS)/2);
changeStampsAfter = (changeStampsAfter-1)/fs;
pulseAreaStamps = [ changeStampsBefore changeStampsAfter ];



pulseAreaBeforeFromRef = Results.(patientId).AV.FromRef.PpgClip.pulseArea(:,1,:);
pulseAreaBeforeToRef = Results.(patientId).AV.ToRef.PpgClip.pulseArea(:,1,:);
pulseAreaBefore = [pulseAreaBeforeFromRef(:); pulseAreaBeforeToRef(:)];
pulseAreaAfterFromRef = Results.(patientId).AV.FromRef.PpgClip.pulseArea(:,2,:);
pulseAreaAfterToRef = Results.(patientId).AV.ToRef.PpgClip.pulseArea(:,2,:);
pulseAreaAfter = [pulseAreaAfterFromRef(:); pulseAreaAfterToRef(:)];

pulseArea = [ pulseAreaBefore  pulseAreaAfter ];


%% Create figure with subplots
figure;
subplot(5,1,1);
[hAx1,hLine1,hLine2] = plotyy(t,ppgClip,intervalStamps,intervalValues,...
    'plot', 'stairs');
ylabel(hAx1(1),'PPG_{Clip} (a.u.)','FontSize',9);
ylabel(hAx1(2),'AV-interval (ms)','FontSize',9);
set(hAx1(1),'XLim',[tStart tEnd]);
set(hAx1(2),'XLim',[tStart tEnd]);
set(hAx1(1),'YLim',[-30 30]);
set(hAx1(2),'YLim',[0 160]);
set(hAx1(1),'YTick',-30:15:80);
set(hAx1(2),'YTick',0:40:400);
set(hAx1(1),'YColor','k');
set(hAx1(2),'YColor','b');
set(hLine2,'LineWidth',1);
set(hLine2,'LineStyle','--');
set(hLine1,'Color','k');
set(hLine2,'Color','b');
grid on;
grid minor;

title({['Signalausschnitt Patient ' num2str(iPatient)] [' ']});

subplot(5,1,2);
[hAx2,hLine1,hLine2] = plotyy(t,ppgCuff,intervalStamps,intervalValues,...
    'plot', 'stairs');
ylabel(hAx2(1),'PPG_{Cuff} (a.u.)','FontSize',9);
ylabel(hAx2(2),'AV-interval (ms)','FontSize',9);
set(hAx2(1),'XLim',[tStart tEnd]);
set(hAx2(2),'XLim',[tStart tEnd]);
set(hAx2(1),'YLim',[-40 40]);
set(hAx2(2),'YLim',[0 160]);
set(hAx2(1),'YTick',-40:20:80);
set(hAx2(2),'YTick',0:40:400);
set(hAx2(1),'YColor','k');
set(hAx2(2),'YColor','b');
set(hLine2,'LineWidth',1);
set(hLine2,'LineStyle','--');
set(hLine1,'Color','k');
set(hLine2,'Color','b');
grid on;
grid minor;

subplot(5,1,3);
[hAx3,hLine1,hLine2] = plotyy(t,bp,intervalStamps,intervalValues,...
    'plot', 'stairs');
ylabel(hAx3(1),'BP (mmHg)','FontSize',9);
ylabel(hAx3(2),'AV-interval (ms)','FontSize',9);
set(hAx3(1),'XLim',[tStart tEnd]);
set(hAx3(2),'XLim',[tStart tEnd]);
set(hAx3(1),'YLim',[20 180]);
set(hAx3(2),'YLim',[0 160]);
set(hAx3(1),'YTick',20:40:200);
set(hAx3(2),'YTick',0:40:400);
set(hAx3(1),'YColor','k');
set(hAx3(2),'YColor','b');
set(hLine2,'LineWidth',1);
set(hLine2,'LineStyle','--');
set(hLine1,'Color','k');
set(hLine2,'Color','b');
grid on;
grid minor;

subplot(5,1,4);
[hAx4,hLine1,hLine2] = plotyy(strokeVolumeStamps,strokeVolume,...
    intervalStamps,intervalValues,...
    'stairs', 'stairs');
ylabel(hAx4(1),'HSV (ml)','FontSize',9);
ylabel(hAx4(2),'AV-interval (ms)','FontSize',9);
set(hAx4(1),'XLim',[tStart tEnd]);
set(hAx4(2),'XLim',[tStart tEnd]);
set(hAx4(1),'YLim',[115 155]);
set(hAx4(2),'YLim',[0 160]);
set(hAx4(1),'YTick',5:10:205);
set(hAx4(2),'YTick',0:40:400);
set(hAx4(1),'YColor','k');
set(hAx4(2),'YColor','b');
set(hLine1,'LineWidth',1);
set(hLine2,'LineWidth',1);
set(hLine2,'LineStyle','--');
set(hLine1,'Color','k');
set(hLine2,'Color','b');
grid on;
grid minor;

subplot(5,1,5);
[hAx5,hLine1,hLine2] = plotyy(pulseAreaStamps',pulseArea',...
    intervalStamps,intervalValues,...
    'plot', 'stairs');
ylabel(hAx5(1),'Pulsfläche (a.u.)','FontSize',9);
ylabel(hAx5(2),'AV-interval (ms)','FontSize',9);
set(hAx5(1),'XLim',[tStart tEnd]);
set(hAx5(2),'XLim',[tStart tEnd]);
set(hAx5(1),'YLim',[1000 1400]);
set(hAx5(2),'YLim',[0 160]);
set(hAx5(1),'YTick',200:100:4000);
set(hAx5(2),'YTick',0:40:400);
set(hAx5(1),'YColor','k');
set(hAx5(2),'YColor','b');
set(hLine1,'LineWidth',1);
set(hLine2,'LineWidth',1);
set(hLine2,'LineStyle','--');
set(hLine1,'LineStyle','-.');
set(hLine1,'Marker','s');
set(hLine1,'Color','k');
set(hLine2,'Color','b');
xlabel('Zeit (s)','FontSize',9);
grid on;
grid minor;

linkaxes([hAx1 hAx2 hAx3 hAx4 hAx5],'x');

%% Print figure to file
set(gcf, 'PaperPosition', [0 -0.5 12 16]);
set(gcf, 'PaperSize', [12.5 15.5]);
print(gcf, ['../results/plots/signalBadExample'], '-dpdf', '-r600');
close(gcf);
