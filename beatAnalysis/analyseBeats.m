function [ UpdatedResults ] = analyseBeats( Results, Data )
%ANALYSEBEATS analyses beats in a given struct of results
%   Parameters:
%       Results (struct)
%           Results struct created by main.m containing sorted beats for
%           all patients
%       Data (struct)
%           Data struct created by main.m containing signals of a single
%           patient
%   Returns:
%       UpdatedResults (struct)
%           Results struct created by main.m containing sorted beats for
%           all patients with updated beats
%
% Author: Johann Roth
% Date: 11.12.2015


%% Set possible values by which the beats are sorted in Results struct
listStimModes = [{'AV'},{'VV'}];
listDirections = [{'FromRef'},{'ToRef'}];
listPositions = 1:2;
listSignals = [{'PpgClip'},{'PpgCuff'}];
listChanges = 1:3;
% in the following variables beginning with c (like cModes) contain the
% current value
%% Loop through beats in Results struct
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
                            Results.(patientId).(cMode).(cDirection).(cSignal).pulseHeight(iChange, iPosition, iInterval) ...
                                = getPulseHeight(beat);
                            %% Here processing of the current beat is finished #####
                        end
                    end
                end
            end
        end
    end
end

end


