function [ ] = fastQualityPlot( input_args )
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

stimModes = [{'AV'},{'VV'}];
directions = [{'FromRef'},{'ToRef'}];
positions = [{'beforeChange'},{'afterChange'}];
signals = [{'PpgClip'},{'PpgCuff'}];
quality = [];
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
end
min(quality), mean(quality)
figure;
plot(sort(quality));
hold on;
plot(1:length(quality),ones(1,length(quality)).*mean(quality));

end

