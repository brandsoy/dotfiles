✅ Option 1: Block Ads with Custom /etc/hosts + GitHub-hosted Blocklists
🔧 Step-by-step setup

1. Backup your current hosts file (recommended)
   sudo cp /etc/hosts /etc/hosts.backup

2. Fetch a curated hosts file
   Use Steven Black’s GitHub project (combines multiple reputable ad-blocking lists):
   curl -o /etc/hosts "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"

3. Flush DNS cache:
   sudo dscacheutil -flushcache
   sudo killall -HUP mDNSResponder

4. Automate updates (e.g. via cron or launchd)

Create a script ~/update-hosts.sh:
#!/bin/bash
curl -o /etc/hosts "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder

Make it executable:
chmod +x ~/update-hosts.sh
Schedule via cron or LaunchAgents for weekly updates.

✅ Step-by-Step: Use launchd to Update /etc/hosts
Because you're modifying a system file (/etc/hosts), you'll need to create a Launch Daemon (runs as root), not a user-level Launch Agent.

🔧 1. Save your script in a root-accessible location
Move your script to a standard location, e.g.:
sudo mkdir -p /usr/local/bin
sudo mv ~/update-hosts.sh /usr/local/bin/update-hosts.sh
sudo chmod +x /usr/local/bin/update-hosts.sh

📝 2. Create a launchd plist file
Create the file:
sudo nano /Library/LaunchDaemons/com.local.updatehosts.plist
Paste this config:

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.local.updatehosts</string>

    <!-- Run every day at 3 AM -->
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>3</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>

    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/update-hosts.sh</string>
    </array>

    <key>StandardOutPath</key>
    <string>/var/log/update-hosts.log</string>

    <key>StandardErrorPath</key>
    <string>/var/log/update-hosts.err</string>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <false/>

</dict>
</plist>

🔐 3. Set proper permissions
sudo chown root:wheel /Library/LaunchDaemons/com.local.updatehosts.plist
sudo chmod 644 /Library/LaunchDaemons/com.local.updatehosts.plist

🚀 4. Load the job into launchd
sudo launchctl load /Library/LaunchDaemons/com.local.updatehosts.plist
To test it manually:
sudo launchctl start com.local.updatehosts

✅ 5. Verify logs
Check the logs:
sudo tail -f /var/log/update-hosts.log
sudo tail -f /var/log/update-hosts.err

🧹 To unload or remove
sudo launchctl unload /Library/LaunchDaemons/com.local.updatehosts.plist
sudo rm /Library/LaunchDaemons/com.local.updatehosts.plist

Let me know if you want to make this run more frequently (e.g. every 6 hours) or only when connected to a network — both are possible with launchd.
That output is just curl's download progress meter, and it's not an error — it's being written to /var/log/update-hosts.err because your launchd job is capturing both stdout and stderr separately.
So you’re seeing the "progress bar" that curl prints to stderr by default.

✅ How to Fix It (Clean up the output)
Option 1: Suppress curl progress with -s or --silent
Edit your script (/usr/local/bin/update-hosts.sh) and make sure curl uses --silent:
#!/bin/bash
{
echo "=== $(date) ==="
curl --silent -o /etc/hosts "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
dscacheutil -flushcache
killall -HUP mDNSResponder
echo "Update complete"
} >> /var/log/update-hosts.log 2>&1
This ensures:

- All output (stdout + stderr) is redirected to the log, not the error log
- curl doesn’t output a progress bar

Option 2: Keep stderr separate, but clean
If you want to keep stdout and stderr in separate files, but make stderr cleaner:
Change curl to:
curl --silent --show-error ...
This will hide the progress bar but still print errors (e.g., 404, timeouts) to stderr.

✅ After fixing the script
Don't forget to reload your launchd job:
sudo launchctl unload /Library/LaunchDaemons/com.local.updatehosts.plist
sudo launchctl load /Library/LaunchDaemons/com.local.updatehosts.plist
Or just test manually:
sudo launchctl start com.local.updatehosts

Let me know if you also want to only update the blocklist if it changed, or add a custom list merge step.
