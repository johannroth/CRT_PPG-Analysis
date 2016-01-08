function [ maxSlope ] = getMaxSlope( beat, slope )
%GETMAXSLOPE returns the maximum slope of the volume pulse signal between
% onset of the curve and systolic maximum
%   Parameters:
%       beat (vector [Lx1])
%           single beat with a length of L samples
%       slope (vector [Lx1])
%           derivate of the single beat with a length of L samples
%   Returns:
%       maxSlope (scalar)
%           maximum slope [a.u.]
%
%
% Author: Johann Roth
% Date: 08.01.2016

%% Plots for debugging and testing the function
% % beat = Results.Pt02.AV.ToRef.PpgCuff.meanBeat{3,2,1}; % nice beat with dias max
% beat = Results.Pt06.VV.ToRef.PpgCuff.meanBeat{3,2,8}; % weird beat
% % beat = Results.Pt02.AV.ToRef.PpgCuff.meanBeat{3,2,2}; % beat with no 2nd max
% % beat = Results.Pt03.AV.FromRef.PpgCuff.meanBeat{3,2,2}; % ugly beat
% slope = getDerivative( beat );
% fs = 200;

if isnan(beat(1))
    maxSlope = nan;
else
    %% Get start and end of the beat (minima)
    % look for minima in the first 20% of the beat (expected position of
    % first minimum).
    [ ~, iMin1] = min( beat(1:round(end*0.2)) );
    [~, iMax] = max(beat(round(0.2*end):round(0.8*end)));
    iMax = round(length(beat)*0.2)+iMax -1;
    
    %% Search maximum slope between first minimum and first maximum
    maxSlope = max(slope(iMin1:iMax));
    %% Plots for debugging and testing the function
%     [maxSlope, iMaxSlope] = max(slope(iMin1:iMax));
%     iMaxSlope = iMin1 + iMaxSlope -1;
end

if length(maxSlope) > 1
    disp(maxSlope);
end

%% Plots for debugging and testing the function
% 
% t = 0:1/fs:(length(beat)-1)/fs;
% figure;
% plot(t,beat);
% hold on;
% plot(t,slope*10);
% disp(maxSlope);
% % % plot(t(iMin1), beat(iMin1),'ro');
% % % plot(t(iMax), beat(iMax),'ro');
% % % plot(t, zeros(1,length(t)) ,'k:');
% plot(t(iMaxSlope), beat(iMaxSlope),'bx');
% plot(t(iMaxSlope), maxSlope*10,'bs');


end

