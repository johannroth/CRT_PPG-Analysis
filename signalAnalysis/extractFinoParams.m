function [ UpdatedResults ] = extractFinoParams( Results, Data, Metadata, iPatient, MAXBEATS, EXCLUDEBEATS )
%EXTRACTFINOPARAMS analyses mode changes saves Parameters calculated by
% Finometer (and BeatScope software) to Results struct
%   Parameters:
%       Results (struct)
%           Results struct created by main.m containing sorted beats for
%           all patients
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
%       UpdatedResults (struct)
%           Results struct with added Finometer parameters (mean values
%           and std over MAXBEATS around changes.
%
%
% Author: Johann Roth
% Date: 07.12.2015

%% Calculate parameters for current patient
heartRate = Metadata.heartRate(iPatient);
rrInterval = 60/heartRate;
fs = Data.fs;
patientId = ['Pt0' num2str(iPatient)];

%% List of parameters extracted by BeatScope
bsParameters = [{'BpDiastolic'}, ...
    {'BpSystolic'}, {'StrokeVolume'}, ...
    {'Lvet'}, ...
    {'MaximumSlope'}, ...
    {'Tpr'}];
bsParameterLatexScatterplotNames = [{'Änderung des diast. BP'}, ...
    {'Änderung des syst. BP'}, {'Änderung des HSV'}, ...
    {'Änderung der LVET'}, ...
    {'Änderung des max. Anstiegs'}, ...
    {'Änderung der SVR'}];
bsParameterLatexNames = [{'diast. BP'},...
    {'syst. BP'}, {'HSV'}, ...
    {'LVET'}, ...
    {'Max. Anstieg'}, ...
    {'SVR'}];
bsParameterUnits = [{'mmHg'}, ...
    {'mmHg'}, {'ml'}, ...
    {'ms'}, ...
    {'mmHg/s'}, ...
    {'dyn*s/cm^5'}];

Results.Info.bsParameters = bsParameters;
Results.Info.bsParameterLatexNames = bsParameterLatexNames;
Results.Info.bsParameterUnits = bsParameterUnits;
Results.Info.bsParameterLatexScatterplotNames = bsParameterLatexScatterplotNames;

for currentMode = [{'AV'},{'VV'}]
    % Same extraction algorithm is used to extract beats for both flanks
    for currentFlank = [{'FromRef'},{'ToRef'}]
        %% Initialize cell arrays for BeatScope parameters
        nIntervals = length(Results.(patientId).(char(currentMode)).interval);
        
        for iParameter = 1:length(bsParameters)
            cParameter = char(bsParameters(iParameter));
            Results.(patientId).(char(currentMode)).(char(currentFlank)).BsBp.(cParameter) = zeros(3,2,nIntervals);
        end
        
        
        %% Go through all stimulation intervals
        for iInterval = 1:nIntervals
            %% Go through all 3 mode changes in the current interval
            for iChange = 1:3
                %% Select detections for beats BEFORE a mode change
                
                lastPossibleSample = Results.(patientId).(char(currentMode)).(char(currentFlank)).stamps(iChange, iInterval) - ...
                    rrInterval*fs - ...
                    rrInterval*EXCLUDEBEATS*fs;
                firstPossibleSample = Results.(patientId).(char(currentMode)).(char(currentFlank)).stamps(iChange, iInterval) - ...
                    rrInterval*fs - ...
                    (MAXBEATS+0.5) * rrInterval * fs;
                % Detection mask is taken from BeatScope detections only,
                % because only for those stamps, there are corresponding
                % calculated values.
                detectionMask = logical( ...
                    (Data.BeatDetections.BsBp.samplestamp > firstPossibleSample) .* ...
                    (Data.BeatDetections.BsBp.samplestamp < lastPossibleSample) );
                
                % Calculate mean value for each parameter
                for iParameter = 1:length(bsParameters)
                    cParameter = char(bsParameters(iParameter));
                    
                    cValues = Data.BsValues.(cParameter).value(detectionMask);
                    while length(cValues) > MAXBEATS-EXCLUDEBEATS
                        cValues = cValues(2:end);
                    end
                    
                    meanParameter = mean(cValues);
                    Results.(patientId).(char(currentMode)).(char(currentFlank)).BsBp.(cParameter)(iChange, 1, iInterval)...
                        = meanParameter;
                end
                
                
                %% Select detections for beats AFTER a mode change
                
                firstPossibleSample = Results.(patientId).(char(currentMode)).(char(currentFlank)).stamps(iChange, iInterval) + ...
                    rrInterval*EXCLUDEBEATS*fs;
                lastPossibleSample = Results.(patientId).(char(currentMode)).(char(currentFlank)).stamps(iChange, iInterval) + ...
                    (MAXBEATS)*rrInterval*fs;
                
                % Detection mask is taken from BeatScope detections only,
                % because only for those stamps, there are corresponding
                % calculated values.
                detectionMask = logical( ...
                    (Data.BeatDetections.BsBp.samplestamp > firstPossibleSample) .* ...
                    (Data.BeatDetections.BsBp.samplestamp < lastPossibleSample) );
                
                % Calculate mean value for each parameter
                for iParameter = 1:length(bsParameters)
                    cParameter = char(bsParameters(iParameter));
                    
                    cValues = Data.BsValues.(cParameter).value(detectionMask);
                    while length(cValues) > MAXBEATS-EXCLUDEBEATS
                        cValues = cValues(1:end-1);
                    end
                    
                    meanParameter = mean(cValues);
                    Results.(patientId).(char(currentMode)).(char(currentFlank)).BsBp.(cParameter)(iChange, 2, iInterval)...
                        = meanParameter;
                end
                
                
            end
        end
    end
end

UpdatedResults = Results;



end