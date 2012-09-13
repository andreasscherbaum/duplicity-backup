#!/usr/bin/env perl
#
#
# backup tool, wrapper around duplicity
#
# written by Andreas 'ads' Scherbaum <andreas@scherbaum.biz>
#


# "duplicity-backup.pl" is released under the PostgreSQL License,
# a liberal Open Source license, similar to the BSD or MIT
# licenses.
#
#
# Copyright (c) 2012, Andreas Scherbaum
#
# Permission to use, copy, modify, and distribute this software
# and its documentation for any purpose, without fee, and without
# a written agreement is hereby granted, provided that the above
# copyright notice and this paragraph and the following two paragraphs
# appear in all copies.
#
# IN NO EVENT SHALL Andreas Scherbaum BE LIABLE TO ANY PARTY FOR
# DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES,
# INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE
# AND ITS DOCUMENTATION, EVEN IF Andreas Scherbaum HAS BEEN ADVISED
# OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Andreas Scherbaum SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE PROVIDED
# HEREUNDER IS ON AN "AS IS" BASIS, AND Andreas Scherbaum HAS
# NO OBLIGATIONS TO PROVIDE MAINTENANCE, SUPPORT, UPDATES,
# ENHANCEMENTS, OR MODIFICATIONS.



package backup::config;
#
# config class for backup
#

# config file schema:
#
# key = value
# key= value
# key =value
# key=value
# key=
# key =   value
# ...

# usage:
#
# $config = backup::config->new(<configfile>);
# $var = $config->config_get_key(<key name>);
# $config->config_set_key(<key name>, <new value>);
# $config->config_delete_key(<key name>);
# %var = $config->config_get_keys();



use strict;
use POSIX; # some standards
use FileHandle; # have variables for the filehandles
use Data::Dumper;
use YAML::XS qw (/./);



# new()
#
# constructor
#
# parameter:
#  - class name
# return:
#  - pointer to config class
sub new {
    my $class = shift;

    my $self = {};
    # bless mysqlf
    bless($self, $class);
    # define own variables

    # config file name
    $self->{config_file} = undef;

    $self->{config} = undef;

    # return reference
    return $self;
}


# read_config()
#
# read in a config file
#
# parameter:
#  - self
#  - config filename
# return:
#  none
sub read_config {
    my $self = shift;
    my $config_file = shift;

    # test if config file exists
    if (!-f $config_file) {
        die "could not find config file: $config_file\n";
    }

    my $config = LoadFile($config_file);

    # save config file name for later use
    $self->{config_file} = $config_file;
    # set config to 'not changed'
    $self->{changed} = 0;
    # store config
    $self->{config} = $config;

    return;
}


# DESTROY()
#
# destructor
#
# parameter:
#  - self
# return:
#  none
sub DESTROY {
    my $self = shift;

}


# config_get_key1()
#
# return a config value
#
# parameter:
#  - self
#  - config key name 1
# return:
#  - value of config parameter (or undef)
sub config_get_key1 {
    my $self = shift;
    my $key1 = shift;

    if (!defined($self->{config}->{$key1})) {
        return undef;
    }

    # return value
    return $self->{config}->{$key1};
}


# config_set_key1()
#
# set a config value
#
# parameter:
#  - self
#  - config key name 1
#  - new value
# return:
#  none
sub config_set_key1 {
    my $self = shift;
    my $key1 = shift;
    my $value = shift;

    $self->{config}->{$key1} = $value;

    return;
}


# config_get_key2()
#
# return a config value
#
# parameter:
#  - self
#  - config key name 1
#  - config key name 2
# return:
#  - value of config parameter (or undef)
sub config_get_key2 {
    my $self = shift;
    my $key1 = shift;
    my $key2 = shift;

    if (!defined($self->{config}->{$key1})) {
        return undef;
    }
    if (!defined($self->{config}->{$key1}->{$key2})) {
        return undef;
    }

    # return value
    return $self->{config}->{$key1}->{$key2};
}


# config_set_key2()
#
# set a config value
#
# parameter:
#  - self
#  - config key name 1
#  - config key name 2
#  - value
# return:
#  none
sub config_set_key2 {
    my $self = shift;
    my $key1 = shift;
    my $key2 = shift;
    my $value = shift;

    $self->{config}->{$key1}->{$key2} = $value;

    return;
}


# config_get_key3()
#
# return a config value
#
# parameter:
#  - self
#  - config key name 1
#  - config key name 2
#  - config key name 3
# return:
#  - value of config parameter (or undef)
sub config_get_key3 {
    my $self = shift;
    my $key1 = shift;
    my $key2 = shift;
    my $key3 = shift;

    if (!defined($self->{config}->{$key1})) {
        return undef;
    }
    if (!defined($self->{config}->{$key1}->{$key2})) {
        return undef;
    }
    if (!defined($self->{config}->{$key1}->{$key2}->{$key3})) {
        return undef;
    }

    # return value
    return $self->{config}->{$key1}->{$key2}->{$key3};
}


