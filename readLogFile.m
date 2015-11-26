function [ logStruct ] = readLogFile( filename )
% READLOGFILE  Reads a .txt LogFile created by CRT-Logger Software
%   logStruct = READLOGFILE( filename ) returns a struct containing Log-Data

%% Format string for each line of text:
%   column1: datetimes (%{HH:mm:ss.SSS}D)
%	column2: datetimes (%{HH:mm:ss.SSS}D)
%   column3: text (%s)
%	column4: text (%s)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%{HH:mm:ss.SSS}D%{HH:mm:ss.SSS}D%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, ...
    'Delimiter', ' ', 'MultipleDelimsAsOne', true,  ...
    'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Allocate imported array to column variable names
logStruct.timeAbs = dataArray{:, 1};
logStruct.timeRel = dataArray{:, 2};
logStruct.flag = dataArray{:, 3};
logStruct.flagText = dataArray{:, 4};

%% 

end

