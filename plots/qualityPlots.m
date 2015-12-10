function [ ] = qualityPlots( Data, Metadata, Results, iPatient, MAXBEATS, EXCLUDEBEATS )
%QUALITYPLOTS creates and saves plots to verify quality of beat detection
% and beat selection
%   Detailed explanation goes here
%
% Author: Johann Roth
% Date: 10.12.2015

patientId = ['Pt0' num2str(iPatient)];
fs = Data.fs;


%% Clip Before change AV plots
interval = Results.(patientId).AV.interval;
nIntervals = length(interval);
nChanges = 3;
nDirections = 2; % (fromRef and toRef)
direction = [{'FromRef'},{'ToRef'}];

qualityPlot = figure('Visible', 'off');
for iInterval = 1:nIntervals
    for iChange = 1:nChanges
        for iDirection = 1:nDirections
            currentDirection = char(direction(iDirection));
            
            plotNumber = (iInterval-1)*nChanges*nDirections + (iChange-1)*nDirections + iDirection;
            subplot(nIntervals,nChanges*nDirections,plotNumber);
            beat = Results.(patientId).AV.(currentDirection).PpgClip.beats{iChange,1,iInterval};
            quality = Results.(patientId).AV.(currentDirection).PpgClip.quality(iChange,1,iInterval);

            t = 0:1/fs:(length(beat)-1)/fs;

            beatMean = mean(beat,2);
            beatSd = std(beat,0,2);

            errorbar(t(1:2:end),beatMean(1:2:end),beatSd(1:2:end));
            axis([0,0.7,-inf,inf]);
            leftText = {['AV ' num2str(interval(iInterval))],...
                ['C = ' num2str(iChange)],...
                currentDirection};
            rightText = ['Q = ' num2str(quality,2)];
            text(0,max(beatMean)*0.8, leftText , 'HorizontalAlignment','left');
            text(t(end)*0.9,max(beatMean)*0.9, rightText , 'HorizontalAlignment','right');

            set(gca,'position',get(gca,'position').*[1 1 1.2 1.2])
            axis off;
        end
    end
end
set(qualityPlot,'units','normalized','outerposition',[0 0 1 1]);
set(qualityPlot,'PaperPositionMode','auto');
print(qualityPlot,...
    ['../results/plots/QualityPlotAV_' ...
    patientId '_Clip_EX' num2str(EXCLUDEBEATS) ...
    '_MAX' num2str(MAXBEATS) '_bC'],'-dpng','-r0');
% savefig(qualityPlot,'QualityPlot.fig');
close(qualityPlot);
%% Clip After change AV plots
interval = Results.(patientId).AV.interval;
nIntervals = length(interval);
nChanges = 3;
nDirections = 2; % (fromRef and toRef)
direction = [{'FromRef'},{'ToRef'}];

qualityPlot = figure('Visible', 'off');
for iInterval = 1:nIntervals
    for iChange = 1:nChanges
        for iDirection = 1:nDirections
            currentDirection = char(direction(iDirection));
            
            plotNumber = (iInterval-1)*nChanges*nDirections + (iChange-1)*nDirections + iDirection;
            subplot(nIntervals,nChanges*nDirections,plotNumber);
            beat = Results.(patientId).AV.(currentDirection).PpgClip.beats{iChange,2,iInterval};
            quality = Results.(patientId).AV.(currentDirection).PpgClip.quality(iChange,2,iInterval);

            t = 0:1/fs:(length(beat)-1)/fs;

            beatMean = mean(beat,2);
            beatSd = std(beat,0,2);

            errorbar(t(1:2:end),beatMean(1:2:end),beatSd(1:2:end));
            axis([0,0.7,-inf,inf]);
            leftText = {['AV ' num2str(interval(iInterval))],...
                ['C = ' num2str(iChange)],...
                currentDirection};
            rightText = ['Q = ' num2str(quality,2)];
            text(0,max(beatMean)*0.8, leftText , 'HorizontalAlignment','left');
            text(t(end)*0.9,max(beatMean)*0.9, rightText , 'HorizontalAlignment','right');

            set(gca,'position',get(gca,'position').*[1 1 1.2 1.2])
            axis off;
        end
    end