# config_set_key3()
#
# set a config value
#
# parameter:
#  - self
#  - config key name 1
#  - config key name 2
#  - config key name 3
#  - value
# return:
#  none
sub config_set_key3 {
    my $self = shift;
    my $key1 = shift;
    my $key2 = shift;
    my $key3 = shift;
    my $value = shift;

    $self->{config}->{$key1}->{$key2}->{$key3} = $value;

    return;
}


# config_delete_key()
#
# delete a config key
#
# parameter:
#  - self
#  - config key name 1
# return:
#  none
sub config_delete_key1 {
    my $self = shift;
    my $key1 = shift;

    # delete key
    delete($self->{config}->{$key1});

    # mark config changed
    $self->{changed} = 1;
}


# config_delete_key2()
#
# delete a config key
#
# parameter:
#  - self
#  - config key name 1
#  - config key name 2
# return:
#  none
sub config_delete_key2 {
    my $self = shift;
    my $key1 = shift;
    my $key2 = shift;

    # delete key
    delete($self->{config}->{$key1}->{$key2});

    # mark config changed
    $self->{changed} = 1;
}


# config_delete_key3()
#
# delete a config key
#
# parameter:
#  - self
#  - config key name 1
#  - config key name 2
#  - config key name 3
# return:
#  none
sub config_delete_key3 {
    my $self = shift;
    my $key1 = shift;
    my $key2 = shift;
    my $key3 = shift;

    # delete key
    delete($self->{config}->{$key1}->{$key2}->{$key3});

    # mark config changed
    $self->{changed} = 1;
}


# config_get_keys1()
#
# return hash with all defined config keys
#
# parameter:
#  - self
#  - config key 1
# return:
#  - hash with config keys
sub config_get_keys1 {
    my $self = shift;
    my $key1 = shift;

    if (!defined($self->{config}->{$key1})) {
        return undef;
    }

    if (ref($self->{config}->{$key1}) eq '') {
      # return value
      return $self->{config}->{$key1};
    }

    if (ref($self->{config}->{$key1}) eq 'HASH') {
      # return sorted hash
      my $config = $self->{config}->{$key1};
      my %config = %$config;
      # returns an array with the values
      return sort(keys(%config));
    }

    if (ref($self->{config}->{$key1}) eq 'ARRAY') {
      die("FIXME: not yet implemented - required?\n");
    }

    return undef;
}


# config_get_keys2()
#
# return hash with all defined config keys
#
# parameter:
#  - self
#  - config key 1
#  - config key 2
# return:
#  - hash with config keys
sub config_get_keys2 {
    my $self = shift;
    my $key1 = shift;
    my $key2 = shift;

    if (!defined($self->{config}->{$key1})) {
        return undef;
    }

    if (!defined($self->{config}->{$key1}->{$key2})) {
        return undef;
    }

    if (ref($self->{config}->{$key1}->{$key2}) eq '') {
      # return value
      return $self->{config}->{$key1}->{$key2};
    }

    if (ref($self->{config}->{$key1}->{$key2}) eq 'HASH') {
      # return sorted hash
      my $config = $self->{config}->{$key1}->{$key2};
      my %config = %$config;
      # returns an array with the values
      return sort(keys(%config));
    }

    if (ref($self->{config}->{$key1}->{$key2}) eq 'ARRAY') {
      die("FIXME: not yet implemented - required?\n");
    }

    return undef;
}


# config_file()
#
# return the name of the config file
#
# parameter:
#  none
# return:
#  - config file name
sub config_file {
    my $self = shift;

    return $self->{config_file};
}



# end module
1;






######################################################################
#                                                                    #
#  Main                                                              #
#                                                                    #
######################################################################

package main;


use strict;
use warnings;

use Getopt::Long qw( :config no_ignore_case );
use FileHandle;
use Data::Dumper;
use YAML::XS qw (/./);
use Date::Manip;
use Date::Parse;
use Time::Duration::Parse;
use Time::HiRes qw( gettimeofday tv_interval );
use Net::FTP;
use feature qw/switch/;
import backup::config;




######################################################################
# initialize global variables
######################################################################

use constant DEBUG2 => 5;
use constant DEBUG  => 4;
use constant INFO   => 3;
use constant WARN   => 2;
use constant ERROR  => 1;

%main::loglevels = (
    5 => 'DEBUG2',
    4 => 'DEBUG',
    3 => 'INFO',
    2 => 'WARN',
    1 => 'ERROR',
);

