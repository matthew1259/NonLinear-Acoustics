%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% batchNEDR
%
% REQUIREMENTS:
%   Signal Processing Toolbox
%   Curve Fitting Toolbox
%
% FUNCTIONS CALLED:
%   interateNLSS -> NLSTFT -> tftb_window
%   polylsqr
%
%   Window size for STFT = 0.012 seconds
%   0.75 second voice segments were used in paper also here in this script
%
% Primary Author: Boquan Liu, PhD
%
% Last Edited on 5/27/2021 by Austin J. Scholp, MS
%   Cleanup & commenting  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear; close;

%% Load Files
%Prompts the user to choose a .wav files for anlysis
disp('Select .wav files for analysis. You MUST choose more than one.');
[filenames, path] = uigetfile('*.wav', 'MultiSelect', 'on');

if isa(filenames, 'double')==1 %check if filenames is a number
    if filenames==0 %if it is, check if it equals zero
        disp('File selection cancelled.');%If it does equal zero
        return
    end
end
if isa(filenames, 'char')==1 %check if filenames is single string
    disp('Please select more than one file.'); %If it is
    return
end

data = cell(1,length(filenames));
Fs = zeros(1,length(filenames));

%get data of selected files
for k = 1:length(filenames)
    [data{k}, Fs(k)]= audioread(strcat([path filenames{k}]));
end

disp('Please wait.');
%% Calculate NEDR

%NEDR_Results stores the result
NEDR_Results = {'Filename' ' NSCR Value'}; % preallocate, lazy/easy/quick

window_timeLength = 0.012; %change only if you know what you're doing

%run NLSS script for each wav file
for  h = 1:length(filenames)
    data_temp = data{h};
    count = Fs(h)/50000;
    data_cc = data_temp(1000:fix(1000+Fs(h)*0.1e-1));
    [NLEMaxima_Instaneous, NLE_Instaneous, scrVal, tfr, time, fre] =...
        iterateNLSS(data_cc, Fs(h),window_timeLength);
    NEDR_Results{h+1,1} = filenames{h} ;
    NEDR_Results{h+1,2} = strcat([' ' num2str(scrVal)]);
        
end
clearvars -except NEDR_Results %deletes unused/temp variables
%% Format and write output
%Convert data to table for easy printing
dataTable = cell2table(NEDR_Results(2:end,:), 'VariableNames',...
    {'File' 'NEDR'});

fileTime = datestr(datetime);
fileTime = strrep(fileTime, ':', '-');
fileTime = strrep(fileTime, ' ', '_');

%Make a directory for the results if one does not exist
[~,~] = mkdir('Results');

%Print table to results directory
writetable(dataTable, strcat(['Results\NEDR_Results_' fileTime '.csv']));
disp('SCR results listed in file: ');
disp(strcat(['NEDR_Results_' fileTime]));
clear status fileTime msg