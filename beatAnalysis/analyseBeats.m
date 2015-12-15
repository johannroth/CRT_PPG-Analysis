function [ UpdatedResults ] = analyseBeats( Results, fs, patient )
%ANALYSEBEATS analyses beats in a given struct of results
%   Parameters:
%       Results (struct)
%           Results struct created by main.m containing sorted beats for
%           all patients
%       fs (scalar)
%           sampling frequency
%       patient (int [1xN])
%           List of patients where N patient numbers are specified
%   Returns:
%       UpdatedResults (struct)
%           Results struct created by main.m containing sorted beats for
%           all patients with updated beats
%
% Author: Johann Roth
% Date: 11.12.2015

%% List of parameters
Results.Info.parameters = [{'pulseHeight'}, {'pulseWidth'},...
                           {'pulseArea'}, {'heightOverWidth'},...
                           {'crestTime'}, {'ipa'}];
Results.Info.parameterUnits = [{'a.u.'}, {'ms'},...
                               {'a.u.'}, {'a.u.'},...
                               {'ms'}, {'a.u.'}];

Results.Info.nMeanBeats = 0;


%% Set possible values by which the beats are sorted in Results struct
listStimModes = [{'AV'},{'VV'}];
listDirections = [{'FromRef'},{'ToRef'}];
listPositions = 1:2;
listSignals = [{'PpgClip'},{'PpgCuff'}];
listChanges = 1:3;
% in the following variables beginning with c (like cModes) contain the
% current value
%% Loop through beats in Results struct to calculate beat parameters
for iPatient = 1:length(patient)                            % Pt01 / ... / Pt06
    patientId = ['Pt0' num2str(patient(iPatient))];
    for iMode = listStimModes                               % AV / VV
        cMode = char(iMode);
        intervals = Results.(patientId).(char(iMode)).interval;
        nIntervals = length(intervals);
        for iDirection = listDirections                     % FromRef / ToRef
            cDirection = char(iDirection);
            for iSignal = listSignals                       % PpgClip / PpgCuff
                cSignal = char(iSignal);
                
                %% Initializing of matrices to save extracted parameters in ########
                Results.(patientId).(cMode).(cDirection).(cSignal).pulseHeight = zeros(3,2,nIntervals);
                %% All matrices have been initialized ##############################
                
                for iChange = listChanges                   % #1 / #2 / #3
                    for iPosition = listPositions           % before / after change
                        for iInterval = 1:nIntervals        % AV40 / ... / VV80
                            %% Here every single mean beat is processed ############
                            beat = Results.(patientId).(cMode).(cDirection).(cSignal).meanBeat{iChange, iPosition, iInterval};
                            slope = getDerivative(beat);
                            
                            pulseHeight = getPulseHeight(beat);
                            pulseWidth = getPulseWidth(beat, fs);
                            pulseArea = getPulseArea(beat);
                            crestTime = getCrestTime(beat, fs);
                            ipa = getIPA(beat, slope);
                            
                            Results.(patientId).(cMode).(cDirection).(cSignal).pulseHeight(iChange, iPosition, iInterval) ...
                                = pulseHeight;
                            Results.(patientId).(cMode).(cDirection).(cSignal).pulseWidth(iChange, iPosition, iInterval) ...
                                = pulseWidth;
                            Results.(patientId).(cMode).(cDirection).(cSignal).pulseArea(iChange, iPosition, iInterval) ...
                                = pulseArea;
                            Results.(patientId).(cMode).(cDirection).(cSignal).heightOverWidth(iChange, iPosition, iInterval) ...
                                = pulseHeight/pulseArea;
                            Results.(patientId).(cMode).(cDirection).(cSignal).crestTime(iChange, iPosition, iInterval) ...
                                = crestTime;
                            Results.(patientId).(cMode).(cDirection).(cSignal).ipa(iChange, iPosition, iInterval) ...
                                = ipa;
                            
                            Results.Info.nMeanBeats = Results.Info.nMeanBeats + 1;
                            %% Here processing of the current beat is finished #####
                        end
                    end
                end
            end
        end
    end
end

%% Write back results
UpdatedResults = Results;
end