$main::loglevel = INFO;





######################################################################
# handle command line arguments
######################################################################
# defaults
$main::help              = 0;
$main::debug             = 0;
$main::config_file       = "";
$main::status            = 0;
$main::cleanup_old_logs  = 0;
# parse options
unless (
    GetOptions(
        'help|h|?'         => \$main::help,
        'debug|d'          => \$main::debug,
        'config|c=s'       => \$main::config_file,
        'logfile|l=s'      => \$main::logfile,
        'status|s'         => \$main::status,
        'cleanup-old-logs' => \$main::cleanup_old_logs,
    )
) {
    # There were errors with parsing command line options - show help.
    $main::help = 1;
}

if ($main::debug == 1) {
    $main::loglevel = DEBUG;
}








######################################################################
# Main
######################################################################


if ($main::help == 1) {
    print <<_END_OF_HELP_;

  $0 [options]

The following options are available:
  -h --help          This help
  -d --debug         Enable debug messages
  -D --debug-irc     Enable IRC traffic debugging
  -c --config        Config file (required)
  -l --logfile       Logfile
  -s --status        Add backup status to output

_END_OF_HELP_
    exit(0);
}



init_config();
if (length($main::config_file) > 0) {
    read_config($main::config_file);
} else {
    print_msg("No configfile!", ERROR);
    exit(1);
}



# pre-flight checks
my $check_duplicity = config_get_keys2('config', 'duplicity');
if (!defined($check_duplicity)) {
    print_msg("duplicity path must be set in config", ERROR);
    exit(1);
}
if (!-f $check_duplicity or !-e $check_duplicity) {
    print_msg("duplicity binary not available", ERROR);
    exit(1);
}

my $check_volsize = config_get_keys2('config', 'volsize');
if (!defined($check_volsize) or length($check_volsize) == 0) {
    print_msg("global volsize must be set", ERROR);
    exit(1);
}

my $check_log_directory = config_get_keys2('config', 'log-directory');
if (!defined($check_log_directory) or length($check_log_directory) == 0) {
    print_msg("global log-directory must be set", ERROR);
    exit(1);
}
if (!-d $check_log_directory) {
    print_msg("global log-directory must exist", ERROR);
    exit(1);
}
if ($check_log_directory !~ /\/$/) {
    # complete path of log directory, make it easier for repetitive calls
    config_set_key2('config', 'log-directory', $check_log_directory . '/');
}



print_msg("Initialization done, start backup", INFO);



my @backups = config_get_keys1('backup');
# walk through all backups
foreach my $backup (@backups) {
    if ($backup =~ /[^a-zA-Z0-9\-\_]/) {
        print_msg("backup name ($backup) is invalid", ERROR);
        next;
    }
    print_msg("Backup task: " . $backup, INFO);
    my $status = run_backup($backup);
    if ($status == 0) {
        print_msg("backup task did not run, because of errors", ERROR);
    } elsif ($status == 1) {
        print_msg("backup task finished successfully", INFO);
    }
}







######################################################################
# regular functions used by the backup
######################################################################


