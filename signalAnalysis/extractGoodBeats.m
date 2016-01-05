function [ goodBeats, quality ] = extractGoodBeats( beats, fs, heartrate, iPatient )
%EXTRACTGOODBEATS removes bad beats from a given beats
% Beats are removed if they diverge strongly from sorrounding beats of if a
% higher or lower heartrate (i.e. RR-interval) is noticed.
%   Parameters:
%       beats (matrix [LxM])
%           matrix containing M single beats (every column is a single
%           beat), length L of a beat is calculated from expected heart
%           rate
%       fs (double)
%           sample frequency of the given signal
%       heartrate (double)
%           expected heartrate in signal (determins the length of a beat)
%       patient (double)
%           patient number
%   Returns:
%       goodBeats (matrix [LxN])
%           matrix containing N good single beats of the M beats (every
%           column is a single beat), length L of a beat is calculated from
%           expected heart rate
%       beatMask (double [1xN])
%           vector containing the indices of beats that are classified as
%           good beats (indices refering to columns in beats matrix)
%       quality (double 0...1)
%           percentage of kept beats
%
% Author: Johann Roth
% Date: 07.12.2015

    DEBUG = false;

    %% Calculate overall beat parameters
    
    expectedRR = 60/heartrate; % in s
    expectedBeatLength = round(expectedRR * fs); % in samples
    % margin equals half the MARGIN of extractBeats i.e. the one-sided
    % margin.
    margin = round(expectedBeatLength*0.1);

    %% Initialize mask to remove beats
    goodBeat = 1:size(beats,2);
    % use 'goodBeat(i) = 0' to mark a bad beat

    %% Remove beats with artifacts or non-expected morphology (3 Criteria)
    for iCurrentBeat = 1:size(beats,2)
        %% Criteria to determine if a beat is bad
        % each criterion has to be false to allow a beat to be passed on
        % as good beat.

%         %% Criterion 1: local minimum around beginning of beat
%         % the first minimum may not be after a certain point in the beat
%         [~, index] = min(beats(1:end/2,iCurrentBeat));
%         if (index > 2*margin)
%             goodBeat(iCurrentBeat) = 0;
%             continue;
%         end
%         %% Criterion 2: local minimum around end of beat
%         % the second minimum may not be before a certain point in the
%         % beat
%         [~, index] = min(beats(end/2:end,iCurrentBeat));
%         if ( index < (length(beats(end/2:end,iCurrentBeat))-1.3*margin) )
%             goodBeat(iCurrentBeat) = 0;
%             continue;
%         end
        %% Criterion 1: more peaks than usual
        % a normal beat has 1 to 3 peaks
        [~,~,peakWidth,~] = findpeaks(beats(:,iCurrentBeat));
        expectedPeakWidth = 0.02 * fs;
        if (length(peakWidth(peakWidth>expectedPeakWidth)) > 3)
            goodBeat(iCurrentBeat) = 0;
            continue;
        end
        %% Criterion 2: more than 15% of beat below zero
        % if more than 15% of values of the beat are lower than zero after
        % drift removal, beat is excluded
        if mean(beats(:,iCurrentBeat) < 0) > 0.15
            goodBeat(iCurrentBeat) = 0;
            continue;
        end
        %% Criterion 3: maximum height of negative values
        % if highest negative value has absolute value of over 10% of
        % highest positive value, beat is excluded
        if abs(min(beats(:,iCurrentBeat))) > max(beats(:,iCurrentBeat))
            goodBeat(iCurrentBeat) = 0;
            continue;
        end
        
