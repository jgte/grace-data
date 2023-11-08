# grace-data

Scripts to download L1B and L2 data of the Gravity Recovery and Climate Experiment (GRACE) satellites from the German Research Centre for Geosciences' (GFZ) [Information System and Data Center (ISDC)](https://isdc.gfz-potsdam.de/homepage/).

The data is placed in `L1B/$SOURCE/RL$VERSION/` or `L2/$SOURCE/RL$VERSION/`, with $SOURCE one of CSR, GFZ, JPL, and $VERSION a relevant L1B/L2 data release version. Note that not all combinations of L1B/L2, $SOURCE and $VERSION are available, refer to the ISDC directory structure.

The following scripts are included:

- `cat-l1b.sh`: show the contents of the L1B data (one day and product at a time):
```
CAT_L1B_HELP
```

- `extract-l1b.sh`: extract the contents of the L1B data (one day and product at a time):
```
EXTRACT_L1B_HELP
```

- `download-l1b.sh`: download the L1B data (one day at a time);
```
DOWNLOAD-L1B_HELP
```

- `batch-download-l1b.sh`: download the L1B data for the given 4-digit list of years;


- `download-l2.sh`: download the L2 data (all data for one institute and release version);
```
DOWNLOAD_L2_HELP
```

- `extract-l2.sh`: extract the contents of the L2 data (all data for one institute and release version):
```
EXTRACT_L2_HELP
```

- `software/update.sh`: download and compile the `Bin2AsciiLevel1` utility needed to read the binary L1B data (no arguments).

The `cat-l1b.sh` script calls the `extract-l1b.sh` script in case the uncompressed data is not available, which calls the `download-l1b.sh` in case the compressed data is not available.