# run_backup()
#
# run a backup task
#
# parameter:
#  - backup task name, from config
# return:
#  - return status
#    0:  error
#    1:  OK
#    >1: ignore value
# note: don't exit in this function, return back to caller
sub run_backup {
    my $backup = shift;

    my @execute = ();


    my $backup_type                 = config_get_key3('backup', $backup, 'type');
    my $backup_disabled             = config_get_key3('backup', $backup, 'disabled');
    my $backup_incremental          = config_get_key3('backup', $backup, 'incremental');
    my $backup_full_every           = config_get_key3('backup', $backup, 'full-every');
    my $backup_incremental_every    = config_get_key3('backup', $backup, 'incremental-every');
    my $backup_keep_full            = config_get_key3('backup', $backup, 'keep-full');
    my $backup_cd_directory         = config_get_key3('backup', $backup, 'backup-cd-directory');
    my $backup_this_directory       = config_get_key3('backup', $backup, 'backup-this-directory');
    my $backup_target               = config_get_key3('backup', $backup, 'backup-target');
    my $backup_target_sub_directory = config_get_key3('backup', $backup, 'backup-target-sub-directory');
    my $backup_include              = config_get_key3('backup', $backup, 'include');
    my $backup_exclude              = config_get_key3('backup', $backup, 'exclude');


    # pre-flight checks
    if (!defined($backup_disabled)) {
        $backup_disabled = 'no';
    }
    if ($backup_disabled eq 'yes' or $backup_disabled eq '1') {
        print_msg("task is disabled", INFO);
        return 2;
    }


    # create logfile prefix, so every "duplicity" call can use the same prefix
    my ($gtod_seconds, $gtod_microseconds) = gettimeofday();
    my $logfile_prefix = sprintf("%s-%010d-%06d", $backup, $gtod_seconds, $gtod_microseconds);
    print_msg("logfile names start with: $logfile_prefix", INFO);
    $logfile_prefix = config_get_keys2('config', 'log-directory') . $logfile_prefix . '-';


    if (!defined($backup_type)) {
        print_msg("backup type must be set", ERROR);
        return 0;
    }
    if (!defined($backup_target)) {
        print_msg("backup-target must be set", ERROR);
        return 0;
    }
    if (!defined($backup_target_sub_directory)) {
        print_msg("backup-target-sub-directory must be set", ERROR);
        return 0;
    }
    if (!defined($backup_full_every)) {
        print_msg("full-every must be set", ERROR);
        return 0;
    }
    if (!defined($backup_keep_full)) {
        print_msg("keep-full must be set", ERROR);
        return 0;
    }
    if ($backup_keep_full !~ /^\d+$/ or $backup_keep_full < 1) {
        print_msg("keep-full must be a positive integer greater 0", ERROR);
        return 0;
    }
    if (!defined($backup_incremental)) {
        $backup_incremental = 'no';
        $backup_incremental_every = undef;
        print_msg("no incremental backups", DEBUG);
    } elsif ($backup_incremental ne 'yes' and $backup_incremental ne 'no') {
        print_msg("incremental must be set to 'yes' or 'no'", ERROR);
        return 0;
    }

    if (!defined($backup_cd_directory)) {
        print_msg("backup-cd-directory must be set", ERROR);
        return 0;
    }
    if (substr($backup_cd_directory, 0, 1) ne '/') {
        # unix only, for now
        print_msg("backup-cd-directory must be a absolute path", ERROR);
        return 0;
    }
    if (!defined($backup_this_directory)) {
        print_msg("backup-this-directory must be set", ERROR);
        return 0;
    }
    if (substr($backup_this_directory, 0, 1) eq '/') {
        print_msg("backup-cd-directory must be a relative path", ERROR);
        return 0;
    }


    # setup
    my $backup_path = complete_backup_path($backup, $backup_target, $backup_target_sub_directory);
    if (!defined($backup_path)) {
        print_msg("error calculating backup path for: $backup, $backup_target, $backup_target_sub_directory", ERROR);
        return 0;
    }

    my $volsize = config_get_key3('backup', $backup, 'volsize');
    if (!defined($volsize) or length($volsize) == 0) {
        $volsize = config_get_key2('config', 'volsize');
    }
    if (defined($volsize) and $volsize > 0) {
        push(@execute, '--volsize', $volsize);
    }

    # handle encryption (local, global)
    my $password = config_get_key3('backup', $backup, 'password');
    if (!defined($password) or length($password) == 0) {
        $password = config_get_key2('config', 'password');
    }
    if (!defined($password) or length($password) == 0 or $password eq 'no') {
        push(@execute, '--no-encryption');
        delete($ENV{'PASSPHRASE'});
    } else {
        $ENV{'PASSPHRASE'} = $password;
    }

    # handle ftp password
    my $ftp_password = config_get_key3('backup', $backup, 'ftp-password');
    if (defined($ftp_password)) {
        $ENV{'FTP_PASSWORD'} = $ftp_password;
    } else {
        delete($ENV{'FTP_PASSWORD'});
    }


    # get list of existing backups
    my $start_time_status = [gettimeofday];
    my $this_backup_path_info = get_backup_path_status($backup, $backup_path, $logfile_prefix);
    my $end_time_status = [gettimeofday];
    my $run_time_status = int(100 * tv_interval($start_time_status, $end_time_status)) / 100;
    if (!defined($this_backup_path_info)) {
        # error is already displayed
        return 0;
    }
    print_msg("time for backup status: $run_time_status seconds", INFO);
    my %this_backup_path_info = %$this_backup_path_info;
    print_msg("number of full backups: " . $this_backup_path_info{'number_full_backups'}, DEBUG);
    if ($this_backup_path_info{'number_full_backups'} > 0) {
        print_msg("last full backup: " . $this_backup_path_info{'last_full_backup'}, DEBUG);
        if ($this_backup_path_info{'number_incremental_backups'} > 0) {
            print_msg("number of incremental backups: " . $this_backup_path_info{'number_incremental_backups'}, DEBUG);
            print_msg("last incremental backups: " . $this_backup_path_info{'last_incremental_backup'}, DEBUG);
        }
    }
    if ($this_backup_path_info{'error_in_sets'} == 1) {
        print_msg("errors in backup set found, please verify backup!", ERROR);
        return 0;
    }


    # is full backup necessary?
    my $need_full_backup = 0;
    my $need_incremental_backup = 0;

    if ($this_backup_path_info{'number_full_backups'} == 0) {
        print_msg("no existing backup, enforce full backup", INFO);
        $need_full_backup = 1;
    } else {
        my $backup_full_duration = undef;
        eval { $backup_full_duration = parse_duration($backup_full_every); };
        if ($@) {
            print_msg("full-every ($backup_full_every) is invalid", ERROR);
            return 0;
        }
        print_msg("full backup every $backup_full_duration seconds ($backup_full_every)", DEBUG);
        my $time_last_full_backup = str2time($this_backup_path_info{'last_full_backup'});
        if (($time_last_full_backup + $backup_full_duration - 30) < time()) {
            print_msg("last full backup is " . (time() - ($time_last_full_backup + $backup_full_duration)) . " seconds too old, enforce full backup", DEBUG);
            $need_full_backup = 1;
        }
    }


    # if no full backup, is incremental backup allowed?
    # if incremental backup allowed, is it necessary?
    if ($need_full_backup == 0 and $backup_incremental eq 'yes') {
        if ($this_backup_path_info{'number_incremental_backups'} == 0) {
            # set last incremental backup timestamp to last full backup timestamp
            $this_backup_path_info{'last_incremental_backup'} = $this_backup_path_info{'last_full_backup'};
        }
        my $backup_incremental_duration = undef;
        eval { $backup_incremental_duration = parse_duration($backup_incremental_every); };
        if ($@) {
            print_msg("incremental-every ($backup_incremental_every) is invalid", ERROR);
            return 0;
        }
        print_msg("incremental backup every $backup_incremental_duration seconds ($backup_incremental_every)", DEBUG);
        my $time_last_incremental_backup = str2time($this_backup_path_info{'last_incremental_backup'});
        if (($time_last_incremental_backup + $backup_incremental_duration - 30) < time()) {
            print_msg("last incremental backup is " . (time() - ($time_last_incremental_backup + $backup_incremental_duration)) . " seconds too old, enforce incremental backup", DEBUG);
            $need_incremental_backup = 1;
        }
    }


    # run backup, if necessary
    if ($need_full_backup == 1 or $need_incremental_backup == 1) {
        if ($need_full_backup == 1) {
            print_msg("full backup necessary", INFO);
            unshift(@execute, 'full');
        } elsif ($need_incremental_backup == 1) {
            print_msg("incremental backup necessary", INFO);
            unshift(@execute, 'incr');
        }


        if (!chdir($backup_cd_directory)) {
            print_msg("cannot chdir() into backup-cd-directory ($backup_cd_directory): $!", ERROR);
            return 0;
        }
        print_msg("chdir into $backup_cd_directory", DEBUG);

        given($backup_type) {
            # here is the right place to do preparations for the backup
            when ('file') {
                if (!prepare_backup_file($backup, $backup_cd_directory, $backup_this_directory)) {
                    return 0;
                }
            }
        }

        my @backup_include = ();
        if (defined($backup_include) and length($backup_include)) {
            if ($backup_include =~ / *, */) {
                @backup_include = split(/ *, */, $backup_include);
            } else {
                push(@backup_include, $backup_include);
            }
            foreach my $tmp_backup_include (@backup_include) {
                push(@execute, '--include');
                push(@execute, "'" . $tmp_backup_include . "'");
            }
        }

        my @backup_exclude = ();
        if (defined($backup_exclude) and length($backup_exclude)) {
            if ($backup_exclude =~ / *, */) {
                @backup_exclude = split(/ *, */, $backup_exclude);
            } else {
                push(@backup_exclude, $backup_exclude);
            }
            foreach my $tmp_backup_exclude (@backup_exclude) {
                push(@execute, '--exclude');
                push(@execute, "'" . $tmp_backup_exclude . "'");
            }
        }

        push(@execute, $backup_this_directory);
        push(@execute, $backup_path);
        my $start_time_backup = [gettimeofday];
        my ($status, $return) = execute_duplicity_command(join(" ", @execute), $logfile_prefix . 'backup.txt');
        my $end_time_backup = [gettimeofday];
        my $run_time_backup = int(100 * tv_interval($start_time_backup, $end_time_backup)) / 100;
        print_msg("return status: $status", DEBUG);
        if ($status != 0) {
            return 0;
        }
        print_msg("time for backup: $run_time_backup seconds", INFO);
    } else {
        print_msg("no backup necessary", INFO);
    }


    # delete old full backups
    if ($need_full_backup == 1 or $need_incremental_backup == 1) {
        my @delete_execute = ();
        push(@delete_execute, 'remove-all-but-n-full');
        push(@delete_execute, $backup_keep_full);
        push(@delete_execute, '--force');
        push(@delete_execute, $backup_path);
        my $start_time_delete = [gettimeofday];
        my ($delete_status, $delete_return) = execute_duplicity_command(join(" ", @delete_execute), $logfile_prefix . 'remove.txt');
        my $end_time_delete = [gettimeofday];
        my $run_time_delete = int(100 * tv_interval($start_time_delete, $end_time_delete)) / 100;
        if ($delete_status != 0) {
            print_msg("deleting old backups failed", ERROR);
            return 0;
        }
        print_msg("time for delete old backups: $run_time_delete seconds", INFO);
    }


    # backup status
    if ($main::status == 1) {
        my @status_execute = ();
        push(@status_execute, 'collection-status');
        push(@status_execute, $backup_path);
        my $start_time_status = [gettimeofday];
        my ($status_status, $status_return) = execute_duplicity_command(join(" ", @status_execute), $logfile_prefix . 'overview.txt');
        my $end_time_status = [gettimeofday];
        my $run_time_status = int(100 * tv_interval($start_time_status, $end_time_status)) / 100;
        if ($status_status != 0) {
            print_msg("retrieving backup status failed", ERROR);
            return 0;
        }
        print_msg("time for backup status: $run_time_status seconds", INFO);
        my @status_return = @$status_return;
        chomp(@status_return);
        print_msg_no_linebreaks("\n" . join("\n", @status_return), INFO);
    }


    if ($main::cleanup_old_logs == 1) {
        my $dh = new FileHandle;
        my $log_directory = config_get_keys2('config', 'log-directory');
        if (!opendir($dh, $log_directory)) {
            print_msg("open log directory failed", ERROR);
            print_msg("$!", ERROR);
            return 0;
        }
        while (my $entry = readdir($dh)) {
            if ($entry =~ /^.+\-(\d{9,11})\-\d{6}\-/) {
                my $entry_ts = $1;
                if ($entry_ts < (time() - (3600 * 24 * 28))) {
                    print_msg("delete old logfile: $entry", DEBUG);
                    unlink($log_directory . '/' . $entry);
                }
            }
        }
        closedir($dh);
    }


    return 1;
}