end
set(qualityPlot,'units','normalized','outerposition',[0 0 1 1]);
set(qualityPlot,'PaperPositionMode','auto');
print(qualityPlot,...
    ['../results/plots/QualityPlotAV_' ...
    patientId '_Clip_EX' num2str(EXCLUDEBEATS) ...
    '_MAX' num2str(MAXBEATS) '_aC'],'-dpng','-r0');
% savefig(qualityPlot,'QualityPlot.fig');
close(qualityPlot);
%% Clip Before change VV plots
interval = Results.(patientId).VV.interval;
nIntervals = length(interval);
nChanges = 3;
nDirections = 2; % (fromRef and toRef)
direction = [{'FromRef'},{'ToRef'}];

qualityPlot = figure('Visible', 'off');
for iInterval = 1:nIntervals
    for iChange = 1:nChanges
        for iDirection = 1:nDirections
            currentDirection = char(direction(iDirection));
            
            plotNumber = (iInterval-1)*nChanges*nDirections + (iChange-1)*nDirections + iDirection;
            subplot(nIntervals,nChanges*nDirections,plotNumber);
            beat = Results.(patientId).VV.(currentDirection).PpgClip.beats{iChange,1,iInterval};
            quality = Results.(patientId).VV.(currentDirection).PpgClip.quality(iChange,1,iInterval);

            t = 0:1/fs:(length(beat)-1)/fs;

            beatMean = mean(beat,2);
            beatSd = std(beat,0,2);

            errorbar(t(1:2:end),beatMean(1:2:end),beatSd(1:2:end));
            axis([0,0.7,-inf,inf]);
            leftText = {['VV ' num2str(interval(iInterval))],...
                ['C = ' num2str(iChange)],...
                currentDirection};
            rightText = ['Q = ' num2str(quality,2)];
            text(0,max(beatMean)*0.8, leftText , 'HorizontalAlignment','left');
            text(t(end)*0.9,max(beatMean)*0.9, rightText , 'HorizontalAlignment','right');

            set(gca,'position',get(gca,'position').*[1 1 1.2 1.2])
            axis off;
        end
    end
end
set(qualityPlot,'units','normalized','outerposition',[0 0 1 1]);
set(qualityPlot,'PaperPositionMode','auto');
print(qualityPlot,...
    ['../results/plots/QualityPlotVV_' ...
    patientId '_Clip_EX' num2str(EXCLUDEBEATS) ...
    '_MAX' num2str(MAXBEATS) '_bC'],'-dpng','-r0');% savefig(qualityPlot,'QualityPlot.fig');
close(qualityPlot);
%% Clip After change VV plots
interval = Results.(patientId).VV.interval;
nIntervals = length(interval);
nChanges = 3;
nDirections = 2; % (fromRef and toRef)
direction = [{'FromRef'},{'ToRef'}];

qualityPlot = figure('Visible', 'off');
for iInterval = 1:nIntervals
    for iChange = 1:nChanges
        for iDirection = 1:nDirections
            currentDirection = char(direction(iDirection));
            
            plotNumber = (iInterval-1)*nChanges*nDirections + (iChange-1)*nDirections + iDirection;
            subplot(nIntervals,nChanges*nDirections,plotNumber);
            beat = Results.(patientId).VV.(currentDirection).PpgClip.beats{iChange,2,iInterval};
            quality = Results.(patientId).VV.(currentDirection).PpgClip.quality(iChange,2,iInterval);

            t = 0:1/fs:(length(beat)-1)/fs;

            beatMean = mean(beat,2);
            beatSd = std(beat,0,2);

            errorbar(t(1:2:end),beatMean(1:2:end),beatSd(1:2:end));
            axis([0,0.7,-inf,inf]);
            leftText = {['VV ' num2str(interval(iInterval))],...
                ['C = ' num2str(iChange)],...
                currentDirection};
            rightText = ['Q = ' num2str(quality,2)];
            text(0,max(beatMean)*0.8, leftText , 'HorizontalAlignment','left');
            text(t(end)*0.9,max(beatMean)*0.9, rightText , 'HorizontalAlignment','right');

            set(gca,'position',get(gca,'position').*[1 1 1.2 1.2])
            axis off;
        end
    end
end
set(qualityPlot,'units','normalized','outerposition',[0 0 1 1]);
set(qualityPlot,'PaperPositionMode','auto');
print(qualityPlot,...
    ['../results/plots/QualityPlotVV_' ...
    patientId '_Clip_EX' num2str(EXCLUDEBEATS) ...
    '_MAX' num2str(MAXBEATS) '_aC'],'-dpng','-r0');% savefig(qualityPlot,'QualityPlot.fig');
