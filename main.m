%% Main script for CRT PPG analysis
%
%
% Author: Johann Roth
% Date: 26.11.2015

clear;

for patient = 6
    fprintf(['Computing data of patient ' num2str(patient) '.\n']);
    
    %% Import data
    
    [Data.Signals, Data.StimulationModes, Data.BsValues, Data.BeatDetections] = extractFromUnisens(patient);
    
    importPatientMetadata;
    
    %% Preprocessing
    
    % Remove powerline artifacts at 50 Hz
    
%     d = designfilt('bandstopiir','FilterOrder',2, ...
%                    'HalfPowerFrequency1',49,'HalfPowerFrequency2',51, ...
%                    'DesignMethod','butter','SampleRate',1000);
%     ppgCuff_filtered = filtfilt(d,Data.Signals.PpgCuff.data);
%     figure;
%     plot(Data.Signals.PpgCuff.data, 'b-');
%     hold on;
%     plot(ppgCuff_filtered, 'r--');
    
    % Heart rate is constant at 90 or 100 bpm (depending on manufactorer of
    % the pacemaker), i.e. a constant frequency of 1.5 to 1.67 Hz. Lower
    % frequencies equal drift of baseline or breathing. In adults a
    % frequency of breathing of about 12 to 18 breath cycles per minute is
    % to be expected (http://flexikon.doccheck.com/de/Atemfrequenz), i.e.
    % frequencies of 0.2 to 0.3 Hz.
    
    % Highpass filter with edge frequendy of 0.5 Hz to remove DC-component
%     fs = 1000;
%     [b,a] = butter(3, 0.5*2/fs, 'high');
% %     freqz(b,a);
%     
%     ppgCuff_filtered = filtfilt(b,a,Data.Signals.PpgCuff.data);
%     figure;
%     plot(Data.Signals.PpgCuff.data, 'b-');
%     hold on;
%     plot(ppgCuff_filtered, 'r--');

    % filtered data
    ppgCuff = Data.Signals.PpgCuff.data;
    ppgClip = Data.Signals.PpgClip.data;
    
    %% Extraction of single beats
    
    % Beat detections from Labchart and Beatscope are merged to gain
    % maximum information. With constant heartrate of 90 or 100 bpm
    % (depending on manufactorer of the pacemaker) artifacts can be removed
    % by searching detections only in a certain time window.
    
    % fixed paced heartrate (in bpm)
    heartRate = PopulationData.Data.heartRate(patient);
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
    
    clear bpStamp ppgCuffStamp ppgClipStamp
    
    %%
    
    
%     clear Data;
end

fprintf('Done!\n');