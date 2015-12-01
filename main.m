%% Main script for CRT PPG analysis
%
%
% Author: Johann Roth
% Date: 26.11.2015

clear;

for patient = 6
    fprintf(['Computing data of patient ' num2str(patient) '.\n']);
    
    %% Import data
    fprintf('..importing unisens data..\n');
    [Data.Signals, Data.StimulationModes, Data.BsValues, Data.BeatDetections] = extractFromUnisens(patient);
    
    Data.Metadata = importPatientMetadata('..\data\raw\Patient_data.xlsx');
    
    %% Preprocessing
    
    % Downsampling to 200 Hz using MATLAB decimate function with a fir
    % filter with a Hamming window and order 30.
    fprintf('..downsampling data..\n');
    Data = downsampleData(Data,200);
    
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
%     ppgCuff = Data.Signals.PpgCuff.data;
%     ppgClip = Data.Signals.PpgClip.data;
%     
%     ppgClipDs = decimate(ppgClip,5,'fir');
%     
%     t = 0:1/1000:(length(ppgClip)-1)/1000;
%     tDs = 0:1/200:(length(ppgClipDs)-1)/200;
%     
%     figure;
%     plot(t,ppgClip,'b-');
%     hold on;
%     plot(tDs,ppgClipDs,'r--');
    
    %% Extraction of single beats
    
    % Beat detections from Labchart and Beatscope are merged to gain
    % maximum information. With constant heartrate of 90 or 100 bpm
    % (depending on manufactorer of the pacemaker) artifacts can be removed
    % by searching detections only in a certain time window.
    
    fprintf('..extracting beats..\n');
    Beats = extractBeats(Data, patient);
    
    %%
    
    
%     clear Data;
end

fprintf('Done!\n');