close(qualityPlot);

%% Cuff Before change AV plots
interval = Results.(patientId).AV.interval;
nIntervals = length(interval);
nChanges = 3;
nDirections = 2; % (fromRef and toRef)
direction = [{'FromRef'},{'ToRef'}];

qualityPlot = figure('Visible', 'off');
for iInterval = 1:nIntervals
    for iChange = 1:nChanges
        for iDirection = 1:nDirections
            currentDirection = char(direction(iDirection));
            
            plotNumber = (iInterval-1)*nChanges*nDirections + (iChange-1)*nDirections + iDirection;
            subplot(nIntervals,nChanges*nDirections,plotNumber);
            beat = Results.(patientId).AV.(currentDirection).PpgCuff.beats{iChange,1,iInterval};
            quality = Results.(patientId).AV.(currentDirection).PpgCuff.quality(iChange,1,iInterval);

            t = 0:1/fs:(length(beat)-1)/fs;

            beatMean = mean(beat,2);
            beatSd = std(beat,0,2);

            errorbar(t(1:2:end),beatMean(1:2:end),beatSd(1:2:end));
            axis([0,0.7,-inf,inf]);
            leftText = {['AV ' num2str(interval(iInterval))],...
                ['C = ' num2str(iChange)],...
                currentDirection};
            rightText = ['Q = ' num2str(quality,2)];
            text(0,max(beatMean)*0.8, leftText , 'HorizontalAlignment','left');
            text(t(end)*0.9,max(beatMean)*0.9, rightText , 'HorizontalAlignment','right');

            set(gca,'position',get(gca,'position').*[1 1 1.2 1.2])
            axis off;
        end
    end
end
set(qualityPlot,'units','normalized','outerposition',[0 0 1 1]);
set(qualityPlot,'PaperPositionMode','auto');
print(qualityPlot,...
    ['../results/plots/QualityPlotAV_' ...
    patientId '_Cuff_EX' num2str(EXCLUDEBEATS) ...
    '_MAX' num2str(MAXBEATS) '_bC'],'-dpng','-r0');
% savefig(qualityPlot,'QualityPlot.fig');
close(qualityPlot);
%% Cuff After change AV plots
interval = Results.(patientId).AV.interval;
nIntervals = length(interval);
nChanges = 3;
nDirections = 2; % (fromRef and toRef)
direction = [{'FromRef'},{'ToRef'}];

qualityPlot = figure('Visible', 'off');
for iInterval = 1:nIntervals
    for iChange = 1:nChanges
        for iDirection = 1:nDirections
            currentDirection = char(direction(iDirection));
            
            plotNumber = (iInterval-1)*nChanges*nDirections + (iChange-1)*nDirections + iDirection;
            subplot(nIntervals,nChanges*nDirections,plotNumber);
            beat = Results.(patientId).AV.(currentDirection).PpgCuff.beats{iChange,2,iInterval};
            quality = Results.(patientId).AV.(currentDirection).PpgCuff.quality(iChange,2,iInterval);

            t = 0:1/fs:(length(beat)-1)/fs;

            beatMean = mean(beat,2);
            beatSd = std(beat,0,2);

            errorbar(t(1:2:end),beatMean(1:2:end),beatSd(1:2:end));
            axis([0,0.7,-inf,inf]);
            leftText = {['AV ' num2str(interval(iInterval))],...
                ['C = ' num2str(iChange)],...
                currentDirection};
            rightText = ['Q = ' num2str(quality,2)];
            text(0,max(beatMean)*0.8, leftText , 'HorizontalAlignment','left');
            text(t(end)*0.9,max(beatMean)*0.9, rightText , 'HorizontalAlignment','right');

            set(gca,'position',get(gca,'position').*[1 1 1.2 1.2])
            axis off;
        end
    end
end
set(qualityPlot,'units','normalized','outerposition',[0 0 1 1]);
set(qualityPlot,'PaperPositionMode','auto');
print(qualityPlot,...
    ['../results/plots/QualityPlotAV_' ...
    patientId '_Cuff_EX' num2str(EXCLUDEBEATS) ...
    '_MAX' num2str(MAXBEATS) '_aC'],'-dpng','-r0');
