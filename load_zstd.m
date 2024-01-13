function [notfound, warnings, verstring] = load_zstd(opts)
% load_zstd load zstd library
%
% load_zstd() loads zstd library from thunkfile
% load_zstd(Name, Value)
%
% NOTES:
%  - The zstd library should be installed somewhere on the system path
%  - Call once with makeThunk=true to generate a prototype file.  After
%  that, use the default makeThunk=false unless you need to update the
%  thunkfile or prototype.
%  - The options `headername`, `alias`, `libname`, and `mfilename` are
%  passed to loadlibrary
%  - If headername is not passed, tries to find the header file in the
%  standard installation location.  If zstd is installed to
%  C:\apps\bin\zstd.dll, then we look for C:\apps\include\zstd.h.  This is
%  the expected structure if zstd was installed using cmake --install.
% - As of version 1.5.5, matlab doesn't successfully parse the header
% installed in a normal build.  The included zstd_simple.h file exposes
% only the non-depricated simple API.  It parses successfully.

arguments
    opts.makeThunk (1, 1) logical = false
    opts.headername (1, 1) string = "zstd_simple.h"
    opts.alias (1, 1) string = "zstd"
    opts.libname (1, 1) string = "zstd.dll";
    opts.mfilename (1, 1) string = "zstdproto";
    opts.verbose (1, 1) logical = false;
end

% force a reload
if libisloaded(opts.alias)
    if opts.verbose
        fprintf("%s already loaded.  Unloading %s.\n", opts.alias, opts.alias);
    end
    unloadlibrary(opts.alias);
end

% try to find dll
libname = find_zstd_dll(opts.libname, opts.verbose);

if opts.makeThunk
    % make a prototype file and a thunk file.  Only need to call this when
    % the prototype or thunkfile need to change.  Calling with 
    % makeThunk=false will be faster and not require compilers.
    headername = find_zstd_header(opts.headername, libname, opts.verbose);
    [notfound, warnings] = loadlibrary(libname, headername, ...
        alias=opts.alias, mfilename=opts.mfilename);
else
    [notfound, warnings] = loadlibrary(libname, ...
        str2func(opts.mfilename), alias=opts.alias);
end

verstring = calllib(opts.alias, "ZSTD_versionString");
if opts.verbose
    fprintf("ZSTD_versionString: %s\n", verstring);
end

end

function libname_out = find_zstd_dll(libname_in, verbose)
% helper function to try and find dll
% Why doesn't loadlibrary do this for us?

libname_out = libname_in;
if exist(libname_in, "file")
    % if the user gave us a full file path, then we don't need to do
    % anything.  If not, it's on the matlab path.  And we get the full path
    % to the file
    if fileparts(libname_in) == ""
        libname_out = which(libname_in);
    end
else
    % Check the system path
    [status, out] = system("where " + libname_in);
    if status ~= 0
        error("zstd:zstdDllNotFound", "%s not found.  " ...
            + "Add to MatLab path, add to system path, " ...
            + "or set full path to option `libname`", libname_in);
    end
    liblocations = strsplit(string(out), "\n");
    libname_out = liblocations(1);
end
if verbose
    fprintf("Loading zstd from: %s\n", libname_out);
end

end

function hname_out = find_zstd_header(hname_in, libname, verbose)
% helper function to try and find dll

hname_out = hname_in;
if exist(hname_in, "file")
    % if the user gave us a full file path, then we don't need to do
    % anything.  If not, it's on the matlab path.  And we get the full path
    % to the file
    if fileparts(hname_in) == ""
        hname_out = which(hname_in);
    end
else
    % Check the standard include install location
    libpath = string(fileparts(libname));
    hname_out = fullfile(libpath, "..", "include", hname_in);
    if ~exist(hname_out, "file")
        error("zstd:zstdHeaderNotFound", "%s not found.  " ...
            + "Add to MatLab path, " ...
            + "or set full path to option `headername`", hname_in);
    end
end
if verbose
    fprintf("Loading zstd header from: %s\n", hname_out);
end
end