# prepare_backup_file()
#
# backup preparations for type 'file'
#
# parameter:
#  - backup task name, from config
#  - directory where the backup program should chdir() into
#  - directory which should be backed up
# return:
#  1: OK
#  0: error
sub prepare_backup_file {
    my $backup                = shift;
    my $backup_cd_directory   = shift;
    my $backup_this_directory = shift;

    return 1;
}


# get_backup_path_status()
#
# collect information about a backup path
#
# parameter:
#  - backup task name, from config
#  - backup path
#  - logfile prefix
sub get_backup_path_status {
    my $backup         = shift;
    my $backup_path    = shift;
    my $logfile_prefix = shift;


    my ($status, $return) = execute_duplicity_command('collection-status' . ' ' . $backup_path, $logfile_prefix . 'status.txt');


    if (!defined($return)) {
        print_msg("backup status on '$backup_path' returned no input", ERROR);
        return undef;
    }

    # ignore the return status


    my @status = @$return;
    chomp(@status);

    my %status = ();
    $status{'number_full_backups'} = 0;
    $status{'number_incremental_backups'} = 0;
    $status{'last_full_backup'} = undef;
    $status{'last_incremental_backup'} = undef;
    $status{'error_in_sets'} = 1;

    my $found_inside_chain = 0;

    foreach my $line (@status) {
        if ($line =~ /^No orphaned or incomplete backup sets found/) {
            $status{'error_in_sets'} = 0;
        }

        if (substr($line, 0, 15) eq '---------------' and $found_inside_chain == 1) {
            $found_inside_chain = 0;
            next;
        } elsif ($line =~ /^Chain start/) {
            $found_inside_chain = 1;
            $status{'number_full_backups'}++;
            $status{'number_incremental_backups'} = 0;
            next;
        }

        if ($found_inside_chain == 1) {
            if ($line =~ /^[ ]+Full[ ]+(.+?)[ ][ ][ ]+\d+/) {
                print_msg("full backup at: $1", DEBUG);
                $status{'last_full_backup'} = $1;
                $status{'number_full_backups'}++;
                next;
            }
            if ($line =~ /^[ ]+Incremental[ ]+(.+?)[ ][ ][ ]+\d+/) {
                print_msg("incremental backup at: $1", DEBUG);
                $status{'last_incremental_backup'} = $1;
                $status{'number_incremental_backups'}++;
                next;
            }
        }
    }

    return \%status;
}