%         %% Criterion 7: outlier in middle of beat
%         % if more than 50% of values in the middle section of the beat
%         % extend either farther than 1.75 or lower than 0.1 of mean beat,
%         % the beat is excluded
%         % this Criterion is used for the remaining beats only.
%         currentBeat = beats(:,iCurrentBeat);
%         meanBeat = mean(beats,2);
%         middleOfMeanBeat = meanBeat(round(end/3):round(2*end/3));
%         middleOfCurrentBeat = currentBeat(round(end/3):round(2*end/3));
%         
%         if mean( or( (middleOfCurrentBeat > middleOfMeanBeat.*2 ), ...
%                      (middleOfCurrentBeat < middleOfMeanBeat.*(-10)) ...
%                    )...
%                ) > 0.5
%             goodBeat(iCurrentBeat) = 0;
%             continue;
%         end
        
    end
    
    %% Removing of outliers of non-artifact beats
    % After exclusion of beats with a non-beat morphology (artifacts) the
    % outliers are removed
    goodBeat(goodBeat == 0) = [];
    goodBeatsSoFar = beats(:,goodBeat);

    quantile25Beat = quantile(goodBeatsSoFar,0.25,2);
    quantile75Beat = quantile(goodBeatsSoFar,0.75,2);
    iqrBeat = quantile75Beat-quantile25Beat;
    
    for iCurrentBeat = 1:size(goodBeatsSoFar,2)
        %% Criterion 1: outlier further than 1.5 times iqr
        % if more than 10% of values of the beat extend farther than 1.5
        % times the difference of 25% and 75% quantiles (i.e. are outliers)
        % the beat is excluded
        if mean(beats(:,iCurrentBeat) < quantile25Beat - iqrBeat.*1.5) > 0.1
            goodBeat(iCurrentBeat) = 0;
            continue;
        end
        if mean(beats(:,iCurrentBeat) > quantile75Beat + iqrBeat.*1.5) > 0.1
            goodBeat(iCurrentBeat) = 0;
            continue;
        end
    end
%     %% Removing further outliers of non-artifact beats
%     % If there are many bad beats, further outliers may be skipped. Thus
%     % the next criterion is applied after removing bad beats again.
%     goodBeat(goodBeat == 0) = [];
%     goodBeatsSoFar = beats(:,goodBeat);
%     medianBeat = median(goodBeatsSoFar,2);
%     for iCurrentBeat = 1:size(goodBeatsSoFar,2)    
%         %% Criterion 2: single high beats
%         % if more than 10% of values of the beat extend farther than 1.5
%         % times the corresponding values of the median beat the beat is
%         % excluded. Only the middle section is regarded for this Criterion
%         % (outer parts contain both zero-passings (minima) and are thus to
%         % be ignored)
%         beatLength = size(goodBeatsSoFar,1);
%         % Area to look in
%         areaMask = round(beatLength/3):round(beatLength*2/3);
%         currentBeat = beats(:,iCurrentBeat);
%         if mean( currentBeat(areaMask) > medianBeat(areaMask).*1.5 ) > 0.1
%             goodBeat(iCurrentBeat) = 0;
%             continue;
%         end
%     end

    %% plots for debugging
    if DEBUG
        t = 0 : 1/fs : (size(beats,1)-1)/fs;
        figure;
        for iCurrentBeat = 1:size(beats,2)
            if goodBeat(iCurrentBeat) == 0
                plot3(t,iCurrentBeat*ones(size(t)),beats(:,iCurrentBeat),'r-');
                hold on;
            else
                plot3(t,iCurrentBeat*ones(size(t)),beats(:,iCurrentBeat),'k-');
                hold on;
            end

        end
    end
    

    %% Use mask to return only good beats
    goodBeat(goodBeat == 0) = [];
    goodBeats = beats(:,goodBeat);
    quality = size(goodBeats,2)/size(beats,2);
    %% If all beats have been excluded, return an empty beat (only zeros)
    if quality == 0
        goodBeats = NaN(size(beats,1),1);
    end
    
    
    %% continued: plots for debugging
    if DEBUG
        view(60,30);
        xlabel('Time [s]');
        ylabel('Beat number');
        zlabel('Amplitude [a.u.]');
        grid on;
        title(['Pt' num2str(iPatient) ' Quality = ' num2str(quality)]);
        figure;
        m = mean(goodBeats,2);
        sd = std(goodBeats,0,2);
        errorbar(m(1:3:end),sd(1:3:end));
        title(['Pt' num2str(iPatient) ' Quality = ' num2str(quality) ' (filtered)']);
    end

end



