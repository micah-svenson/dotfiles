Claude Code Notification Sounds
================================

Play a sound when Claude finishes responding or needs permission approval.
No server, no dashboard — just a hook script and sound files.


SETUP (5 minutes)
-----------------

1. UNZIP this folder somewhere permanent, e.g.:
   - Windows: C:\Users\YourName\claude-notify\
   - Mac/Linux: ~/claude-notify/

2. MAKE THE SCRIPT EXECUTABLE (Mac/Linux only):
   chmod +x claude-notify.sh

3. EDIT your Claude Code hooks config:

   Open (or create) this file:
     ~/.claude/settings.json

   Add the following (replace the path with where you put the folder):

   --- WINDOWS (Git Bash) ---
   {
     "hooks": {
       "Stop": [
         {
           "hooks": [
             {
               "type": "command",
               "command": "bash /c/Users/YourName/claude-notify/claude-notify.sh",
               "timeout": 5
             }
           ]
         }
       ],
       "Notification": [
         {
           "hooks": [
             {
               "type": "command",
               "command": "bash /c/Users/YourName/claude-notify/claude-notify.sh",
               "timeout": 5
             }
           ]
         }
       ]
     }
   }

   --- MAC / LINUX ---
   {
     "hooks": {
       "Stop": [
         {
           "hooks": [
             {
               "type": "command",
               "command": "bash ~/claude-notify/claude-notify.sh",
               "timeout": 5
             }
           ]
         }
       ],
       "Notification": [
         {
           "hooks": [
             {
               "type": "command",
               "command": "bash ~/claude-notify/claude-notify.sh",
               "timeout": 5
             }
           ]
         }
       ]
     }
   }

   NOTE: If you already have hooks in settings.json, merge the Stop and
   Notification entries into your existing hooks object. Don't replace
   the whole file.

4. RESTART Claude Code. That's it — you should hear a sound whenever
   Claude finishes responding or hits a permission prompt.


CHANGING THE SOUND
------------------

Set the CLAUDE_NOTIFY_SOUND environment variable to any filename
(without .wav) from the sounds/ folder:

  export CLAUDE_NOTIFY_SOUND=laser

Or edit claude-notify.sh line 7 and change "soft-chime" to your pick.

Available sounds:
  soft-chime  - Gentle bell (default)
  alert-tone  - Slightly urgent
  ping        - Classic notification
  bell        - Ding-dong
  coin        - Mario-style coin collect
  laser       - Pew pew zap
  boing       - Spring bounce
  quack       - Duck


WHAT THE HOOKS DO
-----------------

- "Stop" fires when Claude finishes responding (your turn to type)
- "Notification" fires when Claude hits a permission prompt (needs approval)

Both just play the sound file. Nothing is sent anywhere, no network
calls, no tracking. It's a local sound and nothing else.


TROUBLESHOOTING
---------------

No sound?
  - Make sure the path in settings.json points to the actual location
  - On Windows: use forward slashes in the path (/c/Users/... not C:\Users\...)
  - On Mac: run "chmod +x claude-notify.sh"
  - On Linux: make sure pulseaudio (paplay) or alsa (aplay) is installed
  - Test manually: bash /path/to/claude-notify.sh < /dev/null

Hooks not firing?
  - Restart Claude Code after editing settings.json
  - Check ~/.claude/settings.json is valid JSON (no trailing commas!)
  - Run "claude --version" to make sure you're on a version that supports hooks