# execute_duplicity_command()
#
# execute a "duplicity" command and write log
#
# parameter:
#  - command (without "duplicity" at the beginning)
#  - logfile name
# return:
#  - array with:
#    - return status of "duplicity" call
#    - pointer to array with logfile entries
# note:
#  - passwords and environment must be already set
#  - logfile is written to the file specified in "logfile name"
sub execute_duplicity_command {
    my $command = shift;
    my $logfile = shift;


    my $duplicity = config_get_key2('config', 'duplicity');

    my $execute = $duplicity . " " . $command .  ' 2>&1';

    print_msg("execute: $execute", DEBUG);

    my @return = `$execute`;
    my $return = $?;

    my $fh = new FileHandle;
    if (open($fh, ">", $logfile)) {
        print $fh $execute . "\n";
        print $fh "return status: $return\n\n";
        print $fh join("", @return);
        close($fh);
    }

    if (scalar(@return) > 0) {
        return ($return, \@return);
    } else {
        return ($return, undef);
    }
}


# complete_backup_path()
#
# complete the backup path name from settings
#
# parameter:
#  - backup task name, from config
#  - backup target
#  - local path for this backup in the backup target
# return:
#  - path, or undef
# note:
#  - aims to create the local path, if it does not yet exist
sub complete_backup_path {
    my $backup                      = shift;
    my $backup_target               = shift;
    my $backup_target_sub_directory = shift;



    if ($backup_target =~ /^file:\/\/(.+)$/) {
        my $tmp_path = $1;
        if (!-d $tmp_path) {
            # the main directory must exist
            print_msg("backup target directory does not exist: $tmp_path", ERROR);
            return undef;
        }
        if (!-d ($tmp_path . "/" . $backup_target_sub_directory)) {
            # if subdirectory does not exist, might be new, create it
            if (!mkdir($tmp_path . "/" . $backup_target_sub_directory)) {
                print_msg("cannot create subdirectory ($backup_target_sub_directory) in backup directory ($tmp_path): $!", ERROR);
                return undef;
            }
            print_msg("subdirectory ($backup_target_sub_directory) in backup directory ($tmp_path) created", INFO);
        }

        my $path = $backup_target . (($backup_target !~ /\/$/) ? '/' : '') . $backup_target_sub_directory;
        print_msg("full backup path: $path", DEBUG);
        return $path;
    } elsif ($backup_target =~ /^ftp:\/\/(.+)$/) {
        my $tmp_path = $1;

        # path must contain a username, a host and optional a directory
        my $tmp_username = undef;
        my $tmp_hostname = $tmp_path;
        my $tmp_pathname = undef;
        if ($tmp_hostname =~ /^([^\@]+)\@(.+)$/) {
            $tmp_username = $1;
            $tmp_hostname = $2; 
        }
        if ($tmp_hostname =~ /^([^\/]+)(\/.*)$/) {
            $tmp_hostname = $1;
            $tmp_pathname = $2;
        }
        if (!defined($tmp_username)) {
            print_msg("username missing in ftp declaration ($backup_target)", ERROR);
            return undef;
        }
        if (!defined($tmp_pathname)) {
            $tmp_pathname = '/';
        }
        my $tmp_password = config_get_key3('backup', $backup, 'ftp-password');
        if (!defined($tmp_password)) {
            print_msg("no ftp password found, assuming empty password", DEBUG);
            $tmp_password = '';
        }

        my $ftp = Net::FTP->new($tmp_hostname, Port => 21);
        if (!$ftp) {
            print_msg("can't connect to ftp server: $@", ERROR);
            return undef;
        }
        if (!$ftp->login($tmp_username, $tmp_password)) {
            print_msg("can't login into ftp server, username or password wrong", ERROR);
            return undef;
        }
        $ftp->pasv();
        $ftp->binary;

        # see that the backup target directory exists
        if (!$ftp->cwd($tmp_pathname)) {
            print_msg("backup target directory does not exist: $tmp_pathname", ERROR);
            $ftp->quit();
            return undef;
        }


        # see that the subdirectory exists, if not create it
        if (!$ftp->cwd($backup_target_sub_directory)) {
            if (!$ftp->mkdir($backup_target_sub_directory)) {
                print_msg("cannot create subdirectory ($backup_target_sub_directory) in backup directory ($tmp_pathname): $!", ERROR);
                $ftp->quit();
                return undef;
            }
            print_msg("subdirectory ($backup_target_sub_directory) in backup directory ($tmp_pathname) created", INFO);
        }

        my $path = 'ftp://' . $tmp_username . '@' . $tmp_hostname . $tmp_pathname . (($tmp_pathname !~ /\/$/) ? '/' : '') . $backup_target_sub_directory . (($backup_target_sub_directory !~ /\/$/) ? '/' : '');
        print_msg("full backup path: $path", DEBUG);
        return $path;
    } else {
        print_msg("unsupported protocol in complete_backup_path(): $backup_target", ERROR);
        return undef;
    }

}


