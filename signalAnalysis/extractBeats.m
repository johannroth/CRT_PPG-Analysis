function [ beats ] = extractBeats( signal, samplestamps, fs, heartrate, removeDrift )
%EXTRACTBEATS extracts single beats from a signal and given detection
% stamps.
%   Parameters:
%       signal (vector [Nx1])
%           vector containing the signal (length N samples)
%       samplestamps (vector [Mx1])
%           stamps of detected beats (amount M of detected beats)
%       fs (double)
%           sample frequency of the given signal
%       heartrate (double)
%           expected heartrate in signal (determins the length of a beat)
%       removeDrift (bool)
%           bool to specify if baseline and drift should be removed
%   Returns:
%       beats (matrix [LxM])
%           matrix containing single beats (every column is a single beat),
%           length L of a beat is calculated from expected heart rate
%
% Author: Johann Roth
% Date: 07.12.2015

    %% Calculation of length of a beat
    % a margin of 1.2 is multiplied to the expected beat length to be able
    % to detect beats around the possibly inprecise detection stamp.
    MARGIN = 1.2;
    BEATLENGTH = round( 60/heartrate * fs * MARGIN );
    MINAREA = round( 60/heartrate * fs * 0.05 );
    
    %% Initialize output matrix
    beats = zeros(BEATLENGTH, length(samplestamps));

    %% Loop through all sample stamps
    for i = 1:length(samplestamps)

        %% Look for local minimum around detected beat
        [minValue1,minDetection1] = min(signal( samplestamps(i)-MINAREA : samplestamps(i)+MINAREA ));
        minSampleStampAbs1 = samplestamps(i)-MINAREA + minDetection1-1;

        %% Define start and end sample to extract the beat
        beatStart = minSampleStampAbs1 - round( 60/heartrate * fs * (MARGIN-1)/2 );
        beatEnd = beatStart + BEATLENGTH - 1;

        minSampleStampRel1 = minSampleStampAbs1-beatStart;

        %% Look for local minimum around end of detected beat
        [minValue2,minDetection2] = min(signal( beatEnd - 2*MINAREA : beatEnd ));
        minSampleStampRel2 = beatEnd-2*MINAREA + minDetection2-1 - beatStart;
        %% Save selected beat
        % parameter removeDrift specifies, if baseline and drift is
        % removed. Drift is removed by removing linear component defined by
        % linear line between the minima in the beginning and in the end of
        % a beat. Equation: y = (x-x1)* (y2-y1)/(x2-x1) + y1
        x = 1:BEATLENGTH;
        if ~removeDrift
            beats(:,i) = signal(beatStart:beatEnd);
        else
            beats(:,i) = signal(beatStart:beatEnd) - minValue1 - ...
                (x' - minSampleStampRel1).*((minValue2-minValue1)/(minSampleStampRel2-minSampleStampRel1));
        end
    end

    %% plot for debugging
    % t = 0 : 1/fs : (size(beats,1)-1)/fs;
    % figure;
    % % for i = 1:size(beats,2)
    % %     plot3(t,i*ones(size(t)),beats(:,i),'k-');
    % %     hold on;
    % % end
    % % view(60,30);
    % % xlabel('Time [s]');
    % % ylabel('Beat number');
    % % zlabel('Amplitude [a.u.]');
    % % grid on;
    % plot(t,beats);
    % hold on;
    % plot(t(minSampleStampRel2+1),minValue2,'c*');
    % hold on;
    % plot(t(minSampleStampRel1+1),minValue1,'c*');
    % hold on;
    % plot( t,(x-minSampleStampRel1).*((minValue2-minValue1)/(minSampleStampRel2-minSampleStampRel1))+minValue1 );
    % figure;
    % plot( t, beats  - minValue1 - (x' - minSampleStampRel1).*((minValue2-minValue1)/(minSampleStampRel2-minSampleStampRel1)) );

end

