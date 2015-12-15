function [  ] = testPlots( Results, patient )

relDelta = 'Delta';
maxbeats = Results.Info.maxbeats;
excludebeats = Results.Info.excludebeats;

%% List of parameters
listParameters = Results.Info.parameters;
nParameters = length(listParameters);
listUnits = Results.Info.parameterUnits;

%% Set possible values by which the beats are sorted in Results struct
listStimModes = [{'AV'},{'VV'}];
listDirections = [{'FromRef'},{'ToRef'}];
listSignals = [{'PpgClip'}, {'PpgCuff'}];

%% Loop through beats to calculate difference values

for iParameter = 6 % default: 1:nParameters
    cParameter = char(listParameters(iParameter));
    cUnit = char(listUnits(iParameter));
    %% Define relDelta for each parameter
    switch cParameter
        case 'pulseHeight'
            relDelta = 'Rel';
        case 'pulseWidth'
            relDelta = 'Delta';
        case 'pulseArea'
            relDelta = 'Rel';
        case 'heightOverWidth'
            relDelta = 'Rel';
        case 'crestTime'
            relDelta = 'Delta';
        case 'ipa'
            relDelta = 'Rel';
        otherwise
            fprintf('Error, parameter not specified for plotting');
    end
    %% Loop through all signals
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
                if strcmp(relDelta,'Rel')
                    plot(cReferenceInterval, 1,'ks');
                    hold on;
                    plot([-100 500], [1 1],'k:');
                else
                    plot(cReferenceInterval, 0,'ks');
                    hold on;
                    plot([-100 500], [0 0],'k:');
                end
                
                
                
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
                    cValues = Results.(patientId).(cMode).(cDirection).(cSignal).([cParameter relDelta])(:);
                    
                    nanMask = isnan(cValues);
                    cValues(nanMask) = [];
                    intervalPlotVector(nanMask) = [];
                    plot(intervalPlotVector, cValues, cLineStylePoints);
                    %% Plot quadratic regressions
                    % if there enough data points
                    if length(cValues) > 3
                        quadraticCoeff = polyfit(intervalPlotVector,cValues,2);
                        xRegression = linspace(intervals(1)-20,intervals(end)+20);
                        yRegression = polyval(quadraticCoeff, xRegression);
                        plot(xRegression, yRegression, cLineStyleRegression);
                    end
                    
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
                cValues = [ Results.(patientId).(cMode).FromRef.(cSignal).([cParameter relDelta])(:); ...
                    Results.(patientId).(cMode).ToRef.(cSignal).([cParameter relDelta])(:)];
                nanMask = isnan(cValues);
                cValues(nanMask) = [];
                intervalPlotVector(nanMask) = [];
                %% Plot quadratic regressions
                % if there enough data points
                if length(cValues) > 3
                    quadraticCoeff = polyfit(intervalPlotVector,cValues,2);
                    xRegression = linspace(intervals(1)-20,intervals(end)+20);
                    yRegression = polyval(quadraticCoeff, xRegression);
                    plot(xRegression, yRegression, 'g-', 'LineWidth', 1.5);
                end
                
                
                %% Labeling and adjusting plot
                title([patientId ' ' cMode ' (' cSignal ')']);
                % Labeling depending on parameter
                switch cParameter
                    
                    case 'pulseHeight'
                        %% Pulse height
                        if strcmp(relDelta,'Rel')
                            ylabel(['relative pulse height [' cUnit '/' cUnit ']']);
                            ymin = 0;
                            ymax = 3;
                            
                        else
                            ylabel(['delta pulse height [' cUnit ']']);
                            ymin = -inf;
                            ymax = inf;
                        end
                    case 'pulseWidth'
                        %% Pulse width
                        if strcmp(relDelta,'Rel')
                            ylabel(['relative pulse width [' cUnit '/' cUnit ']']);
                            ymin = 0.4;
                            ymax = 1.4;
                            
                        else
                            ylabel(['delta pulse width [' cUnit ']']);
                            ymin = -100;
                            ymax = 100;
                        end
                    case 'pulseArea'
                        %% pulse area
                        if strcmp(relDelta,'Rel')
                            ylabel(['relative pulse area [' cUnit '/' cUnit ']']);
                            ymin = 0.3;
                            ymax = 2.5;
                            
                        else
                            ylabel(['delta pulse area [' cUnit ']']);
                            ymin = -inf;
                            ymax = inf;
                        end
                    case 'heightOverWidth'
                        %% height over width
                        if strcmp(relDelta,'Rel')
                            ylabel(['relative pulse height/width [' cUnit '/' cUnit ']']);
                            ymin = -inf;
                            ymax = inf;
                        else
                            ylabel(['delta pulse height/width [' cUnit ']']);
                            ymin = -inf;
                            ymax = inf;
                        end
                    case 'crestTime'
                        %% crest time
                        if strcmp(relDelta,'Rel')
                            ylabel(['relative cresttime [' cUnit '/' cUnit ']']);
                            ymin = -inf;
                            ymax = inf;
                        else
                            ylabel(['delta crest time [' cUnit ']']);
                            ymin = -inf;
                            ymax = inf;
                        end
                    case 'ipa'
                        %% ipa
                        if strcmp(relDelta,'Rel')
                            ylabel(['relative IPA [' cUnit '/' cUnit ']']);
                            ymin = -inf;
                            ymax = inf;
                        else
                            ylabel(['delta IPA [' cUnit ']']);
                            ymin = -inf;
                            ymax = inf;
                        end
                    otherwise
                        fprintf('Error, parameter not specified for plotting');
                end
                % Different scaling depending on mode
                switch cMode
                    case 'AV'
                        %% AV mode
                        axis([0 360 ymin ymax])
                        xlabel('AV interval [ms]');
                    case 'VV'
                        %% VV mode
                        axis([-100 100 ymin ymax])
                        xlabel('VV interval [ms]');
                    otherwise
                        fprintf('Error');
                end
                %% Save plots to png
                
            end % Pt01/...
        end % AV/VV
        targetDirectory = ['../results/plots/ScatterplotsRegression/EX' ...
            num2str(excludebeats) '_MAX' num2str(maxbeats)];
        if ~exist(targetDirectory, 'dir')
            mkdir(targetDirectory);
        end
        set(gcf,'PaperPositionMode','auto');
        print(gcf,...
            [targetDirectory '/' cParameter '_' ...
            cSignal '_EX' num2str(excludebeats) ...
            '_MAX' num2str(maxbeats)],'-dpng','-r0');
        
    end % PpgClip/PpgCuff
end % Parameters

end


