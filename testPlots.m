function [  ] = testPlots( Results, patient )

%% List of parameters
listParameters = Results.Info.parameters;

%% Set possible values by which the beats are sorted in Results struct
listStimModes = [{'AV'},{'VV'}];
listDirections = [{'FromRef'},{'ToRef'}];
listSignals = [{'PpgClip'}, {'PpgCuff'}];

%% Loop through beats to calculate difference values
for iParameter = listParameters
    cParameter = char(iParameter);
    for iSignal = listSignals                                       % PpgClip / PpgCuff
        figure('Units', 'normalized','OuterPosition',[0, 0, 1, 1]);
        cSignal = char(iSignal);
        for iMode = 1:length(listStimModes)                         % AV / VV
            cMode = char(listStimModes(iMode));
            
            for iPatient = 1:length(patient)                        % Pt01 / ... / Pt06
                patientId = ['Pt0' num2str(patient(iPatient))];
                
                intervals = Results.(patientId).(cMode).interval;
                nIntervals = length(intervals);
                
                
                cReferenceInterval = Results.(patientId).(cMode).refInterval;
                
                subplot( 2, length(patient), (iMode-1)*length(patient) + iPatient);
                plot(cReferenceInterval, 1,'ks');
                hold on;
                plot([-100 500], [1 1],'k:');
                
                for iDirection = listDirections                     % FromRef / ToRef
                    cDirection = char(iDirection);
                    switch cDirection
                        case 'FromRef'
                            %% Current change from reference to test interval
                            cLineStylePoints = 'rx';
                            cLineStyleRegression = 'r-.';
                        case 'ToRef'
                            %% Current change from test to reference interval
                            cLineStylePoints = 'bo';
                            cLineStyleRegression = 'b-.';
                        otherwise
                            fprintf('Error');
                    end
                    
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
                    cValues = Results.(patientId).(cMode).(cDirection).(cSignal).([cParameter 'Rel'])(:);
                    
                    nanMask = isnan(cValues);
                    cValues(nanMask) = [];
                    intervalPlotVector(nanMask) = [];
                    plot(intervalPlotVector, cValues, cLineStylePoints);
                    %% Plot quadratic regressions
                    quadraticCoeff = polyfit(intervalPlotVector,cValues,2);
                    xRegression = linspace(intervals(1)-20,intervals(end)+20);
                    yRegression = polyval(quadraticCoeff, xRegression);
                    plot(xRegression, yRegression, cLineStyleRegression);
                end % FromRef/ToRef
                
                %% Calculate values for combined quadratic regression
                % for combined data (ToRef and FromRef)
                
                % Create Vector containing intervals suitable for plotting
                % i.e. as a vector: [40 40 40 80 80 80 .... 320 320 320]
                % Every interval is used three times (3 changes per direction)
                
                % length has to be double to include changes in both
                % directions
                intervalPlotVector = zeros(6*nIntervals,1);
                for iInterval = 1:nIntervals
                    for iChange = 1:3
                        intervalPlotVector((iInterval-1)*3+iChange) = intervals(iInterval);
                        intervalPlotVector(3*nIntervals + (iInterval-1)*3+iChange) = intervals(iInterval);
                    end
                end
                
                
                % Quadratic regression is calculated based on values from
                % both directions of changes (ToRef and FromRef).
                % NaN values in cValues and interval vector are removed
                cValues = [ Results.(patientId).(cMode).FromRef.(cSignal).([cParameter 'Rel'])(:); ...
                            Results.(patientId).(cMode).ToRef.(cSignal).([cParameter 'Rel'])(:)];
                nanMask = isnan(cValues);
                cValues(nanMask) = [];
                intervalPlotVector(nanMask) = [];                
                %% Plot quadratic regressions
                quadraticCoeff = polyfit(intervalPlotVector,cValues,2);
                xRegression = linspace(intervals(1)-20,intervals(end)+20);
                yRegression = polyval(quadraticCoeff, xRegression);
                plot(xRegression, yRegression, 'g-', 'LineWidth', 1.5);
                
                
                %% Labeling and adjusting plot
                title([patientId ' ' cMode ' (' cSignal ')']);
                ylabel('relative pulse height');
                switch cMode
                    case 'AV'
                        %% Current change from reference to test interval
                        axis([0 360 0 2])
                        xlabel('AV interval [ms]');
                    case 'VV'
                        %% Current change from test to reference interval
                        axis([-100 100 0 3])
                        xlabel('VV interval [ms]');
                    otherwise
                        fprintf('Error');
                end
                
            end % Pt01/...
        end % AV/VV
    end % PpgClip/PpgCuff
end % Parameters

end


