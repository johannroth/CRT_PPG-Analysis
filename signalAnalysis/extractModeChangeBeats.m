function [ AV, VV ] = extractModeChangeBeats( ModeAV, ModeVV, Data, Metadata, iPatient, MAXBEATS, EXCLUDEBEATS )
%EXTRACTMODECHANGEBEATS analyses mode changes and beat detections and
% returns 'good' beats (i.e. beats that are not excluded) sorted by
% stimulation mode, change to or from a reference mode. For each mode there
% are 3 changes each for change to and from reference mode.
%   Parameters:
%       ModeAV (struct)
%           struct containing used intervals, reference interval and stamps
%           of mode changes to and from reference mode (of current patient)
%       ModeVV (struct)
%           struct containing used intervals, reference interval and stamps
%           of mode changes to and from reference mode. Analog to VV
%           stimulation modes.
%       Data (struct)
%           struct containing imported unisens signals of a patient
%       Metadata (struct)
%           struct containing metadata of all patients
%       iPatient (int)
%           number of the current patient
%       MAXBEATS (int)
%           number of maximum beats around mode change to be analysed
%       EXCLUDEBEATS (int)
%           number of beats directly around a change of stimulation
%           interval to be excluded
%   Returns:
%       AV.ToRef (struct) / VV.ToRef
%           struct containing good beats sorted by sorted by stimulation
%           mode, change TO a reference mode. For each mode there are 3
%           changes and for each change matrices of MAXBEATS beats before
%           and after the change itself
%
%           ToRef.PpgClip.beats (cell array [3 x 2 x N])
%               containing matrices of double [BEATLENGTH x M] where N is
%               the amount of modes and M is the amount of beats (3
%               repetitions per change of stimulation interval, 2 analyzed
%               areas: before and after change)
%
%           ToRef.PpgClip.beatQuality (array [3 x 2 x N])
%               containing quality values for selected beats (representing
%               the amount of beats filtered out)
%
%           ToRef.PpgCuff
%               analog to content of ToRef.PpgClip
%
%       AV.FromRef (struct) / VV.FromRef
%           struct analog to ToRef
%
%
% Author: Johann Roth
% Date: 07.12.2015

%% Keep information in existing structs
AV = ModeAV;
VV = ModeVV;

%% Calculate parameters for current patient
heartRate = Metadata.heartRate(iPatient);
rrInterval = 60/heartRate;
fs = Data.fs;

%% AV mode is calculated first
% Same extraction algorithm is used to extract beats for both flanks
for currentFlank = [{'FromRef'},{'ToRef'}]

    %% Initialize cell arrays
    % amount of mode changes
    nIntervals = length(AV.interval);
    for currentSignal = [{'PpgClip'},{'PpgCuff'}]
        AV.(char(currentFlank)).(char(currentSignal)).beats = cell(3,2,nIntervals);
        AV.(char(currentFlank)).(char(currentSignal)).quality = zeros(3,2,nIntervals);
    end

    %% Go through all stimulation intervals
    for iInterval = 1:nIntervals
        %% Go through all 3 mode changes in the current interval
        for iChange = 1:3
            %% Select detections for beats BEFORE a mode change

            lastPossibleSample = AV.FromRef.stamps(iChange, iInterval) - ...
                                 rrInterval*fs - ...
                                 rrInterval*EXCLUDEBEATS*fs;
            firstPossibleSample = AV.FromRef.stamps(iChange, iInterval) - ...
                                 rrInterval*fs - ...
                                 (MAXBEATS+0.5) * rrInterval * fs;
            detectionMask = logical( ...
                (Data.BeatDetections.Merged.samplestamp > firstPossibleSample) .* ...
                (Data.BeatDetections.Merged.samplestamp < lastPossibleSample) );
            
            detections = Data.BeatDetections.Merged.samplestamp(detectionMask);
            while length(detections) > MAXBEATS-EXCLUDEBEATS
                detections = detections(2:end);
            end

            % Make Calculations for both signals
            for currentSignal = [{'PpgClip'},{'PpgCuff'}]
                includedBeats = extractBeats(Data.Signals.(char(currentSignal)).data,...
                         detections,...
                         fs,...
                         heartRate,...
                         true);
                [includedGoodBeats, quality] = extractGoodBeats(includedBeats, fs, heartRate, iPatient);
                AV.(char(currentFlank)).(char(currentSignal)).beats{iChange,1,iInterval} = includedGoodBeats;
                AV.(char(currentFlank)).(char(currentSignal)).quality(iChange,1,iInterval) = quality;
            end
            
            %% Select detections for beats AFTER a mode change
            
            firstPossibleSample = AV.FromRef.stamps(iChange, iInterval) + ...
                                  rrInterval*EXCLUDEBEATS*fs;
            lastPossibleSample = AV.FromRef.stamps(iChange, iInterval) + ...
                                 (MAXBEATS)*rrInterval*fs; 
            detectionMask = logical( ...
                (Data.BeatDetections.Merged.samplestamp > firstPossibleSample) .* ...
                (Data.BeatDetections.Merged.samplestamp < lastPossibleSample) );
            
            detections = Data.BeatDetections.Merged.samplestamp(detectionMask);
            while length(detections) > MAXBEATS-EXCLUDEBEATS
                detections = detections(1:end-1);
            end

            % Make Calculations for both signals
            for currentSignal = [{'PpgClip'},{'PpgCuff'}]
                includedBeats = extractBeats(Data.Signals.(char(currentSignal)).data,...
                         detections,...
                         fs,...
                         heartRate,...
                         true);
                [includedGoodBeats, quality] = extractGoodBeats(includedBeats, fs, heartRate, iPatient);
                AV.(char(currentFlank)).(char(currentSignal)).beats{iChange,2,iInterval} = includedGoodBeats;
                AV.(char(currentFlank)).(char(currentSignal)).quality(iChange,2,iInterval) = quality;
            end
            
        end
    end
