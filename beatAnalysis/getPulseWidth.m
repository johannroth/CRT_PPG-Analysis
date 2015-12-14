function [ pulseWidth ] = getPulseWidth( beat, fs)
%GETPULSEWIDTH returns width of the pulse (as defined and used by [1]
% The width at half height of the beat is used as value for the pulse width 
%   Parameters:
%       beat (vector [Lx1])
%           single beat with a length of L samples
%       fs (scalar)
%           sampling frequency (needed for calculating width in ms)
%   Returns:
%       pulseWidth (scalar)
%           width of beat in [ms]
%
% [1]   Awad, A. a., Haddadin, A. S., Tantawy, H., Badr, T. M., Stout,
%       R. G., Silverman, D. G., & Shelley, K. H. (2007). The relationship 
%       between the photoplethysmographic waveform and systemic vascular
%       resistance. Journal of Clinical Monitoring and Computing, 21(6),
%       365–372. doi:10.1007/s10877-007-9097-5
%
% Author: Johann Roth
% Date: 11.12.2015

if isnan(beat(1))
    pulseWidth = nan;
else
    % extract all values from beat that are higher than 50 % of height. 
    % First and last value are used as points to measure width in between
    
    % outter parts of beat will be removed (as there might be parts of the
    % following or preceeding beat)
    beat = beat(round( length(beat)*0.08 ):round( end-length(beat)*0.08 ));
    beatMax = max(beat);
    
    firstPass = find(beat>beatMax/2,1);
    lastPass = find(beat>beatMax/2,1, 'last');
    
    % width is calculated by subtracting the stamps of the passes. 2 is
    % added to correct the error, that both stamps of passes have values
    % slightly higher than half the height of the beat.
    % (samples/fs = time [s], time [s] * 1000 = time [ms])
    pulseWidth = (lastPass - firstPass + 1) * 1000/fs;
end

end

