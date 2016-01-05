function [ UpdatedResults ] = saveScatterplotData( Results, patient )
%SAVESCATTERPLOTDATA creates matrices for fast scatterplot creation and
% saves them to results-struct. Serves as preparation for calculation of
% regression curves.
% Scatterplotdata is saved as a matrix with the first column containing the
% stimulation intervals, the second column containing the Delta values and
% the third column containing the relative values
%   Parameters:
%       Results (struct)
%           Results struct created by main.m containing sorted beats for
%           all patients
%       patient (int [1xN])
%           List of patients where N patient numbers are specified
%   Returns:
%       UpdatedResults (struct)
%           Results struct created by main.m containing matrices for fast
%           scatterplot creation
%
% Author: Johann Roth
% Date: 05.01.2016

%% List of parameters
listParameters = Results.Info.parameters;
listBsParameters = Results.Info.bsParameters;
nParameters = length(listParameters);
nBsParameters = length(listBsParameters);

%% Set possible values by which the beats are sorted in Results struct
listStimModes = [{'AV'},{'VV'}];
listDirections = [{'FromRef'},{'ToRef'}];
listSignals = [{'PpgClip'}, {'PpgCuff'}];

%% Loop through parameters from PPG signal
for iParameter = 1:nParameters % default: 1:nParameters
    cParameter = char(listParameters(iParameter));
    
    %% Loop through all signals
    for iSignal = listSignals                                       % PpgClip / PpgCuff
        cSignal = char(iSignal);
        for iMode = 1:length(listStimModes)                         % AV / VV
            cMode = char(listStimModes(iMode));
            
            for iPatient = 1:length(patient)                        % Pt01 / ... / Pt06
                patientId = ['Pt0' num2str(patient(iPatient))];
                
                intervals = Results.(patientId).(cMode).interval;
                nIntervals = length(intervals);
                
                for iDirection = listDirections                     % FromRef / ToRef
                    cDirection = char(iDirection);
                    
                    %% Create Vector containing intervals suitable for plotting
                    % i.e. as a vector: [40 40 40 80 80 80 .... 320 320 320]
                    % Every interval is used three times (3 changes per direction)
                    intervalPlotVector = zeros(3*nIntervals,1);
                    for iInterval = 1:nIntervals
                        for iChange = 1:3
                            intervalPlotVector((iInterval-1)*3+iChange) = intervals(iInterval);
                        end
                    end
                    %% Scatterplots
                    % nan values in cValues and interval vector are removed
                    cValuesRel = Results.(patientId).(cMode).(cDirection).(cSignal).([cParameter 'Rel'])(:);
                    nanMask = isnan(cValuesRel);
                    cValuesRel(nanMask) = [];
                    intervalPlotVector(nanMask) = [];
                    cValuesDelta = Results.(patientId).(cMode).(cDirection).(cSignal).([cParameter 'Delta'])(:);
                    cValuesDelta(nanMask) = [];
                    % Intervals and Datapoints are put together into one matrix
                    Results.(patientId).(cMode).(cDirection).(cSignal).ScatterplotData.(cParameter) = ...
                        [ intervalPlotVector cValuesDelta cValuesRel ];
                    
                    
                end % FromRef/ToRef
            end % Pt01/...
        end % AV/VV
    end % PpgClip/PpgCuff
end % Parameters
%% Loop through parameters from BP signal (BeatScope/Finometer)
for iParameter = 1:nBsParameters % default: 1:nBsParameters
    cParameter = char(listBsParameters(iParameter));
    
    cSignal = 'BsBp';
    for iMode = 1:length(listStimModes)                         % AV / VV
        cMode = char(listStimModes(iMode));
        
        for iPatient = 1:length(patient)                        % Pt01 / ... / Pt06
            patientId = ['Pt0' num2str(patient(iPatient))];
            
            intervals = Results.(patientId).(cMode).interval;
            nIntervals = length(intervals);
            
            for iDirection = listDirections                     % FromRef / ToRef
                cDirection = char(iDirection);
                
                %% Create Vector containing intervals suitable for plotting
                % i.e. as a vector: [40 40 40 80 80 80 .... 320 320 320]
                % Every interval is used three times (3 changes per direction)
                intervalPlotVector = zeros(3*nIntervals,1);
                for iInterval = 1:nIntervals
                    for iChange = 1:3
                        intervalPlotVector((iInterval-1)*3+iChange) = intervals(iInterval);
                    end
                end
                %% Scatterplots
                % nan values in cValues and interval vector are removed
                cValuesRel = Results.(patientId).(cMode).(cDirection).(cSignal).([cParameter 'Rel'])(:);
                nanMask = isnan(cValuesRel);
                cValuesRel(nanMask) = [];
                intervalPlotVector(nanMask) = [];
                cValuesDelta = Results.(patientId).(cMode).(cDirection).(cSignal).([cParameter 'Delta'])(:);
                cValuesDelta(nanMask) = [];
                % Intervals and Datapoints are put together into one matrix
                Results.(patientId).(cMode).(cDirection).(cSignal).ScatterplotData.(cParameter) = ...
                    [ intervalPlotVector cValuesDelta cValuesRel ];
                
                
            end % FromRef/ToRef
        end % Pt01/...
    end % AV/VV
end % BS Parameters

UpdatedResults = Results;

end



