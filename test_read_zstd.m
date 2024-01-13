%%
close all
clear
clc

%% Inputs
% example file, just a compressed copy of our header
filename = "zstd_simple.h";

% created with zstd.exe -k <filename>
filenameComp = filename + ".zst";

%% Load ZSTD
load_zstd(verbose=true);

%% Read Compressed file
tic
data1 = read_zstd(filenameComp);
fprintf("Time to read compressed file: %g sec\n", toc);

% fprintf("\n---------- File Contents:\n")
% disp(char(data1));
% fprintf("\n---------- End File Contents\n")

%% Make sure it's exactly the original data
tic
fid = fopen(filename, "rb");
data2 = fread(fid, [1, Inf], "uint8=>uint8");
fclose(fid);
fprintf("Time to uncompressed file   : %g sec\n", toc);

assert(all(data1(:) == data2(:)), "Data doesn't match");
