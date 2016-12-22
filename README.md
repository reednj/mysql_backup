# MySQL Backup Tools

## Installation

    $ gem install mysql_backup

## Usage

Run the command `mysql-backup` to backup a database. You must provide a config file in order to tell it what to backup.

    mysql-backup --config /path/to/config.yaml

## Config files

The backup config is stored in a YAML file. The only required settings are `server`, `username` and `database`

For example:

    # reddit-stream.backup.yaml
    server: 127.0.0.1
    username: backup_user
    database: redditstream

There are a number of optional parameters as well:

    # reddit-stream.backup.yaml
    #
    # These are the mandatory settings, same as before
    server: 127.0.0.1
    username: backup_user
    database: redditstream

    # you can specify the list of tables to be backed up
    tables: [action_log_notes, payment_log, payment_log_notes]

    # list multiple locations to save the backup to. SSH hosts can
    # be list here as well, and the file will be transferred using
    # scp
    save_to:
    - ~/backups
    - user@remote.com:backups/



## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

