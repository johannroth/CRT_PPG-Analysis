function [ beats ] = extractBeats( signal, samplestamps, fs, heartrate )
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
%   Returns:
%       beats (vector [LxM])
%           matrix containing single beats (every column is a single beat),
%           length L of a beat is calculated from expected heart rate
%
% Author: Johann Roth
% Date: 07.12.2015

%% Calculation of length of a beat
MARGIN = 1.05;
BEATLENGTH = round( 60/heartrate * fs * MARGIN );
MINAREA = round( 60/heartrate * fs * 0.05 );
beats = zeros(BEATLENGTH, length(samplestamps));

%% Loop through all sample stamps
for i = 1:length(samplestamps)
    
    %% Look for local minimum around detected beat
    [~,iDetection] = min(signal( samplestamps(i)-MINAREA : samplestamps(i)+MINAREA ));
    minSampleStamp = samplestamps(i)-MINAREA + iDetection-1;
    
    %% Save beat to beats matrix
    beatStart = minSampleStamp - round( 60/heartrate * fs * (MARGIN-1)/2 );
    beatEnd = beatStart + BEATLENGTH - 1;
    beats(:,i) = signal(beatStart:beatEnd);
end

end

