%% This script converts raw patient data to prepare unisens export
% This script uses imported raw data (import with readRawData.m), adds
% correct time and sample stamps and calculates shift between analog and
% digital BeatScope data, saved to BsWaveData.timeshift as value in
% seconds.
%
% Data has to be read from ../data/matlab/Pt##/Pt##_raw.mat and will be
% saved to ../data/matlab/Pt##/Pt##_converted.mat
%
% Author: Johann Roth
% Date: 26.11.2015

debugFlag = 0;

patient = 1:6;
fprintf('Convert raw data............................\n');
for i = 1:size(patient,2)
%     fprintf('............................................\n');
%     fprintf('Reading Pt0x................................\n');
    fprintf(['Converting Pt0' int2str(i)]); 
    
    patientId = ['Pt0' int2str(i)];
    patientDataFile = ['../data/matlab/' patientId '/' patientId '_raw.mat'];
    load(patientDataFile);
    fprintf('.........');
    %% Convert Logger time-stamps to sample numbers corresponding to 
    % LabChart data
    logLength = length(LoggerData.timeAbs);
    LoggerData.sampleStamps = zeros(logLength,1);
    
    % LoggerData does not contain year month and date, so it has to be set
    % manually to same values as LabChart-Data

    LabChartData.startTime = datetime(LabChartData.blocktimes,...
        'ConvertFrom', 'datenum');
    LoggerData.timeAbs.Day = LabChartData.startTime.Day;
    LoggerData.timeAbs.Month = LabChartData.startTime.Month;
    LoggerData.timeAbs.Year = LabChartData.startTime.Year;

    % check, if CRT-Logger recording was started before LabChart recording
    if (LoggerData.timeAbs(1) < LabChartData.startTime)
        disp('CRT-Logger was started before Labchart!');
    end

    % samplestamp is calculated by multiplying the amount of seconds
    % since start of measurement (in Labchart) by samplerate
    LoggerData.sampleStamps = round( seconds(LoggerData.timeAbs - ...
                                     LabChartData.startTime) ...
                                     * LabChartData.samplerate(1));
    fprintf('..........');                                 
    %% Convert BeatScope time-stamps to sample numbers corresponding to 
    % LabChart data

    bsBeatsLength = length(BsBeatsData.Times);
    BsBeatsData.sampleStamps = zeros(bsBeatsLength,1);

    bsWaveLength = length(BsWaveData.Times);
    BsWaveData.sampleStamps = zeros(bsWaveLength,1);

    % BeatScope data does not contain year month and date, so it has to be set
    % manually to same values as LabChart-Data
    BsBeatsData.Times.Day = LabChartData.startTime.Day;
    BsBeatsData.Times.Month = LabChartData.startTime.Month;
    BsBeatsData.Times.Year = LabChartData.startTime.Year;

    BsWaveData.Times.Day = LabChartData.startTime.Day;
    BsWaveData.Times.Month = LabChartData.startTime.Month;
    BsWaveData.Times.Year = LabChartData.startTime.Year;

    % check, if BeatScope recording was started before LabChart recording

    if (BsWaveData.Times(1) < LabChartData.startTime)
        disp('BeatScope Easy was started before Labchart!');
    end

    % samplestamp is calculated by multiplying the amount of seconds
    % since start of measurement (in Labchart) by samplerate

    BsBeatsData.sampleStamps = round( seconds(BsBeatsData.Times - ...
                                     LabChartData.startTime) ...
                                     * LabChartData.samplerate(1));
    BsWaveData.sampleStamps = round( seconds(BsWaveData.Times - ...
                                     LabChartData.startTime) ...
                                     * LabChartData.samplerate(1));
    fprintf('..........\n');
    
    %% Calculate time shift between analog and digital BeatScope signal
    fprintf('Calculating time shift....');
    sigStampsDigital = BsWaveData.sampleStamps';
    sigAnalogFull = LabChartData.data(LabChartData.datastart(3) : LabChartData.dataend(3));
    % Analog signal is sampled with 1000 Hz, digital signal is sampled with
    % 200 Hz. Analog signal thus has to be downsampled by a factor of 5.
    % Using SampleStamps of digital signal as mask to pick corresponding
    % parts in analog signal
    sigAnalog = sigAnalogFull(sigStampsDigital);
    sigDigital = BsWaveData.PressureFINmmHg';
    sigAnalog(1:350) = 0;
    sigDigital(1:350) = 0;
    
    fprintf('......');
    
    if debugFlag
        figure;
        plot(sigAnalog, 'r-');
        hold on;
        plot(sigDigital, 'b--');
        axis([-2000 10000 0 inf])
        title(['Unshifted Signal' patientId]);
        legend('analog','digital','Location','northwest');
    end
    
    % calculate crosscorrelation between analog and digital signal to
    % define the lag of the analog signal. Not the full signal is needed
    % for the correlation, only using first 5000 samples (equals first
    % 25s)
    [sigAcor,sigLag] = xcorr(sigAnalog(1:30000),sigDigital(1:30000));
    fprintf('......');
    
    if debugFlag
        figure;
        plot(sigLag,sigAcor)
        title(['Cross correlation' patientId]);
    end
    
    [~,I] = max(abs(sigAcor));
    sigLagDiff = sigLag(I);
    BsWaveData.timeshift = sigLagDiff/200;
    fprintf('......\n');
    
    if debugFlag
        fprintf(['Timeshift = ' num2str(sigLagDiff/200) 'seconds.\n']);
        figure;
        plot(sigAnalog, 'r-');
        hold on;
        plot([zeros(1,sigLagDiff) sigDigital], 'b--');
        axis([-2000 10000 0 inf])
        title(['Shifted Signal' patientId]);
        legend('analog','digital shifted','Location','northwest');
    end
    
    save(['../data/matlab/' patientId '/' patientId '_converted.mat'],'LabChartData','LoggerData','BsBeatsData','BsWaveData');
    clear LabChartData LoggerData BsBeatsData BsWaveData I sigAcor sigAnalog sigAnalogFull sigDigital sigLag sigLagDiff sigStampsDigital;
end

clear bsBeatsLength bsWaveLength i logLength patientDataFile patientId;
fprintf('Done!.......................................\n');