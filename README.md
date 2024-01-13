This project is a MatLab wrapper for the ZSTD Simple API.
For licensing reasons, those files are not included here.
ZSTD is on github at https://github.com/facebook/zstd

As of ZSTD 1.5.5, the full zstd.h file won't import into MatLab.
Modify it by including only the start of the file, through the Simple API.
And delete references to any deprecated functions.
