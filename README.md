duplicity-backup.pl - wrapper around "duplicity"



## General functionality

The backup software is built on top of an open source software
called "duplicity". The website of the software is:

http://duplicity.nongnu.org/

The backup program controls the following characteristics: 
* size of backup archives
* configuration of multiple backups
* encryption
* creation of incremental backups and full backups
* automatically deletion of obsolete backups
* inclusion and exclusion of directories
* backup status



## License

"duplicity-backup.pl" is released under the PostgreSQL License,
a liberal Open Source license, similar to the BSD or MIT
licenses.


Copyright (c) 2012, Andreas Scherbaum

Permission to use, copy, modify, and distribute this software
and its documentation for any purpose, without fee, and without
a written agreement is hereby granted, provided that the above
copyright notice and this paragraph and the following two paragraphs
appear in all copies.

IN NO EVENT SHALL Andreas Scherbaum BE LIABLE TO ANY PARTY FOR
DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES,
INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE
AND ITS DOCUMENTATION, EVEN IF Andreas Scherbaum HAS BEEN ADVISED
OF THE POSSIBILITY OF SUCH DAMAGE.

Andreas Scherbaum SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING,
BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE PROVIDED
HEREUNDER IS ON AN "AS IS" BASIS, AND Andreas Scherbaum HAS
NO OBLIGATIONS TO PROVIDE MAINTENANCE, SUPPORT, UPDATES,
ENHANCEMENTS, OR MODIFICATIONS.



## Sponsor

I would like to take this opportunity to thank the sponsor of
this software:

Eisbaer Media GmbH
http://www.eisbaer.de/



## Additional required software

The following packages are required on Debian/Ubuntu:

* duplicity
* ncftp
* libyaml-libyaml-perl
* libyaml-tiny-perl
* libregexp-common-perl
* libdate-manip-perl
* libtime-duration-parse-perl



## Using cron to run the backup

An example cronjob using "duplicity-backup.pl":

```
0 2 * * * root /root/duplicity-backup.pl -c /root/duplicity.conf -s --cleanup-old-logs
```

With this call, the program starts every night at 2 o `clock.



## Command line parameters

"duplicity-backup.pl" accepts the following command line parameters:
-h / --help		Display help
-d / --debug		Debug mode
-c / --config		Configuration file (required)
-l / --logfile		logfile
-s / --status		Output the status at the end of the backup
--cleanup-old-logs	Deletes all log files older than 4 weeks



## Configuration file format

The configuration file uses YAML and is easy to change using
an editor. There are two main categories:

- "config:" contains general configuration parameters
  - "duplicity:" specifies the path to the "duplicity" program
  - "volsize:" specifies the size of each backup archive, in MB
  - "password:" is optional and specifies the password used to encrypt the backup
  - "log-directory:" specifies the directory for logfiles
- "backup" is composed of sub-categories, one for each backup job
  names are unique across all backup definitions
  any definition may contain the following parameters:
  - "type:" defines the type of backup, currently only "file" is supported
  - "disabled:" determines whether a backup job is disabled
    the default is "no", by indicating "yes" the job is disabled
  - "cd-backup-directory" is the directory where the program will
    chdir into prior to any other operation
  - "backup-this-directory:" specifies the directory, relative
    to "backup-cd-directory" which should be backed up
  - "backup-target" specifies the backup destination, i.e. where
    the files are backed up
    currently, "file:" and "ftp:" supported as target
    all login information are related to this parameter
  - "backup-target-sub-directory:" specifies the subdirectory
    where this backup is to be created in "backup-target"
    if not present, it is automatically created
  - "ftp-password" is the password for the FTP server
  - "incremental" specifies whether incremental backups allowed
    default is "yes", "no" disables incremental backups
  - "full-every:" specifies a time after which a new full
    backup is created
    the time can be specified in regular English language
  - "incremental-every" specifies a time after which a new
    incremental backup is created
    when a full backup is created, the program will not create
    an incremental backup during the same run
  - "exclude:" specifies a comma-separated list of files and
    directories which should be excluded from the backup
  - "include:" specifies a comma-separated list of files and
    directories which should be included in the backup

See the "duplicity-backup.conf" example file.
Note: the password in this file is *not* my regular backup password ;-)


## Other operations

Since "duplicity-backup.pl" is just a wrapper around "duplicity"
to create backups, the restore of a file is done using "duplicity".
Following are some examples how to use "duplicity":


### List all backups

export PASSPHRASE="backup password"
export FTP_PASSWORD="ftp password"
duplicity collection-status <backup-target>/<backup-target-sub-directory>

Specifying PASSPHRASE is only required if the backups are encrypted.
Specifying FTP_PASSWORD is only required if a FTP server is
used as backup target.


### List all files in a backup

export PASSPHRASE="backup password"
export FTP_PASSWORD="ftp password"
duplicity list-current <backup-target>/<backup-target-sub-directory>


### Restore a file from backup

export PASSPHRASE="backup password"
export FTP_PASSWORD="ftp password"
duplicity --file-to-restore /path/to/file <backup-target>/<backup-target-sub-directory> /tmp/file

This will restore "/path/to/file" as "file" in "/tmp". In addition,
by using the option "-t<number days>D" it is possible to restore
an older version of a file from the backup.



## Further readings


* http://duplicity.nongnu.org/
* https://help.ubuntu.com/community/DuplicityBackupHowto
* http://en.wikipedia.org/wiki/Duplicity_(software)
