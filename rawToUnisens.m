%% Read raw data, convert it and write Unisens files
% This has to be executed only for first import of raw data.
%
% Author: Johann Roth
% Date: 09.12.2015
oldpath = path;
addpath('rawToUnisensConversion');

readRawData;
convertRawData;
createUnisensFiles;

rmpath('rawToUnisensConversion');
path(oldpath);

clear;