end

%% VV mode is calculated second, same algorithm as for AV mode
% Same extraction algorithm is used to extract beats for both flanks
for currentFlank = [{'FromRef'},{'ToRef'}]

    %% Initialize cell arrays
    % amount of mode changes
    nIntervals = length(VV.interval);
    for currentSignal = [{'PpgClip'},{'PpgCuff'}]
        VV.(char(currentFlank)).(char(currentSignal)).beats = cell(3,2,nIntervals);
        VV.(char(currentFlank)).(char(currentSignal)).beatQuality = zeros(3,2,nIntervals);
    end

    %% Go through all stimulation intervals
    for iInterval = 1:nIntervals
        %% Go through all 3 mode changes in the current interval
        for iChange = 1:3
            %% Select detections for beats BEFORE a mode change

            lastPossibleSample = VV.FromRef.stamps(iChange, iInterval) - ...
                                 rrInterval*fs - ...
                                 rrInterval*EXCLUDEBEATS*fs;
            firstPossibleSample = VV.FromRef.stamps(iChange, iInterval) - ...
                                 rrInterval*fs - ...
                                 (MAXBEATS+0.5) * rrInterval * fs;
            detectionMask = logical( ...
                (Data.BeatDetections.Merged.samplestamp > firstPossibleSample) .* ...
                (Data.BeatDetections.Merged.samplestamp < lastPossibleSample) );
            
            detections = Data.BeatDetections.Merged.samplestamp(detectionMask);
            while length(detections) > MAXBEATS-EXCLUDEBEATS
                detections = detections(2:end);
            end

            % Make Calculations for both signals
            for currentSignal = [{'PpgClip'},{'PpgCuff'}]
                includedBeats = extractBeats(Data.Signals.(char(currentSignal)).data,...
                         detections,...
                         fs,...
                         heartRate,...
                         true);
                [includedGoodBeats, quality] = extractGoodBeats(includedBeats, fs, heartRate, iPatient);
                VV.(char(currentFlank)).(char(currentSignal)).beats{iChange,1,iInterval} = includedGoodBeats;
                VV.(char(currentFlank)).(char(currentSignal)).quality(iChange,1,iInterval) = quality;
            end
            
            %% Select detections for beats AFTER a mode change
            
            firstPossibleSample = VV.FromRef.stamps(iChange, iInterval) + ...
                                  rrInterval*EXCLUDEBEATS*fs;
            lastPossibleSample = VV.FromRef.stamps(iChange, iInterval) + ...
                                 (MAXBEATS)*rrInterval*fs; 
            detectionMask = logical( ...
                (Data.BeatDetections.Merged.samplestamp > firstPossibleSample) .* ...
                (Data.BeatDetections.Merged.samplestamp < lastPossibleSample) );
            
            detections = Data.BeatDetections.Merged.samplestamp(detectionMask);
            while length(detections) > MAXBEATS-EXCLUDEBEATS
                detections = detections(1:end-1);
            end

            % Make Calculations for both signals
            for currentSignal = [{'PpgClip'},{'PpgCuff'}]
                includedBeats = extractBeats(Data.Signals.(char(currentSignal)).data,...
                         detections,...
                         fs,...
                         heartRate,...
                         true);
                [includedGoodBeats, quality] = extractGoodBeats(includedBeats, fs, heartRate, iPatient);
                VV.(char(currentFlank)).(char(currentSignal)).beats{iChange,2,iInterval} = includedGoodBeats;
                VV.(char(currentFlank)).(char(currentSignal)).quality(iChange,2,iInterval) = quality;
            end
            
        end
    end
end    

end