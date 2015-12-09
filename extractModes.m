function [ AV, VV ] = extractModes( Data, Metadata, iPatient )
%EXTRACTMODES extracts modes and mode changes and returns the information
% bundled in the structs AV and VV for the corresponding stimulation
% parameters
%   Parameters:
%       Data (struct)
%           struct containing imported unisens signals of a patient
%       Metadata (struct)
%           struct containing metadata of all patients
%       iPatient (int)
%           number of the current patient
%   Returns:
%       AV (struct)
%           struct containing used intervals, reference interval and stamps
%           of mode changes to and from reference mode
%
%           AV.refInterval (double)
%               reference interval
%           AV.interval (vector of doubles [1xN])
%            used intervals in current patient (N = number of intervals)
%           AV.ToRef.stamps / AV.FromRef.stamps (matrices of doubles [3xN])
%               matrices containing samplestamps of mode changes (either from
%               test interval to reference or from reference to test interval).
%               The columns contain 3 mode changes for each of the N intervals.
%
%       VV (struct)
%           struct containing used intervals, reference interval and stamps
%           of mode changes to and from reference mode. Analog to VV
%           stimulation modes.
%
% Author: Johann Roth
% Date: 09.12.2015

%% Extract reference intervals
AV.refInterval = Metadata.referenceAV(iPatient);
VV.refInterval = 0;

%% Extract all other intervals
% Initialize interval vectors
AV.interval = zeros(1,20);
VV.interval = zeros(1,20);
avIndex=1;
vvIndex=1;
for avInt = Data.StimulationModes.AV.value'
    if isempty(AV.interval(AV.interval==avInt)) && (avInt ~= AV.refInterval)
        AV.interval(avIndex)=avInt;
        avIndex = avIndex + 1;
    end
end
for vvInt = Data.StimulationModes.VV.value'
    if isempty(VV.interval(VV.interval==vvInt)) && (vvInt ~= VV.refInterval)
        VV.interval(vvIndex)=vvInt;
        vvIndex = vvIndex + 1;
    end
end
% sort by size of the interval and remove zeros
AV.interval = sort(AV.interval(AV.interval ~=0));
VV.interval = sort(VV.interval(VV.interval ~=0));

%% Extract samplestamps of mode changes
% Initialize samplestamp matrices
AV.FromRef.stamps = zeros(3,length(AV.interval));
AV.ToRef.stamps = zeros(3,length(AV.interval));
VV.FromRef.stamps = zeros(3,length(VV.interval));
VV.ToRef.stamps = zeros(3,length(VV.interval));

for i = 1:length(AV.interval)
    valueMask = Data.StimulationModes.AV.value == AV.interval(i);
    samplestampAV = Data.StimulationModes.AV.samplestamp(valueMask);
    AV.FromRef.stamps(:,i) = samplestampAV(1:3);
    
    % for mode change back to reference mode the value mask is shifted
    % backwards for one value. Next samplestamp is always again the
    % reference interval.
    toRefValueMask = logical([0; valueMask(1:end-1)]);
    samplestampAV = Data.StimulationModes.AV.samplestamp(toRefValueMask);
    AV.ToRef.stamps(:,i) = samplestampAV(1:3);
end

for i = 1:length(VV.interval)
    valueMask = Data.StimulationModes.VV.value == VV.interval(i);
    samplestampVV = Data.StimulationModes.VV.samplestamp(valueMask);
    VV.FromRef.stamps(:,i) = samplestampVV(1:3);
    
    % for mode change back to reference mode the value mask is shifted
    % backwards for one value. Next samplestamp is always again the
    % reference interval.
    toRefValueMask = logical([0; valueMask(1:end-1)]);
    samplestampVV = Data.StimulationModes.VV.samplestamp(toRefValueMask);
    VV.ToRef.stamps(:,i) = samplestampVV(1:3);
end




end