# init_config()
#
# init configuration
#
# parameter:
#  none
# return:
#  none
sub init_config {

    $main::config = backup::config->new();
}


# read_config()
#
# read configuration & set variables accordingly
#
# parameter:
#  - config file name
# return:
#  none
sub read_config {
    my $config_file = shift;

    print_msg("Read configuration file: $config_file", DEBUG);
    $main::config->read_config($config_file);

    validate_config();
}


# config_get_key1()
#
# read configuration value
#
# parameter:
#  - config key 1
# return:
#  - config value
sub config_get_key1 {
    my $key1 = shift;

    return $main::config->config_get_key($key1);
}


# config_get_key2()
#
# read configuration value
#
# parameter:
#  - config key 1
#  - config key 2
# return:
#  - config value
sub config_get_key2 {
    my $key1 = shift;
    my $key2 = shift;

    return $main::config->config_get_key2($key1, $key2);
}


# config_get_key3()
#
# read configuration value
#
# parameter:
#  - config key 1
#  - config key 2
#  - config key 3
# return:
#  - config value
sub config_get_key3 {
    my $key1 = shift;
    my $key2 = shift;
    my $key3 = shift;

    return $main::config->config_get_key3($key1, $key2, $key3);
}


# config_set_key1()
#
# set configuration value
#
# parameter:
#  - config key 1
#  - value
# return:
#  none
sub config_set_key1 {
    my $key1  = shift;
    my $value = shift;

    $main::config->config_set_key($key1, $value);

    return;
}


