# grace-data

Scripts to download L1B and L2 data of the Gravity Recovery and Climate Experiment (GRACE) satellites from the German Research Centre for Geosciences' (GFZ) [Information System and Data Center (ISDC)](https://isdc.gfz-potsdam.de/homepage/).

The data is placed in `L1B/$SOURCE/RL$VERSION/` or `L2/$SOURCE/RL$VERSION/`, with $SOURCE one of CSR, GFZ, JPL, and $VERSION a relevant L1B/L2 data release version. Note that not all combinations of L1B/L2, $SOURCE and $VERSION are available, refer to the ISDC directory structure.

The following scripts are included:

- `cat-l1b.sh`: show the contents of the L1B data (one day and product at a time):
```
cat-l1b.sh <date> <product> [ <sat> ] [ <version> ] [ <source> ] ]

Either:
  - <date> in YYYYMM[DD]
  - <product> name: ACC1B, AHK1B, GNV1B, KBR1B, MAS1B, SCA1B, THR1B, CLK1B, GPS1B, IHK1B, MAG1B, TIM1B, TNK1B, USO1B, VSL1B
  Optional argument:
   - sat     : GRACE A or B or GRACE-FO C or D, defaults to 'A' (irrelevant if <product> is 'KBR1B')
   - version : release versions, defaults to '03'
   - source  : data source institute, defaults to 'JPL'
  NOTICE:
   - if <product> is KBR1B, the third input argument is ignored (effectively replaced with 'X')

Or:
  - <dat file>, with complete path

NOTICE: v03 data is available in monthly files; all other versions are available in daily files
```

- `extract-l1b.sh`: extract the contents of the L1B data (one day and product at a time):
```
extract-l1b.sh <date> <product> [ <sat> ] [ <version> ] [ <source> ]

 - <date> in YYYYMM
 - <product> name: ACC1B, AHK1B, GNV1B, KBR1B, MAS1B, SCA1B, THR1B, CLK1B, GPS1B, IHK1B, MAG1B, TDP1B, TIM1B, TNK1B, USO1B, VSL1B

Optional inputs:
 - sat     : GRACE A or B or GRACE-FO C or D, defaults to 'A' (irrelevant if <product> is 'KBR1B')
 - version : release versions, defaults to '03'
 - source  : data source institute, defaults to 'JPL'

 NOTICE: v03 data is available in monthly files; all other versions are available in daily files
```

- `download-l1b.sh`: download the L1B data (one day at a time);
```
DOWNLOAD-L1B_HELP
```

- `batch-download-l1b.sh`: download the L1B data for the given 4-digit list of years;


- `download-l2.sh`: download the L2 data (all data for one institute and release version);
```
/Users/teixeira/cloud/surfdrive/data/grace/download-l2.sh <source> <version> [ <year> ] [ echo ] [ manual ]

Mandatory arguments:
- source  : CSR, GFZ or JPL (no other options possible), defaults to CSR

Optional arguments:
- version : as of 10/2018 (the 'RL' part is added internally), defaults to '06.2:
  - CSR   : 05, 05_mean_field, 06, 06.1
  - GFZ   : 05, 05_WEEKLY, 06
  - JPL   : 05, 05.1, 06
- year    : defines the year to download the data, can be multiple (must include the century, i.e. 20xy), defaults to 2023
- echo    : show what would have been done but don't actually do anything (optional)
- manual  : browse the remote data repository manually (optional)
- secret  : use secret file (legacy: not relevant for ISDC, which is the server currently in use, optional)
- help    : show this string (optional)
```

- `extract-l2.sh`: extract the contents of the L2 data (all data for one institute and release version):
```
/Users/teixeira/cloud/surfdrive/data/grace/extract-l2.sh <source> <version> [ echo ]

Mandatory arguments:
- source  : CSR, GFZ or JPL (no other options possible)

Optional arguments:
- version : as of 10/2018 (the 'RL' part is added internally):
  - CSR   : 05, 05_mean_field, 06
  - GFZ   : 05, 05_WEEKLY, 06
  - JPL   : 05, 05.1, 06
- echo    : show what would have been done but don't actually do anything (optional)
- help    : show this string (optional)
```

- `software/update.sh`: download and compile the `Bin2AsciiLevel1` utility needed to read the binary L1B data (no arguments).

The `cat-l1b.sh` script calls the `extract-l1b.sh` script in case the uncompressed data is not available, which calls the `download-l1b.sh` in case the compressed data is not available.
