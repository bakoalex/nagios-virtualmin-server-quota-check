# Nagios plugin for Virtualmin virtual server quota check

This is a bash shell script that collects quota usage information for a specified virtual server and alerts is the specified usage threshold is exceeded.

###Usage

```
Virtualmin virtual server quota check plugin for Nagios
Version v1.0.0
Arguments :  -d <domain> -t <type:server|user> -c <critical_threshold> -w <warning_threshold>
        -d      domain: domain of the virtual serer to query (required)
        -t      type (server|user): type of quoat to check, defaults to "server"
        -c      critical threshold level: quota usage threshold for critical alert, in percent defaults to 95
        -w      warning threshold level: quota usage threshold for warning alert, in percent defaults to 90
```

The Virtualmin CLI tool is required to run as root thus this plugin relies on `sudo`. To allow the `nagios` user (or the one that runs your Nagios or `nagios-nrpe-server` process) you need to whitelist `/usr/sbin/virtualmin` the following command for each checked domain:
```
nagios  ALL=(root) NOPASSWD: /usr/sbin/virtualmin list-domains --multiline --domain example.com
```
It is possible to whitelist the command with any argument so that you do not have to add a new record for every domain but **you have to be extremly cautious with this**.

### License

GNU GENERAL PUBLIC LICENSE. See [LICENSE](LICENSE)

