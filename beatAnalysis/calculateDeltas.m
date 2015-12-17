function [ UpdatedResults ] = calculateDeltas( Results, patient )
%CALCULATEDELTA calculates delta parameters
%   Parameters:
%       Results (struct)
%           Results struct created by main.m containing sorted beats for
%           all patients
%       patient (int [1xN])
%           List of patients where N patient numbers are specified
%   Returns:
%       UpdatedResults (struct)
%           Results struct created by main.m containing sorted beats for
%           all patients with calculated delta parameters
%
% Author: Johann Roth
% Date: 14.12.2015

%% List of parameters
listParameters = Results.Info.parameters;
listBsParameters = Results.Info.bsParameters;

%% Set possible values by which the beats are sorted in Results struct
listStimModes = [{'AV'},{'VV'}];
listDirections = [{'FromRef'},{'ToRef'}];
listSignals = [{'PpgClip'},{'PpgCuff'}];
listChanges = 1:3;

%% Loop through beats to calculate difference values
for iPatient = 1:length(patient)                            % Pt01 / ... / Pt06
    patientId = ['Pt0' num2str(patient(iPatient))];
    for iMode = listStimModes                               % AV / VV
        cMode = char(iMode);
        intervals = Results.(patientId).(char(iMode)).interval;
        nIntervals = length(intervals);
        for iDirection = listDirections                     % FromRef / ToRef
            cDirection = char(iDirection);
            %% Calculation for parameters from PPG signals
            for iSignal = listSignals                       % PpgClip / PpgCuff
                cSignal = char(iSignal);
                
                %% Initializing of matrices to save delta parameters in ########
                for iParameter = listParameters
                    cParameter = char(iParameter);
                    Results.(patientId).(cMode).(cDirection).(cSignal).([cParameter 'Delta']) = zeros(3,nIntervals);
                    Results.(patientId).(cMode).(cDirection).(cSignal).([cParameter 'Rel']) = zeros(3,nIntervals);
                end
                %% All matrices have been initialized ##############################
                
                for iChange = listChanges                   % #1 / #2 / #3
                    for iInterval = 1:nIntervals            % AV40 / ... / VV80
                        %% Here every single mean beat is processed ############
                        for iParameter = listParameters
                            cParameter = char(iParameter);
                            %% Depending on direction of the change (to or from reference)
                            % delta parameters have to be calculated differently
                            % (always test 'param - ref' param).
                            switch cDirection
                                case 'FromRef'
                                    %% Current change from reference to test interval
                                    Results.(patientId).(cMode).(cDirection).(cSignal).([cParameter 'Delta'])(iChange, iInterval) ...
                                        =  Results.(patientId).(cMode).(cDirection).(cSignal).(cParameter)(iChange, 2, iInterval) ...
                                        - Results.(patientId).(cMode).(cDirection).(cSignal).(cParameter)(iChange, 1, iInterval);
                                    try
                                        Results.(patientId).(cMode).(cDirection).(cSignal).([cParameter 'Rel'])(iChange, iInterval) ...
                                            =  Results.(patientId).(cMode).(cDirection).(cSignal).(cParameter)(iChange, 2, iInterval) ...
                                            / Results.(patientId).(cMode).(cDirection).(cSignal).(cParameter)(iChange, 1, iInterval);
                                    catch
                                        Results.(patientId).(cMode).(cDirection).(cSignal).([cParameter 'Rel'])(iChange, iInterval) = nan;
                                    end
                                case 'ToRef'
                                    %% Current change from test to reference interval
                                    Results.(patientId).(cMode).(cDirection).(cSignal).([cParameter 'Delta'])(iChange, iInterval) ...
                                        =  Results.(patientId).(cMode).(cDirection).(cSignal).(cParameter)(iChange, 1, iInterval) ...
                                        - Results.(patientId).(cMode).(cDirection).(cSignal).(cParameter)(iChange, 2, iInterval);
                                    try
                                        Results.(patientId).(cMode).(cDirection).(cSignal).([cParameter 'Rel'])(iChange, iInterval) ...
                                            =  Results.(patientId).(cMode).(cDirection).(cSignal).(cParameter)(iChange, 1, iInterval) ...
                                            / Results.(patientId).(cMode).(cDirection).(cSignal).(cParameter)(iChange, 2, iInterval);
                                    catch
                                        Results.(patientId).(cMode).(cDirection).(cSignal).([cParameter 'Rel'])(iChange, iInterval) = nan;
                                    end
                                otherwise
                                    fprintf('Error');
                            end
                        end
                        %% Here processing of the current beat is finished #####
                    end
                end
            end
            %% Calculation for parameters from Beatscope (BP signal)
            
            cSignal = 'BsBp';
            
            %% Initializing of matrices to save delta parameters in ########
            for iParameter = listBsParameters
                cParameter = char(iParameter);
                Results.(patientId).(cMode).(cDirection).(cSignal).([cParameter 'Delta']) = zeros(3,nIntervals);
                Results.(patientId).(cMode).(cDirection).(cSignal).([cParameter 'Rel']) = zeros(3,nIntervals);
            end
            %% All matrices have been initialized ##############################
            
            for iChange = listChanges                   % #1 / #2 / #3
                for iInterval = 1:nIntervals            % AV40 / ... / VV80
                    %% Here every single mean beat is processed ############
                    for iParameter = listBsParameters
                        cParameter = char(iParameter);
                        %% Depending on direction of the change (to or from reference)
                        % delta parameters have to be calculated differently
                        % (always test 'param - ref' param).
                        switch cDirection
                            case 'FromRef'
                                %% Current change from reference to test interval
                                valueBeforeChange = Results.(patientId).(cMode).(cDirection).(cSignal).(cParameter)(iChange, 1, iInterval);
                                valueAfterChange = Results.(patientId).(cMode).(cDirection).(cSignal).(cParameter)(iChange, 2, iInterval);
                                if or(isnan(valueBeforeChange),isnan(valueAfterChange))
                                    Results.(patientId).(cMode).(cDirection).(cSignal).([cParameter 'Delta'])(iChange, iInterval) ...
                                        = nan;
                                    Results.(patientId).(cMode).(cDirection).(cSignal).([cParameter 'Rel'])(iChange, iInterval) ...
                                        = nan;
                                else
                                    Results.(patientId).(cMode).(cDirection).(cSignal).([cParameter 'Delta'])(iChange, iInterval) ...
                                        = valueAfterChange - valueBeforeChange;
                                    try
                                        Results.(patientId).(cMode).(cDirection).(cSignal).([cParameter 'Rel'])(iChange, iInterval) ...
                                            =  valueAfterChange / valueBeforeChange;
                                    catch
                                        Results.(patientId).(cMode).(cDirection).(cSignal).([cParameter 'Rel'])(iChange, iInterval) = nan;
                                    end
                                end
                                
                                
                            case 'ToRef'
                                %% Current change from test to reference interval
                                valueBeforeChange = Results.(patientId).(cMode).(cDirection).(cSignal).(cParameter)(iChange, 1, iInterval);
                                valueAfterChange = Results.(patientId).(cMode).(cDirection).(cSignal).(cParameter)(iChange, 2, iInterval);
                                if or(isnan(valueBeforeChange),isnan(valueAfterChange))
                                    Results.(patientId).(cMode).(cDirection).(cSignal).([cParameter 'Delta'])(iChange, iInterval) ...
                                        = nan;
                                    Results.(patientId).(cMode).(cDirection).(cSignal).([cParameter 'Rel'])(iChange, iInterval) ...
                                        = nan;
                                else
                                    Results.(patientId).(cMode).(cDirection).(cSignal).([cParameter 'Delta'])(iChange, iInterval) ...
                                        = valueBeforeChange - valueAfterChange;
                                    try
                                        Results.(patientId).(cMode).(cDirection).(cSignal).([cParameter 'Rel'])(iChange, iInterval) ...
                                            = valueBeforeChange / valueAfterChange;
                                    catch
                                        Results.(patientId).(cMode).(cDirection).(cSignal).([cParameter 'Rel'])(iChange, iInterval) = nan;
                                    end
                                end
                            otherwise
                                fprintf('Error');
                        end
                    end
                    %% Here processing of the current beat is finished #####
                end
            end
            
        end
    end
end


%% Write back results
UpdatedResults = Results;
end


