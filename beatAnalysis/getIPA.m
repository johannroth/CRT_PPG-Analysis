function [ ipa ] = getIPA( beat, slope )
%GETIPA returns the inflection point area. The inflection point area is
% defined as quotient of both partial areas below pulse wave devided by the
% inflection point
%   Parameters:
%       beat (vector [Lx1])
%           single beat with a length of L samples
%       slope (vector [Lx1])
%           derivate of the single beat with a length of L samples
%       fs (scalar)
%           sampling frequency of the signals
%   Returns:
%       ipa (scalar)
%           inflection point area [a.u.]
%
% [1]   Wang, L., Pickwell-Macpherson, E., Liang, Y. P., & Zhang, Y. T.
%       (2009). Noninvasive cardiac output estimation using a novel
%       photoplethysmogram index. In Conference proceedings : ... Annual
%       International Conference of the IEEE Engineering in Medicine and
%       Biology Society. IEEE Engineering in Medicine and Biology Society.
%       Conference (Vol. 2009, pp. 1746–1749).
%       doi:10.1109/IEMBS.2009.5333091
%
% Author: Johann Roth
% Date: 14.12.2015

if isnan(beat(1))
    ipa = nan;
else
    %% Get start and end of the beat (minima)
    % look for minima in the first and last 20% of the beat (expected position of
    % first minimum.
    beatBackwards = flipud(beat);
    [ ~, iMin1] = min( beat(1:round(end*0.2)) );
    [ ~, iMin2] = min( beatBackwards(1:round(end*0.2)) );
    iMin2 = length(beat) - iMin2 + 1;
    [~, iMax] = max(beat);
    
    %% Calculate zero crossings in slope signal
    % in zeroCrossings the stamps right before the zero crossing are
    % saved.
    t1 = slope(1:end-1);
    t2 = slope(2:end);
    tt = t1.*t2;
    zeroCrossings = find(tt < 0);
    
    %% Check if beat curve has a diastolic maximum
    % search for zero crossing in slope between systolic maximum and before
    [pks, locs, w, ~] = findpeaks(slope);
    locationMask = and( locs > iMax, locs < length(beat) * 0.7);
    widthMask = w > 5;
    
    locs = locs(and(locationMask,widthMask));
    pks = pks(and(locationMask,widthMask));
    % if there is no prominent maximum in slope, there is no visible
    % inflection point
    if isempty(pks)
        ipa = nan;
        return;
    else
        if pks(1) > 0 % there is a real diastolic maximum
            locationMask = and( zeroCrossings > iMax, zeroCrossings < locs(1));
            relevantZeroCrossings = zeroCrossings(locationMask);
            ip = relevantZeroCrossings(1);
        else % no diastolic maximum
            [~,indexMaxPeak] = max(pks);
            ip = locs(indexMaxPeak);
        end
    end
    
    %% Calculate area under the curve
    % using trapezoidal method
    ipa = trapz(beat(ip:iMin2))/trapz(beat(iMin1:ip));
end
% 
% 
% t = 0:1/fs:(length(beat)-1)/fs;
% figure;
% plot(t,beat);
% hold on;
% plot(t,slope*10);
% 
% plot(t(iMin1), beat(iMin1),'ro');
% plot(t(iMin2), beat(iMin2),'ro');
% plot(t(iMax), beat(iMax),'ro');
% plot(t, zeros(1,length(t)) ,'k:');
% plot(t(locs), beat(locs),'bx');
% plot(t(ip),beat(ip),'rs');

end

