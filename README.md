# SoleCRIS -> Import scripts

This repository contains import-scripts for SoleCRIS -> DSpace import. The scripts use programs in SAF-Archiver [1] repository. You can use provided `install.sh`-script to copy all the necessary files to somewhere (/opt/solecris-dspace directory is assumed):

```
$ sudo ./install.sh /opt/solecris-dspace
```

or just copy necessary files where desired.

You need to set the necessary environmental variables - an example is provided in file `env.example.sh`. For now, see actual `import.sh` script for details.

When satisfied, perform the actual import with `import.sh` script (possibly as a cronjob) with eg.

```
'. /opt/solecris-dspace/env.sh; /opt/solecris-dspace/import.sh'
```

# License 

The files in this repository are (C) 2016 University of Eastern Finland and are licensed with a MIT licence. They were produced during SURIMA (Suomi rinnakkaistallennuksen mallimaaksi) project.

[1] https://github.com/isido/SAF-Archiver
