function [ Signals, StimulationModes, BsValues, BeatDetections] = extractFromUnisens( patientNumber )
%EXTRACTFROMUNISENS extracts all data from a selected unisens dataset
%   Parameters:
%       patientNumber (int)
%           integer ranging from 1 to 6 for selecting the patient
%   Returns:
%       Signals (struct)
%           Struct containing data, samplerate and unit information of
%           recorded BP and PPG signals
%       StimulationModes (struct)
%           Struct containing samplestamps, programmed values and unit
%           information of stimulation modes (AV and VV)
%       BsValues (struct)
%           Struct containing values, samplestamps, samplerate and unit
%           information of values calculated by BeatScope based on BP-data
%       BeatDetections (struct)
%           Struct containing samplestamps and samplerate of beat
%           detections from LabChart (from PPG-data) and from BeatScope
%           (from BP-data)
%
% Author: Johann Roth
% Date: 26.11.2015

unisensDataPath = ['../data/unisens/Pt0' num2str(patientNumber)];

% create unisens object
jUnisensFactory = org.unisens.UnisensFactoryBuilder.createFactory();
jUnisens = jUnisensFactory.createUnisens(unisensDataPath);

%% import all signals
signalEntry = jUnisens.getEntry('BpAnalog.bin');
signalEntryLength = signalEntry.getCount();
Signals.Bp.data = signalEntry.readScaled(signalEntryLength);
Signals.Bp.fs = signalEntry.getSampleRate();
Signals.Bp.unit = char(signalEntry.getUnit());

signalEntry = jUnisens.getEntry('PpgClip.bin');
signalEntryLength = signalEntry.getCount();
Signals.PpgClip.data = signalEntry.readScaled(signalEntryLength);
Signals.PpgClip.fs = signalEntry.getSampleRate();
Signals.PpgClip.unit = char(signalEntry.getUnit());

signalEntry = jUnisens.getEntry('PpgCuff.bin');
signalEntryLength = signalEntry.getCount();
Signals.PpgCuff.data = signalEntry.readScaled(signalEntryLength);
Signals.PpgCuff.fs = signalEntry.getSampleRate();
Signals.PpgCuff.unit = char(signalEntry.getUnit());

clear signalEntry signalEntryLength;

%% import calculated parameters (calculated in BeatScope)
for valueEntryName = [{'BpDiastolic'},...
                      {'BpMean'},...
                      {'BpSystolic'},...
                      {'CardiacOutput'},...
                      {'Heartrate'},...
                      {'Lvet'},...
                      {'MaximumSlope'},...
                      {'PulseInterval'},...
                      {'StrokeVolume'},...
                      {'Tpr'}]
    valueEntry = jUnisens.getEntry(['Bs' char(valueEntryName) '.csv']);
    valueEntryLength = valueEntry.getCount();
    valueEntryList = valueEntry.readScaled(valueEntryLength);
    BsValues.(char(valueEntryName)).samplestamp = zeros(valueEntryLength, 1);
    BsValues.(char(valueEntryName)).value = zeros(valueEntryLength, 1);
    BsValues.(char(valueEntryName)).fs = valueEntry.getSampleRate();
    BsValues.(char(valueEntryName)).unit = valueEntry.getUnit();
    for iEntry = 1:valueEntryLength
        BsValues.(char(valueEntryName)).samplestamp(iEntry) = valueEntryList(iEntry).getSampleStamp();
        BsValues.(char(valueEntryName)).value(iEntry) = valueEntryList(iEntry).getData();
    end
end

clear valueEntryName valueEntry valueEntryLength valueEntryList iEntry;

%% import stimulation mode data

for valueEntryName = [{'AV'},...
                      {'VV'}]
    valueEntry = jUnisens.getEntry(['StimulationMode' char(valueEntryName) '.csv']);
    valueEntryLength = valueEntry.getCount();
    valueEntryList = valueEntry.readScaled(valueEntryLength);
    StimulationModes.(char(valueEntryName)).samplestamp = zeros(valueEntryLength, 1);
    StimulationModes.(char(valueEntryName)).value = zeros(valueEntryLength, 1);
    StimulationModes.(char(valueEntryName)).fs = valueEntry.getSampleRate();
    StimulationModes.(char(valueEntryName)).unit = valueEntry.getUnit();
    for iEntry = 1:valueEntryLength
        StimulationModes.(char(valueEntryName)).samplestamp(iEntry) = valueEntryList(iEntry).getSampleStamp();
        StimulationModes.(char(valueEntryName)).value(iEntry) = valueEntryList(iEntry).getData();
    end
end

clear valueEntryName valueEntry valueEntryLength valueEntryList iEntry;

%% import detection markers
% PPG-Clip and PPG-Cuff beat detections are calculated by Labchart, BP beat
% detections are calculate by BeatScope based on BP-Signal (extrapolating
% values when recalibrating)

        patientNumber = 1;
        unisensDataPath = ['../data/unisens/Pt0' num2str(patientNumber)];

        % create unisens object
        jUnisensFactory = org.unisens.UnisensFactoryBuilder.createFactory();
        jUnisens = jUnisensFactory.createUnisens(unisensDataPath);

for eventEntryName = [{'BsBp'},...
                      {'PpgCuff'},...
                      {'PpgClip'}]
    eventEntry = jUnisens.getEntry(['Detection' char(eventEntryName) '.csv']);
    eventEntryLength = eventEntry.getCount();
    eventEntryList = eventEntry.read(eventEntryLength);
    BeatDetections.(char(eventEntryName)).samplestamp = zeros(eventEntryLength, 1);
    BeatDetections.(char(eventEntryName)).fs = eventEntry.getSampleRate();
    for iEntry = 1:eventEntryLength
        BeatDetections.(char(eventEntryName)).samplestamp(iEntry) = eventEntryList.get(iEntry-1).getSampleStamp();
    end
end

clear eventEntryName eventEntry eventEntryLength eventEntryList iEntry

%% close dataset
jUnisens.closeAll();

clear jUnisens jUnisensFactory unisensDataPath patientNumber;

end