% savefig(qualityPlot,'QualityPlot.fig');
close(qualityPlot);
%% Cuff Before change VV plots
interval = Results.(patientId).VV.interval;
nIntervals = length(interval);
nChanges = 3;
nDirections = 2; % (fromRef and toRef)
direction = [{'FromRef'},{'ToRef'}];

qualityPlot = figure('Visible', 'off');
for iInterval = 1:nIntervals
    for iChange = 1:nChanges
        for iDirection = 1:nDirections
            currentDirection = char(direction(iDirection));
            
            plotNumber = (iInterval-1)*nChanges*nDirections + (iChange-1)*nDirections + iDirection;
            subplot(nIntervals,nChanges*nDirections,plotNumber);
            beat = Results.(patientId).VV.(currentDirection).PpgCuff.beats{iChange,1,iInterval};
            quality = Results.(patientId).VV.(currentDirection).PpgCuff.quality(iChange,1,iInterval);

            t = 0:1/fs:(length(beat)-1)/fs;

            beatMean = mean(beat,2);
            beatSd = std(beat,0,2);

            errorbar(t(1:2:end),beatMean(1:2:end),beatSd(1:2:end));
            axis([0,0.7,-inf,inf]);
            leftText = {['VV ' num2str(interval(iInterval))],...
                ['C = ' num2str(iChange)],...
                currentDirection};
            rightText = ['Q = ' num2str(quality,2)];
            text(0,max(beatMean)*0.8, leftText , 'HorizontalAlignment','left');
            text(t(end)*0.9,max(beatMean)*0.9, rightText , 'HorizontalAlignment','right');

            set(gca,'position',get(gca,'position').*[1 1 1.2 1.2])
            axis off;
        end
    end
end
set(qualityPlot,'units','normalized','outerposition',[0 0 1 1]);
set(qualityPlot,'PaperPositionMode','auto');
print(qualityPlot,...
    ['../results/plots/QualityPlotVV_' ...
    patientId '_Cuff_EX' num2str(EXCLUDEBEATS) ...
    '_MAX' num2str(MAXBEATS) '_bC'],'-dpng','-r0');% savefig(qualityPlot,'QualityPlot.fig');
close(qualityPlot);
%% Cuff After change VV plots
interval = Results.(patientId).VV.interval;
nIntervals = length(interval);
nChanges = 3;
nDirections = 2; % (fromRef and toRef)
direction = [{'FromRef'},{'ToRef'}];

qualityPlot = figure('Visible', 'off');
for iInterval = 1:nIntervals
    for iChange = 1:nChanges
        for iDirection = 1:nDirections
            currentDirection = char(direction(iDirection));
            
            plotNumber = (iInterval-1)*nChanges*nDirections + (iChange-1)*nDirections + iDirection;
            subplot(nIntervals,nChanges*nDirections,plotNumber);
            beat = Results.(patientId).VV.(currentDirection).PpgCuff.beats{iChange,2,iInterval};
            quality = Results.(patientId).VV.(currentDirection).PpgCuff.quality(iChange,2,iInterval);

            t = 0:1/fs:(length(beat)-1)/fs;

            beatMean = mean(beat,2);
            beatSd = std(beat,0,2);

            errorbar(t(1:2:end),beatMean(1:2:end),beatSd(1:2:end));
            axis([0,0.7,-inf,inf]);
            leftText = {['VV ' num2str(interval(iInterval))],...
                ['C = ' num2str(iChange)],...
                currentDirection};
            rightText = ['Q = ' num2str(quality,2)];
            text(0,max(beatMean)*0.8, leftText , 'HorizontalAlignment','left');
            text(t(end)*0.9,max(beatMean)*0.9, rightText , 'HorizontalAlignment','right');

            set(gca,'position',get(gca,'position').*[1 1 1.2 1.2])
            axis off;
        end
    end
end
set(qualityPlot,'units','normalized','outerposition',[0 0 1 1]);
set(qualityPlot,'PaperPositionMode','auto');
print(qualityPlot,...
    ['../results/plots/QualityPlotVV_' ...
    patientId '_Cuff_EX' num2str(EXCLUDEBEATS) ...
    '_MAX' num2str(MAXBEATS) '_aC'],'-dpng','-r0');% savefig(qualityPlot,'QualityPlot.fig');
close(qualityPlot);
end

