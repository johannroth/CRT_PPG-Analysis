function [ pulseArea ] = getPulseArea( beat )
%GETPULSEAREA returns area under the pulse curve
%   Parameters:
%       beat (vector [Lx1])
%           single beat with a length of L samples
%   Returns:
%       pulseArea (scalar)
%           area of beat in [a.u.]
%
% Author: Johann Roth
% Date: 14.12.2015

if isnan(beat(1))
    pulseArea = nan;
else
    beatBackwards = flipud(beat);
    %% Get start and end of the beat (minima)
    % look for minima in the first and last 20% of the beat (expected position of
    % first minimum.
    [ ~, iMin1] = min( beat(1:round(end*0.2)) );
    [ ~, iMin2] = min( beatBackwards(1:round(end*0.2)) );
    iMin2 = length(beat) - iMin2 + 1;
    
    %% Calculate area under the curve
    % using trapezoidal method
    pulseArea = trapz(beat(iMin1:iMin2));
end

end

