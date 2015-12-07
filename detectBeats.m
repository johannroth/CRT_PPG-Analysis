function [ detections ] = detectBeats( Data, patient )
%DETECTBEATS analyses existing beat detections and returns a struct
%containing single beats as vectors.
%   Parameters:
%       Data (struct)
%           struct containing data to be analysed
%       patient (int)
%           number of current patient
%   Returns:
%       detections (vector of int)
%           vector containing stamps of beats
%
% Author: Johann Roth
% Date: 01.12.2015
    
    stopFlag = false;

    % Beat detections from Labchart and Beatscope are merged to gain
    % maximum information. With constant heartrate of 90 or 100 bpm
    % (depending on manufactorer of the pacemaker) artifacts can be removed
    % by searching detections only in a certain time window.

    fs = Data.BeatDetections.BsBp.fs;
    
    % fixed paced heartrate (in bpm) and RR-interval (in samples)
    HR = Data.Metadata.heartRate(patient);
    RR = round(60/HR * fs);
    % margin in percent of expected RR-Interval to search for beats
    margin = 0.25;
    % margin in samples
    DR = round(RR*margin);

    Beat.bp = Data.BeatDetections.BsBp.samplestamp;
    Beat.cuff = Data.BeatDetections.PpgCuff.samplestamp;
    Beat.clip = Data.BeatDetections.PpgClip.samplestamp;

    detections = zeros(length(Beat.bp)+length(Beat.cuff)+length(Beat.clip),1);
    
    %% First beat is detected manually from bp detections
    % It has been manually verified that first bp beat is detected
    % correctly in all patients.
    detections(1) = Beat.bp(1);
    % Look for detections in PPG cuff and clip signals around first BP beat
    % detection
    maskCuff = logical( (Beat.cuff > detections(1)-DR) .* (Beat.cuff < detections(1)+DR) );
    cuffDetec = Beat.cuff(maskCuff);
    maskClip = logical( (Beat.clip > detections(1)-DR) .* (Beat.clip < detections(1)+DR) );
    clipDetec = Beat.clip(maskClip);
    
    % if there are other detected beats in the vicinity of the first
    % detection take the mean of the sample
    m = 1;    
    try
        if ( (length(cuffDetec) > 1) || (length(clipDetec) > 1) )
            fprintf('Multiple detections around first beat\n');
        end
        detections(m) = round( mean([clipDetec; detections(1); cuffDetec]) );                  
    catch
        fprintf('Error: Error detecting beats around first beat.\n');
    end
    
    
    
    %% Every following beat is calculated automatically
    m = 2;
    while (m < length(detections) && ~stopFlag)
        lastDet = detections(m-1);
        
        % Look for a beat in expected range from first detection
        maskCuff = logical( (Beat.cuff > lastDet+RR-DR) .* (Beat.cuff < lastDet+RR+DR) );
        maskClip = logical( (Beat.clip > lastDet+RR-DR) .* (Beat.clip < lastDet+RR+DR) );
        maskBp = logical( (Beat.bp > lastDet+RR-DR) .* (Beat.bp < lastDet++RR+DR) );
        cuffDetec = Beat.cuff(maskCuff);
        clipDetec = Beat.clip(maskClip);
        bpDetec = Beat.bp(maskBp);
        
        % If no beat can be found in any of the detection channels extend
        % range to look for detections
        rangeExtension = RR;
        marginExtension = 0;
        while (isempty(cuffDetec)) && (isempty(clipDetec)) && (isempty(bpDetec))
            searchRange = lastDet+RR+rangeExtension;
            searchMargin = DR + marginExtension;
            maskCuff = logical( (Beat.cuff > searchRange-searchMargin) .* (Beat.cuff < searchRange+searchMargin) );
            maskClip = logical( (Beat.clip > searchRange-searchMargin) .* (Beat.clip < searchRange+searchMargin) );
            maskBp = logical( (Beat.bp > searchRange-searchMargin) .* (Beat.bp < searchRange+searchMargin) );
            cuffDetec = Beat.cuff(maskCuff);
            clipDetec = Beat.clip(maskClip);
            bpDetec = Beat.bp(maskBp);
            
            % Range to look for beats is extended (to the expected start of
            % the next beat)
            rangeExtension = rangeExtension + RR;
            % If an extension of range has not been successful the
            % algorithm tries to find a beat that is 180° phase shifted
            if rangeExtension > RR
                rangeExtension = rangeExtension - 0.5*RR;
            end
            if rangeExtension == 30*RR
                stopFlag = true;
                break;
            end
        end
        
        if ((length(cuffDetec) > 1) || (length(clipDetec) > 1) || (length(bpDetec) > 1))
            fprintf('Margin too big, multiple detections!\n');
        end
        detections(m) = round( mean([clipDetec; bpDetec; cuffDetec]) );                     

        m = m + 1;
    end
    
%     % Plot detections and signal for debugging
%     figure;
%     plot(Data.Signals.Bp.data);
%     hold on;
%     plot(detections,40,'c*');
%     
% %     plot(Beat.cuff, 1, 'r*');
% %     plot(Beat.clip, 2, 'g*');
% %     plot(detections, 3, 'c*');
% %     axis([0,2000,-5,10]);
    
end