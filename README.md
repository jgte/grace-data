# grace-data

Scripts to download L1B and L2 data of the Gravity Recovery and Climate Experiment satellites from `podaac-ftp.jpl.nasa.gov`.

The file `email.txt` must be created in the same dir as the rest of the scripts, containing a single line with the email that is used as password for the anonymous FTP login.

The data is placed in `L1B/Year/Month/Day/` or `L2/[CSR|GFZ\JPL]/RELEASE/`.

The following scripts are included:
- `cat-l1b.sh`: show the contents of the L1B data;
- `download-l1b.sh`: download the L1B data (one day at a time);
- `download-l2.sh`: download the L2 data (all data for one institude and release version);
- `gunzip-l2.sh`: decompress L2 data (called from `download-l2.sh`);
- `software/update.sh`: download and compile the `Bin2AsciiLevel1` utility needed to read the binary L1B data.
