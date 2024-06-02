# Sentinel
Monitoring service for Linux and OpenPanel

![sentinel logo](assets/sentinel.svg)


## Features

Sentinel is a set-and-forget service that you can install on Ubuntu and it will monitor system services and resource usage.

It is powered by AI, and can perform necessary actions in order to resolve problems.

Examples include:

- **Mitigating DoS attacks** - Automatically reconfigure Nginx and UFW limits when synflood, bruteforce, DoS or other types of attacks are detected.
- **Restarting failed services** - check service logs and if service crashed look up the fix on the internet and apply to try to bring the service back online.
- **** - 


It supports:

Resource usage monitoring:
- **Resource usage** - ram, cpu and disk usage
- **DoS** - synflood connections, xmlrpc bruteforce
- **Failed services** - nginx, mysql, ufw..
- **Logins** - get notifications of new logins

### Alerts

By default, Sentinel will record the incidents only on log on the server itself. However, you can configure email alerts or integrate third-party tools like telegraf.

- [OpenAdmim alerts](https://community.openpanel.co/d/13-introducing-notifications-center) - if server is running OpenPanel, then alerts will automatically appear in OpenAdmin Notifications.
- [Email alerts](https://openpanel.co/docs/changelog/0.1.6/#email-alerts) - can be enabled in the config.
- Telegraf - soon


