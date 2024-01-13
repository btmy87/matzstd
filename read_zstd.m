function out = read_zstd(filename)
% read_zst read bytes from a .zst file

% make sure the file exists
assert(exist(filename, "file") > 0, "File not found: %s", filename);

% read all data as a set of bytes
fid = fopen(filename, "rb");
try
    cdata = fread(fid, "uint8=>uint8");
catch ME
    fclose(fid);
    rethrow(ME);
end

% make a pointer to compressed data.  Do this once so we can pass it to
% multiple functions
nCompressed = length(cdata);
ptrComp = libpointer('uint8Ptr', cdata);

% make sure library is loaded
libname = 'zstd';
if ~libisloaded(libname)
    load_zstd();
end

% get the decompressed size
nRaw = calllib(libname, 'ZSTD_getFrameContentSize', ptrComp, nCompressed);
err = calllib(libname, 'ZSTD_isError', nRaw);
if err ~= 0
    errString = calllib(libname, 'ZSTD_getErrorName', nRaw);
    error('zstd:frameContentSize', 'Error getting frame size: %s',...
        errString);
end

% decompress
ptrRaw = libpointer('uint8Ptr', zeros(1, nRaw));
nRaw2 = calllib(libname, 'ZSTD_decompress', ptrRaw, nRaw, ...
    ptrComp, nCompressed);
err = calllib(libname, 'ZSTD_isError', nRaw2);
if err ~= 0
    errString = calllib(libname, 'ZSTD_getErrorName', nRaw2);
    error('zstd:decompress', 'Error decompressing: %s',...
        errString);
end

% send output as normal matlab variable
out = ptrRaw.Value;

