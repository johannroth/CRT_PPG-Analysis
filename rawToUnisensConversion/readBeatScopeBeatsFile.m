function [ bsBeatsStruct ] = readBeatScopeBeatsFile( filename )
%READBEATSCOPEBEATSFILE Reads a .txt Beats-File created by BeatScope Easy Software
%   logStruct = READBEATSCOPEBEATSFILE( filename ) returns a struct containing
%   Beats-Data

% Auto-generated by MATLAB on 2015/10/28 15:54:09

delimiter = ';';
startRow = 7;

%% Read columns of data as strings:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
textscan(fileID, '%[^\n\r]', startRow-1, 'WhiteSpace', '', 'ReturnOnError', false);
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric strings to numbers.
% Replace non-numeric strings with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[2,3,4,5,6,7,8,9,10,11]
    % Converts strings in the input cell array to numbers. Replaced non-numeric
    % strings with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1);
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\.]*)+[\,]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\.]*)*[\,]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData{row}, regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if any(numbers=='.');
                thousandsRegExp = '^\d+?(\.\d{3})*\,{0,1}\d*$';
                if isempty(regexp(thousandsRegExp, '.', 'once'));
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric strings to numbers.
            if ~invalidThousandsSeparator;
                numbers = strrep(numbers, '.', '');
                numbers = strrep(numbers, ',', '.');
                numbers = textscan(numbers, '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch me
        end
    end
end

% Convert the contents of columns with dates to MATLAB datetimes using date
% format string.
try
    dates{1} = datetime(dataArray{1}, 'Format', 'HH:mm:ss,SSS', 'InputFormat', 'HH:mm:ss,SSS');
catch
    try
        % Handle dates surrounded by quotes
        dataArray{1} = cellfun(@(x) x(2:end-1), dataArray{1}, 'UniformOutput', false);
        dates{1} = datetime(dataArray{1}, 'Format', 'HH:mm:ss,SSS', 'InputFormat', 'HH:mm:ss,SSS');
    catch
        dates{1} = repmat(datetime([NaN NaN NaN]), size(dataArray{1}));
    end
end

anyBlankDates = cellfun(@isempty, dataArray{1});
anyInvalidDates = isnan(dates{1}.Hour) - anyBlankDates;
dates = dates(:,1);

%% Split data into numeric and cell columns.
rawNumericColumns = raw(:, [2,3,4,5,6,7,8,9,10,11]);
rawCellColumns = raw(:, 12);


%% Allocate imported array to column variable names
bsBeatsStruct.Times = dates{:, 1};
bsBeatsStruct.SystolicmmHg = cell2mat(rawNumericColumns(:, 1));
bsBeatsStruct.DiastolicmmHg = cell2mat(rawNumericColumns(:, 2));
bsBeatsStruct.MeanmmHg = cell2mat(rawNumericColumns(:, 3));
bsBeatsStruct.Heartratebpm = cell2mat(rawNumericColumns(:, 4));
bsBeatsStruct.StrokeVolumeml = cell2mat(rawNumericColumns(:, 5));
bsBeatsStruct.LVETms = cell2mat(rawNumericColumns(:, 6));
bsBeatsStruct.PulseIntervalms = cell2mat(rawNumericColumns(:, 7));
bsBeatsStruct.MaximumSlopemmHgs = cell2mat(rawNumericColumns(:, 8));
bsBeatsStruct.CardiacOutputlmin = cell2mat(rawNumericColumns(:, 9));
bsBeatsStruct.TPRdynscm5 = cell2mat(rawNumericColumns(:, 10));
bsBeatsStruct.Markers = rawCellColumns(:, 1);

end
