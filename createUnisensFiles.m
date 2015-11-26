%% This script creates Unisens files from converted matlab data
% This script uses converted matlab data (import with readRawData.m,
% conversion with convertRawData.m)
%
% Data has to be read from ../data/matlab/Pt##/Pt##converted.mat and will
% be saved to ../data/unisens/Pt##/.
%
% Additional Meta-Data from ../data/raw/Patient_data.xlsx is also included
% and added to unisens files
%
% Author: Johann Roth
% Date: 26.11.2015

if ~exist('debugFlag','var')
    debugFlag = 0;
end

patient = 1:6;
unisensPath = '../data/unisens/';

%% If Unisens files already exist, ask if they should be overwritten
% else the script is canceled.
if exist([unisensPath 'Pt01'], 'dir')
    if input('Unisens files already exist. Overwrite? [1/0]\n')
        fprintf('Deleting old unisens files');
        for i = 1:size(patient,2)
            patientId = ['Pt0' int2str(i)];
            try
                rmdir(['../data/unisens/' patientId],'s')
            catch
                fprintf('Could not remove all folders.\n');
            end
        end
        fprintf('..................\n');
    else
        fprintf('Script canceled.............................\n');
        return;
    end
end
%% Loop through all patients and create Unisens files
fprintf('Creating Unisens files......................\n');
for i = 1:size(patient,2)
%     fprintf('............................................\n');
%     fprintf('Processing Pt0x.............................\n');
    fprintf(['Processing Pt0' int2str(i) '...']); 
    
    patientId = ['Pt0' int2str(i)];
    patientDataFile = ['../data/matlab/' patientId '/' patientId '_converted.mat'];
    load(patientDataFile);
    
    %% Find beginning and end of measurement in LoggerData
    % marked by START and STOP flag
    
    temp.dataStart = LoggerData.sampleStamps(strcmp(LoggerData.flag, 'START'));
    temp.dataEnd = LoggerData.sampleStamps(strcmp(LoggerData.flag, 'STOP'));
    
    %% Set correct start time in unisens file
    unisensStartTime = java.util.Date;
    matlabStartTime = LabChartData.startTime + datenum(0,0,0,0,0,temp.dataStart/LabChartData.samplerate(1));
    % d = u/86400 + 719529 gives seconds since 1.1.1970 0:00
    % factor 1000 to get time in milliseconds
    % 1 hour has to be subtracted to get to convert timezone correctly
    % 1 hour = 3600s = 3600*1000ms
    % backwards: matlabtime = datetime(unixtime, 'ConvertFrom',
    % 'posixtime')?
    setTime(unisensStartTime,( datenum(matlabStartTime) - 719529 ) * 86400 * 1000 - 3600000);
    writeData.starttime = unisensStartTime;
    
    clear unisensStartTime matlabStartTime;
    
    fprintf('......');
    
    %% Process LabChart Data
    % PPG Cuff signal (values multiplied by 1000 to get values in mV)
    temp.PpgCuff_full = LabChartData.data(LabChartData.datastart(1):LabChartData.dataend(1));
    writeData.signals.PpgCuff.data = temp.PpgCuff_full(temp.dataStart:temp.dataEnd)*1000;
    writeData.signals.PpgCuff.content = 'PPG';
    writeData.signals.PpgCuff.physicalUnit = 'mV';
    writeData.signals.PpgCuff.sampleRate = LabChartData.samplerate(1);
    if debugFlag
        figure;
        subplot(3,1,1);
        plot(temp.PpgCuff_full, 'b-');
        hold on;
        plot([zeros(1,temp.dataStart-1) writeData.signals.PpgCuff.data], 'r--');
        title([patientId ' - PPG_{Cuff}']);
        % legend('Cuff_{full}','Cuff_{cropped}','Location','northwest');
    end
    clear temp.PpgCuff_full;
    
    % PPG Clip signal (values multiplied by 1000 to get values in mV)
    temp.PpgClip_full = LabChartData.data(LabChartData.datastart(2):LabChartData.dataend(2));
    writeData.signals.PpgClip.data = temp.PpgClip_full(temp.dataStart:temp.dataEnd)*1000;
    writeData.signals.PpgClip.content = 'PPG';
    writeData.signals.PpgClip.physicalUnit = 'mV';
    writeData.signals.PpgClip.sampleRate = LabChartData.samplerate(2);
    if debugFlag
        subplot(3,1,2);
        plot(temp.PpgClip_full, 'b-');
        hold on;
        plot([zeros(1,temp.dataStart-1) writeData.signals.PpgClip.data], 'r--');
        title([patientId ' - PPG_{Clip}']);
        % legend('Clip_{full}','Clip_{cropped}','Location','northwest');
    end    
    clear temp.PpgClip_full;
    
    % Analog finger BP signal from Finometer
    temp.BpAnalog_full = LabChartData.data(LabChartData.datastart(3):LabChartData.dataend(3));
    writeData.signals.BpAnalog.data = temp.BpAnalog_full(temp.dataStart:temp.dataEnd);
    writeData.signals.BpAnalog.content = 'BP';
    writeData.signals.BpAnalog.physicalUnit = 'mmHg';
    writeData.signals.BpAnalog.sampleRate = LabChartData.samplerate(3);
    
    if debugFlag
        subplot(3,1,3);
        plot(temp.BpAnalog_full, 'b-');
        hold on;
        plot([zeros(1,temp.dataStart-1) writeData.signals.BpAnalog.data], 'r--');
        title([patientId ' - BP_{analog}']);
        % legend('BP_{analog, full}','BP_{analog, cropped}','Location','northwest');
    end    
    clear temp.BpAnalog_full;
    
    % PPG beat detections are also imported from LabChart data. BP beat
    % detection has been done by BeatScope and is exported form BeatScope
    % beats data.
    % Detections from PPG Clip and PPG Cuff are stored seperately
    
    % PPG Cuff
    temp.detectionPpgCuffMask = logical( (LabChartData.com(:,3) >= temp.dataStart) .* ...   % data after beginning
                                         (LabChartData.com(:,3) <= temp.dataEnd) .* ...     % data before end
                                         (LabChartData.com(:,1)==1)  ...                    % data for channel 1
                                        );
    writeData.annotations.DetectionPpgCuff.data = LabChartData.com(temp.detectionPpgCuffMask,3)-temp.dataStart;
    writeData.annotations.DetectionPpgCuff.marker = 'B';
    writeData.annotations.DetectionPpgCuff.sampleRate = 1000;
    
    % PPG Clip
    temp.detectionPpgClipMask = logical( (LabChartData.com(:,3) >= temp.dataStart) .* ...   % data after beginning
                                         (LabChartData.com(:,3) <= temp.dataEnd) .* ...     % data before end
                                         (LabChartData.com(:,1)==2)  ...                    % data for channel 2
                                        );
    writeData.annotations.DetectionPpgClip.data = LabChartData.com(temp.detectionPpgClipMask,3)-temp.dataStart;
    writeData.annotations.DetectionPpgClip.marker = 'B';
    writeData.annotations.DetectionPpgClip.sampleRate = 1000;
    
    fprintf('.....');
    
    %% Process BeatScope wave data
    % Digital finger BP signal from Finometer
    % Digital signal is shifted according to calculated timeshift to match
    % analog BP signal and PPG signals.
    temp.BpDigital_full = BsWaveData.PressureFINmmHg';
    temp.BpDigitalMask = logical( (BsWaveData.sampleStamps >= (temp.dataStart - BsWaveData.timeshift*1000)) .* ...
                                  (BsWaveData.sampleStamps <= (temp.dataEnd - BsWaveData.timeshift*1000)) );
    writeData.signals.BpDigital.data = temp.BpDigital_full(temp.BpDigitalMask);
    writeData.signals.BpDigital.content = 'BP';
    writeData.signals.BpDigital.physicalUnit = 'mmHg';
    writeData.signals.BpDigital.sampleRate = 200;
     
    clear temp.BpDigital_full temp.BpDigitalMask;
    
    fprintf('.....');
    
    %% Process BeatScope Beats data
    % Contains several calculated values for BP signal
    % Beats data is shifted backwards corresponding to calculated
    % timeshift. Timeshift thus has to be added to move values back in
    % time.
    temp.BpBeatsStamps_shifted = BsBeatsData.sampleStamps + BsWaveData.timeshift*1000;
    temp.BpBeatsMask = logical( (temp.BpBeatsStamps_shifted >= (temp.dataStart)) .* ...
                                (temp.BpBeatsStamps_shifted <= (temp.dataEnd)) ...
                              );
    temp.BpBeatsStamps = temp.BpBeatsStamps_shifted(temp.BpBeatsMask) - temp.dataStart;
    
    writeData.values.BsBpSystolic.comment = 'Value calculated in Beatscope';
    writeData.values.BsBpSystolic.content = 'BP';
    writeData.values.BsBpSystolic.sampleRate = 1000;
    writeData.values.BsBpSystolic.physicalUnit = 'mmHg';
    writeData.values.BsBpSystolic.data = [ temp.BpBeatsStamps BsBeatsData.SystolicmmHg(temp.BpBeatsMask) ];
    
    writeData.values.BsBpDiastolic.comment = 'Value calculated in Beatscope';
    writeData.values.BsBpDiastolic.content = 'BP';
    writeData.values.BsBpDiastolic.sampleRate = 1000;
    writeData.values.BsBpDiastolic.physicalUnit = 'mmHg';
    writeData.values.BsBpDiastolic.data = [ temp.BpBeatsStamps BsBeatsData.DiastolicmmHg(temp.BpBeatsMask) ];
    
    writeData.values.BsBpMean.comment = 'Value calculated in Beatscope';
    writeData.values.BsBpMean.content = 'BP';
    writeData.values.BsBpMean.sampleRate = 1000;
    writeData.values.BsBpMean.physicalUnit = 'mmHg';
    writeData.values.BsBpMean.data = [ temp.BpBeatsStamps BsBeatsData.MeanmmHg(temp.BpBeatsMask) ];
    
    writeData.values.BsHeartrate.comment = 'Value calculated in Beatscope';
    writeData.values.BsHeartrate.content = 'Heartrate';
    writeData.values.BsHeartrate.sampleRate = 1000;
    writeData.values.BsHeartrate.physicalUnit = 'bpm';
    writeData.values.BsHeartrate.data = [ temp.BpBeatsStamps BsBeatsData.Heartratebpm(temp.BpBeatsMask) ];
    
    writeData.values.BsStrokeVolume.comment = 'Value calculated in Beatscope';
    writeData.values.BsStrokeVolume.content = 'Volume';
    writeData.values.BsStrokeVolume.sampleRate = 1000;
    writeData.values.BsStrokeVolume.physicalUnit = 'ml';
    writeData.values.BsStrokeVolume.data = [ temp.BpBeatsStamps BsBeatsData.StrokeVolumeml(temp.BpBeatsMask) ];
    
    writeData.values.BsLvet.comment = 'Value calculated in Beatscope';
    writeData.values.BsLvet.content = 'Time';
    writeData.values.BsLvet.sampleRate = 1000;
    writeData.values.BsLvet.physicalUnit = 'ms';
    writeData.values.BsLvet.data = [ temp.BpBeatsStamps BsBeatsData.LVETms(temp.BpBeatsMask) ];
    
    writeData.values.BsPulseInterval.comment = 'Value calculated in Beatscope';
    writeData.values.BsPulseInterval.content = 'Time';
    writeData.values.BsPulseInterval.sampleRate = 1000;
    writeData.values.BsPulseInterval.physicalUnit = 'ms';
    writeData.values.BsPulseInterval.data = [ temp.BpBeatsStamps BsBeatsData.PulseIntervalms(temp.BpBeatsMask) ];
    
    writeData.values.BsMaximumSlope.comment = 'Value calculated in Beatscope';
    writeData.values.BsMaximumSlope.content = 'MaximumSlope';
    writeData.values.BsMaximumSlope.sampleRate = 1000;
    writeData.values.BsMaximumSlope.physicalUnit = 'mmHg/s';
    writeData.values.BsMaximumSlope.data = [ temp.BpBeatsStamps BsBeatsData.MaximumSlopemmHgs(temp.BpBeatsMask) ];
    
    writeData.values.BsCardiacOutput.comment = 'Value calculated in Beatscope';
    writeData.values.BsCardiacOutput.content = 'CardiacOutput';
    writeData.values.BsCardiacOutput.sampleRate = 1000;
    writeData.values.BsCardiacOutput.physicalUnit = 'l/min';
    writeData.values.BsCardiacOutput.data = [ temp.BpBeatsStamps BsBeatsData.CardiacOutputlmin(temp.BpBeatsMask) ];
    
    writeData.values.BsTpr.comment = 'Value calculated in Beatscope';
    writeData.values.BsTpr.content = 'TotalPeripheralResistance';
    writeData.values.BsTpr.sampleRate = 1000;
    writeData.values.BsTpr.physicalUnit = 'dyn*s/cm^5';
    writeData.values.BsTpr.data = [ temp.BpBeatsStamps BsBeatsData.TPRdynscm5(temp.BpBeatsMask) ];
    
    % Annotations for Beatscope beat detection
    writeData.annotations.DetectionBsBp.data = temp.BpBeatsStamps;
    writeData.annotations.DetectionBsBp.marker = 'B';
    writeData.annotations.DetectionBsBp.sampleRate = 1000;

    fprintf('.....');
    
    %% Process CRT-Logger annotations
    % Annotation marker cannot be set individually for every event, switch
    % in stimulation mode is marked by the A or V (respectively for AV and
    % VV mode. For the actual values check stimulationModeAV and
    % stimulationModeVV entries (as values).
    temp.ModeSwitchAvMask = strcmp(LoggerData.flag, 'AV');
    temp.ModeSwitchAvStamps = LoggerData.sampleStamps(temp.ModeSwitchAvMask)-temp.dataStart;
    writeData.annotations.StimulationModeSwitchVv.data = temp.ModeSwitchAvStamps;
    writeData.annotations.StimulationModeSwitchVv.marker = 'A';
    writeData.annotations.StimulationModeSwitchVv.sampleRate = 1000;
    
    temp.ModeSwitchVvMask = strcmp(LoggerData.flag, 'VV');
    temp.ModeSwitchVvStamps = LoggerData.sampleStamps(temp.ModeSwitchVvMask)-temp.dataStart;
    writeData.annotations.StimulationModeSwitchAv.data = temp.ModeSwitchVvStamps;
    writeData.annotations.StimulationModeSwitchAv.marker = 'V';
    writeData.annotations.StimulationModeSwitchAv.sampleRate = 1000;
    
    % Generate value entries for AV and VV mode switch (any comments are
    % deleted)
    writeData.values.StimulationModeAV.comment = 'Programmed AV-Delay';
    writeData.values.StimulationModeAV.content = 'AV-Delay';
    writeData.values.StimulationModeAV.sampleRate = 1000;
    writeData.values.StimulationModeAV.physicalUnit = 'ms';
    temp.ModeSwitchAvValues = str2double(LoggerData.flagText(temp.ModeSwitchAvMask));
    writeData.values.StimulationModeAV.data = [ temp.ModeSwitchAvStamps temp.ModeSwitchAvValues ];
    
    writeData.values.StimulationModeVV.comment = 'Programmed VV-Delay';
    writeData.values.StimulationModeVV.content = 'VV-Delay';
    writeData.values.StimulationModeVV.sampleRate = 1000;
    writeData.values.StimulationModeVV.physicalUnit = 'ms';
    temp.ModeSwitchVvValues = str2double(LoggerData.flagText(temp.ModeSwitchVvMask));
    writeData.values.StimulationModeVV.data = [ temp.ModeSwitchVvStamps temp.ModeSwitchVvValues ];
    
    clear temp.ModeSwitchAvValues temp.ModeSwitchAvMask temp.ModeSwitchAvStamps
    clear temp.ModeSwitchVvValues temp.ModeSwitchVvMask temp.ModeSwitchVvStamps
    
    fprintf('...OK\n');
    
    %% Create Unisens file
    unisens_converter(unisensPath,patientId,writeData);
end
% clear BsBeatsData BsWaveData i LabChartData LoggerData patient patientDataFile patientId temp unisensPath writeData;

fprintf('Done!.......................................\n');