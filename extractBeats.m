function [ Beats ] = extractBeats( Data, patient )
%EXTRACTBEATS analyses existing beat detections and returns a struct
%containing single beats as vectors.
%   Parameters:
%       Data (struct)
%           struct containing data to be analysed
%       patient (int)
%           number of current patient
%   Returns:
%       Beats (struct)
%           Struct containing beats
%
% Author: Johann Roth
% Date: 26.11.2015

    % Beat detections from Labchart and Beatscope are merged to gain
    % maximum information. With constant heartrate of 90 or 100 bpm
    % (depending on manufactorer of the pacemaker) artifacts can be removed
    % by searching detections only in a certain time window.

    % fixed paced heartrate (in bpm)
    heartRate = Data.Metadata.heartRate(patient);
    % expected RR-Interval for given heartrate (in samples)
    rr = round(1/(heartRate/60) * 1000);
    % 5% of expected RR-Interval as margin to search for beats in samples
    dr = round(rr*0.05);

    bpStamp = Data.BeatDetections.BsBp.samplestamp;
    ppgCuffStamp = Data.BeatDetections.PpgCuff.samplestamp;
    ppgClipStamp = Data.BeatDetections.PpgClip.samplestamp;



    beatStamp(1) = bpStamp(1);
    % Look for detections in PPG cuff and clip signals around first BP beat
    % detection
    cuffDetec = ppgCuffStamp(logical( (ppgCuffStamp > beatStamp(1)-dr) .* (ppgCuffStamp < beatStamp(1)+dr) ));
    clipDetec = ppgClipStamp(logical( (ppgClipStamp > beatStamp(1)-dr) .* (ppgClipStamp < beatStamp(1)+dr) ));

    if ((length(cuffDetec) == 1) && (length(clipDetec) == 1))
        beatStamp(1) = round(mean([beatStamp(1) cuffDetec clipDetec]));
    elseif ((length(cuffDetec) == 1))
        beatStamp(1) = round(mean([beatStamp(1) cuffDetec]));
    elseif ((length(clipDetec) == 1))
        beatStamp(1) = round(mean([beatStamp(1) cuffDetec]));  
    end

    Beats = 0;
end