function [ ] = qualityPlots( Data, Results, iPatient, MAXBEATS, EXCLUDEBEATS )
%QUALITYPLOTS creates and saves plots to verify quality of beat detection
% and beat selection
%   Detailed explanation goes here
%
% Author: Johann Roth
% Date: 10.12.2015

patientId = ['Pt0' num2str(iPatient)];
fs = Data.fs;

%% Parameters
nStimModes = 2; % AV and VV
nChanges = 3;
nDirections = 2; % fromRef and toRef
nPositions = 2; % before change and after change
nSignals = 2; % PpgClip and PpgCuff

stimModes = [{'AV'},{'VV'}];
direction = [{'FromRef'},{'ToRef'}];
positions = [{'beforeChange'},{'afterChange'}];
signals = [{'PpgClip'},{'PpgCuff'}];


%% Loop through all stimulation modes, signals and positions
% intervals are different depenting on mode (AV: 40 80 ... 320; VV: -80 ...
% +80)
for iStimMode = 1:nStimModes
    currentStimMode = char(stimModes(iStimMode));
    interval = Results.(patientId).(currentStimMode).interval;
    nIntervals = length(interval);
    
    % all signals are processed (PpgClip and PpgCuff)
    for iSignal = 1:nSignals
        currentSignal = char(signals(iSignal));
        
        for iPosition = 1:nPositions
            currentPosition = char(positions(iPosition));

            % for each Mode, Signal and Position there are two plots (beats
            % overview and errorbar)
            
            % initialize both plots
            qualityPlotErrorBar = figure('Visible', 'off');
            qualityPlotBeatsOverview = figure('Visible', 'off');
            for iInterval = 1:nIntervals
                for iChange = 1:nChanges
                    for iDirection = 1:nDirections
                        currentDirection = char(direction(iDirection));
                        
                        beats = Results.(patientId).(currentStimMode).(currentDirection).(currentSignal).beats{iChange,iPosition,iInterval};
                        meanBeat = Results.(patientId).(currentStimMode).(currentDirection).(currentSignal).meanBeat{iChange,iPosition,iInterval};
                        quality = Results.(patientId).(currentStimMode).(currentDirection).(currentSignal).quality(iChange,iPosition,iInterval);
                        t = 0:1/fs:(length(beats)-1)/fs;
                        % calculate standard deviation for errorbar plot
                        beatSd = std(beats,0,2);
                        
                        plotNumber = (iInterval-1)*nChanges*nDirections + (iChange-1)*nDirections + iDirection;
                        
                        %% Plot Errorbar
                        set(groot,'CurrentFigure',qualityPlotErrorBar);
                        subplot(nIntervals,nChanges*nDirections,plotNumber);
                        
                        errorbar(t(1:2:end),meanBeat(1:2:end),beatSd(1:2:end));
                        axis([0,0.8,-inf,inf]);
                        % define texts
                        leftText = {[currentStimMode ' ' num2str(interval(iInterval))],...
                            ['C' num2str(iChange)],...
                            currentDirection};
                        rightText = ['Q = ' num2str(quality,2)];
                        % input texts
                        text(0,max(meanBeat)*0.8, leftText , 'HorizontalAlignment','left');
                        text(t(end)*0.9,max(meanBeat)*0.9, rightText , 'HorizontalAlignment','right');
                        % scale plot
                        set(gca,'position',get(gca,'position').*[1 1 1.2 1.2])
                        axis off;
                        
                        %% Plot beats overview
                        set(groot,'CurrentFigure',qualityPlotBeatsOverview);
                        subplot(nIntervals,nChanges*nDirections,plotNumber);
                        
                        plot(t,beats);
                        axis([0,0.8,-inf,inf]);
                        % define texts
                        leftText = {[currentStimMode ' ' num2str(interval(iInterval))],...
                            ['C' num2str(iChange)],...
                            currentDirection};
                        rightText = ['Q = ' num2str(quality,2)];
                        % input texts
                        text(0,max(meanBeat)*0.8, leftText , 'HorizontalAlignment','left');
                        text(t(end)*0.9,max(meanBeat)*0.9, rightText , 'HorizontalAlignment','right');
                        % scale plot
                        set(gca,'position',get(gca,'position').*[1 1 1.2 1.2])
                        axis off;
                    end % Direction of change
                end % Change of Interval
            end % Stimulation interval
            
            %% Last changes to ErrorBar plot and saving
            set(groot,'CurrentFigure',qualityPlotErrorBar);
            set(qualityPlotErrorBar,'units','normalized','outerposition',[0 0 1 1]);
            set(qualityPlotErrorBar,'PaperPositionMode','auto');
            print(qualityPlotErrorBar,...
                ['../results/plots/QualityPlotErrorBar/QualityPlot' currentStimMode '_' ...
                patientId '_' currentSignal '_EX' num2str(EXCLUDEBEATS) ...
                '_MAX' num2str(MAXBEATS) '_' currentPosition],'-dpng','-r0');
            close(qualityPlotErrorBar);
            %% Last changes to BeatsOverview plot and saving
            set(groot,'CurrentFigure',qualityPlotBeatsOverview);
            set(qualityPlotBeatsOverview,'units','normalized','outerposition',[0 0 1 1]);
            set(qualityPlotBeatsOverview,'PaperPositionMode','auto');
            print(qualityPlotBeatsOverview,...
                ['../results/plots/QualityPlotBeats/QualityPlotBeats' currentStimMode '_' ...
                patientId '_' currentSignal '_EX' num2str(EXCLUDEBEATS) ...
                '_MAX' num2str(MAXBEATS) '_' currentPosition],'-dpng','-r0');
            close(qualityPlotBeatsOverview);
        end % Position
    end % Signal
end % StimMode

end

