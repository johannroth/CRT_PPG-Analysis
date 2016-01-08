function [ pulseHeight ] = getPulseHeight( beat )
%GETPULSEHEIGHT returns height of Maximum of the pulse
% Maximum value of a pulse can be used, because minimum value is 0 after
% removal of baseline and drift.
%   Parameters:
%       beat (vector [Lx1])
%           single beat with a length of L samples
%   Returns:
%       pulseHeight (scalar)
%           height of beat in [a.u.]
%
% Author: Johann Roth
% Date: 11.12.2015
pulseHeight = max(beat(round(0.2*end):round(0.8*end)));

end

