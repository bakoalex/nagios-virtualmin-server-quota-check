# Nagios plugin for Virtualmin virtual server quota check

This is a bash shell script that collects quota usage information for a specified virtual server and alerts is the specified usage threshold is exceeded.

###Usage:

```
Virtualmin virtual server quota check plugin for Nagios
Version v1.0.0
Arguments :  -d <domain> -t <type:server|user> -c <critical_threshold> -w <warning_threshold>
        -d      domain: domain of the virtual serer to query (required)
        -t      type (server|user): type of quoat to check, defaults to "server"
        -c      critical threshold level: quota usage threshold for critical alert, in percent defaults to 95
        -w      warning threshold level: quota usage threshold for warning alert, in percent defaults to 90
```

### License

GNU GENERAL PUBLIC LICENSE. See [LICENSE](LICENSE)

