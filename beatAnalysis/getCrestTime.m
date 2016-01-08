function [ crestTime ] = getCrestTime( beat, fs)
%GETCRESTTIME returns the crest time, i.e. the time of systolic upstroke
% beginning at diastolic minimum and ending at systolic maximum (as defined
% in [1]). Crest time has a negative correlation with blood pressure [2].
% The width at half height of the beat is used as value for the pulse width 
%   Parameters:
%       beat (vector [Lx1])
%           single beat with a length of L samples
%       fs (scalar)
%           sampling frequency (needed for calculating width in ms)
%   Returns:
%       crestTime (scalar)
%           crest time (= duration of systolic upstroke) in [ms]
%
% [1]   Alty, S. R., Angarita-Jaimes, N., Millasseau, S. C., & Chowienczyk,
%       P. J. (2007). Predicting Arterial Stiffness From the Digital Volume
%       Pulse Waveform. IEEE Transactions on Biomedical Engineering,
%       54(12), 2268–2275. doi:10.1109/TBME.2007.897805
% [2]   Yoon, Y.-Z., & Yoon, G.-W. (2006). Nonconstrained Blood Pressure
%       Measurement by Photoplethysmography. Journal of the Optical Society
%       of Korea, 10(2), 91–95. doi:10.3807/JOSK.2006.10.2.091
%
% Author: Johann Roth
% Date: 15.12.2015

if isnan(beat(1))
    crestTime = nan;
else
    %% first minimum and maximum of beat are calculated
    [ ~, iMin] = min( beat(1:round(end*0.2)) );
    [~, iMax] = max(beat(round(0.2*end):round(0.8*end)));
    iMax = round(length(beat)*0.2)+iMax -1;
    
    
    
    % width is calculated by subtracting the stamps of the passes.
    % (samples/fs = time [s], time [s] * 1000 = time [ms])
    crestTime = (iMax - iMin) * 1000/fs;
end

end

