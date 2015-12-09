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
%       goodBeats (matrix [LxM])
%           matrix containing only good single beats (every column is a
%           single beat), length L of a beat is calculated from expected
%           heart rate
%       quality (double 0...1)
%           percentage of kept beats
%
% Author: Johann Roth
% Date: 07.12.2015

    DEBUG = false;

    %% Calculate overall beat statistics

    quantile25Beat = quantile(beats,0.25,2);
    quantile75Beat = quantile(beats,0.75,2);
    iqrBeat = quantile75Beat-quantile25Beat;
    
    expectedRR = 60/heartrate; % in s
    expectedBeatLength = round(expectedRR * fs); % in samples
    margin = round(expectedBeatLength*0.1);

    %% Initialize mask to remove beats
    goodBeat = 1:size(beats,2);
    % use 'goodBeat(i) = 0' to mark a bad beat

    %% Loop through all beats to exclude bad beats (6 Criteria)
    for i = 1:size(beats,2)
        %% Criteria to determine if a beat is bad
        % each criterion has to be false to allow a beat to be passed on
        % as good beat.
        
        %% Criterion 1: outlier further than 1.5 times iqr
        % if more than 20% of values of the beat extend farther than 1.5
        % times the difference of 25% and 75% quantiles (i.e. are outliers)
        % the beat is excluded
        if mean(beats(:,i) < quantile25Beat - iqrBeat.*1.5) > 0.2
            goodBeat(i) = 0;
            continue;
        end
        if mean(beats(:,i) > quantile75Beat + iqrBeat.*1.5) > 0.2
            goodBeat(i) = 0;
            continue;
        end
        %% Criterion 2: local minimum around beginning of beat
        % the first minimum may not be after a certain point in the beat
        [~, index] = min(beats(1:end/2,i));
        if (index > 2*margin)
            goodBeat(i) = 0;
            continue;
        end
        %% Criterion 3: local minimum around end of beat
        % the second minimum may not be before a certain point in the
        % beat
        [~, index] = min(beats(end/2:end,i));
        if ( index < (length(beats(end/2:end,i))-1.6*margin) )
            goodBeat(i) = 0;
            continue;
        end
        %% Criterion 4: more peaks than usual
        % a normal beat has 1 to 3 peaks
        [~,~,peakWidth,~] = findpeaks(beats(:,i));
        expectedPeakWidth = 0.02 * fs;
        if (length(peakWidth(peakWidth>expectedPeakWidth)) > 3)
            goodBeat(i) = 0;
            continue;
        end
        %% Criterion 5: more than 15% of beat below zero
        % if more than 15% of values of the beat are lower than zero after
        % drift removal, beat is excluded
        if mean(beats(:,i) < 0) > 0.15
            goodBeat(i) = 0;
            continue;
        end
        %% Criterion 6: maximum height of negative values
        % if highest negative value has absolute value of over 10% of
        % highest positive value, beat is excluded
        if abs(min(beats(:,i))) > max(beats(:,i))
            goodBeat(i) = 0;
            continue;
        end
        
    end

    %% plots for debugging
    if DEBUG
        t = 0 : 1/fs : (size(beats,1)-1)/fs;
        figure;
        for i = 1:size(beats,2)
            if goodBeat(i) == 0
                plot3(t,i*ones(size(t)),beats(:,i),'r-');
                hold on;
            else
                plot3(t,i*ones(size(t)),beats(:,i),'k-');
                hold on;
            end

        end
    end
    

    %% Use mask to return only good beats
    goodBeat(goodBeat == 0) = [];
    goodBeats = beats(:,goodBeat);
    quality = size(goodBeats,2)/size(beats,2);
    
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



