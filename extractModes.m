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
%           AV.toRef / AV.fromRef (matrices of doubles [3xN])
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

AV.refInterval = Data.Metadata.referenceAV(iPatient);
VV.refInterval = 0;


end

