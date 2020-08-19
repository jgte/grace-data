# grace-data

Scripts to download L1B and L2 data of the Gravity Recovery and Climate Experiment satellites from the [PO.DAAC Drive](https://podaac-tools.jpl.nasa.gov/drive/).

The file `secret.txt` must be created in the same dir as the rest of the scripts, containing two lines with the username and password (one in each line) with the credentials to access the PO.DAAC Drive.

The data is placed in `L1B/$SOURCE/RL$VERSION/` or `L2/$SOURCE/RL$VERSION/`, with $SOURCE one of CSR, GFZ, JPL, and $VERSION a relevant L1B/L2 data release version. Note that not all combinations of L1B/L2, $SOURCE and $VERSION are available, refer to the PO.DAAC Drive.

The following scripts are included:
- `cat-l1b.sh`: show the contents of the L1B data (one day and product at a time):
```
./cat-l1b.sh [ <date> <product> [ <sat> [ <version> [ <source> ] ] ] | <dat file> ]

Either:
  - <date> in YYYYMMDD
  - <product> name: ACC1B, AHK1B, GNV1B, KBR1B, MAS1B, SCA1B, THR1B, CLK1B, GPS1B, IHK1B, MAG1B, TIM1B, TNK1B, USO1B, VSL1B
  Optional argument:
   - sat     : GRACE A or B, defaults to 'A' (irrelevant if <product> is 'KBR1B')
   - version : release versions, defaults to '02'
   - source  : data source institute, defaults to 'JPL'
  NOTICE:
   - if <product> is KBR1B, the third input argument is ignored (effectively replaced with 'X')

Or:
  - <dat file>, with complete path
 ```
- `extract-l1b.sh`: extract the contents of the L1B data (one day and product at a time):
```
./extract-l1b.sh <date> <product> [ <sat> [ <version> [ <source> ] ] ]

  - <date> in YYYYMMDD
  - <product> name: ACC1B, AHK1B, GNV1B, KBR1B, MAS1B, SCA1B, THR1B, CLK1B, GPS1B, IHK1B, MAG1B, TDP1B, TIM1B, TNK1B, USO1B, VSL1B

Optional inputs:
 - sat     : GRACE A or B, defaults to 'A' (irrelevant if <product> is 'KBR1B')
 - version : release versions, defaults to '02'
 - source  : data source institute, defaults to 'JPL'
```
- `download-l1b.sh`: download the L1B data (one day at a time);
```
./download-l1b.sh <date> [ <version> [ <source> ] ]

Optional inputs:
 - version : release versions, defaults to '02'
 - source  : data source institute, defaults to 'JPL'
```
- `batch-download-l1b.sh`: download the L1B data for the given 4-digit list of years;
- `download-l2.sh`: download the L2 data (all data for one institute and release version);
```
./download-l2.sh <source> <version> [ echo ] [ manual ]

- the <source> can be CSR, GFZ or JPL
- the <version> can be (the 'RL' part is added internally), as of 10/2018:
  - CSR: 05, 05_mean_field, 06
  - GFZ: 05, 05_WEEKLY, 06
  - JPL: 05, 05.1, 06
```
- `software/update.sh`: download and compile the `Bin2AsciiLevel1` utility needed to read the binary L1B data (no arguments).

The `cat-l1b.sh` script calls the `extract-l1b.sh` script in case the decompressed data is not available, which calls the `download-l1b.sh` in case the compressed data is not available.