# config_set_key2()
#
# read configuration value
#
# parameter:
#  - config key 1
#  - config key 2
#  - value
# return:
#  none
sub config_set_key2 {
    my $key1  = shift;
    my $key2  = shift;
    my $value = shift;

    $main::config->config_set_key2($key1, $key2, $value);

    return;
}


# config_set_key3()
#
# read configuration value
#
# parameter:
#  - config key 1
#  - config key 2
#  - config key 3
#  - value
# return:
#  none
sub config_set_key3 {
    my $key1  = shift;
    my $key2  = shift;
    my $key3  = shift;
    my $value = shift;

    $main::config->config_set_key3($key1, $key2, $key3, $value);

    return;
}


# config_get_keys1()
#
# read configuration keys
#
# parameter:
#  - config key 1
# return:
#  - array with 2nd config keys
sub config_get_keys1 {
    my $key1 = shift;

    return $main::config->config_get_keys1($key1);
}


# config_get_keys2()
#
# read configuration keys
#
# parameter:
#  - config key 1
#  - config key 2
# return:
#  - array with 3nd config keys
sub config_get_keys2 {
    my $key1 = shift;
    my $key2 = shift;

    return $main::config->config_get_keys2($key1, $key2);
}


# validate_config()
#
# read configuration & validate important settings
#
# parameter:
#  none
# return:
#  none
sub validate_config {

    if (!config_get_key2('config', 'duplicity')) {
        die("Please set config value 'config:duplicity'\n");
    }
    if (! -f config_get_key2('config', 'duplicity')) {
        die("Please validate config value 'config:duplicity'\n");
    }

    if (!config_get_key2('config', 'volsize')) {
        die("Please set config value 'config:volsize'\n");
    }
    if (config_get_key2('config', 'volsize') !~ /^\d+$/) {
        die("Please validate config value 'config:volsize'\n");
    }

    print_msg("Configuration validated", DEBUG);
}


# print_msg()
#
# print out a message on stderr
#
# parameter:
#  - message
#  - loglevel (optional)
# return:
#  none
sub print_msg {
    my $msg   = shift;
    my $level = shift || $main::loglevel;

    if ($level > $main::loglevel) {
        return;
    }

    $msg =~ s/\n//g;

    return print_msg_no_linebreaks($msg, $level);
}


# print_msg_no_linebreaks()
#
# print out a message on stderr
#
# parameter:
#  - message
#  - loglevel (optional)
# return:
#  none
sub print_msg_no_linebreaks {
    my $msg   = shift;
    my $level = shift || $main::loglevel;

    if ($level > $main::loglevel) {
        return;
    }

    my $timestamp = localtime;
    my $print = "";
    $print .= "$timestamp ";
    $print .= sprintf "%-8s", "[" . $main::loglevels{$level} . "]";
    $print .= "- $msg\n";
    print $print;

    if (defined($main::logfile)) {
        my $fh = new FileHandle;
        if (open($fh, ">", $main::logfile)) {
            print $fh $print;
            close($fh);
        }
    }

    return 1;
}
