function [ ] = fastQualityPlot( Results, patient )
%FASTQUALITYPLOT plots quality distribution over all extracted beats.

stimModes = [{'AV'},{'VV'}];
directions = [{'FromRef'},{'ToRef'}];
positions = [{'beforeChange'},{'afterChange'}];
signals = [{'PpgClip'},{'PpgCuff'}];
quality = [];

figure;
for i = 1:length(patient)
    id = ['Pt0' num2str(patient(i))];
    for currentMode = stimModes
        for currentDirection = directions
            for currentSignal = signals
                if isempty(quality)
                    quality = Results.(char(id)).(char(currentMode)).(char(currentDirection)).(char(currentSignal)).quality(:);
                else
                    quality = [ quality; Results.(char(id)).(char(currentMode)).(char(currentDirection)).(char(currentSignal)).quality(:)];
                end
            end
        end
    end
    subplot(round(length(patient)/2), 2, i);
    plot(sort(quality));
    hold on;
    plot(1:length(quality),ones(1,length(quality)).*mean(quality));
    title(['Quality of Extracted beats (' id ')']);
    axis([0 inf 0 1]);
    quality = [];
end



end

