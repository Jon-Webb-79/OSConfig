.. _system_config:

*******************************
System Services & Configuration
*******************************

This section provides guidance on configuring and managing essential system 
services that are commonly used across multiple operating systems, including 
Arch Linux, Pop!_OS, and macOS. These services form the backbone of a secure 
and reliable development environment and are typically independent of any 
single platform, although implementation details may vary.

Topics covered in this section include secure remote access (SSH), intrusion 
prevention tools such as Fail2Ban, task scheduling with cron, and other 
foundational utilities. Each topic focuses on practical configuration, 
recommended best practices, and system-level integration to ensure consistent 
behavior across environments.

In addition to setup instructions, this section includes troubleshooting 
guidance for diagnosing and resolving common issues. Emphasis is placed on 
understanding service behavior, log inspection, and configuration validation 
so that users can effectively maintain and debug their systems.

The goal of this section is to provide a centralized reference for core system 
services, enabling users to build a secure, automated, and maintainable 
workflow regardless of the underlying operating system.

.. _config_files:

Configuration Files
===================

At this stage, the required software packages have been installed, but no
configuration has been applied. This section installs and applies configuration
files from the OSConfig repository.

.. warning::

   This section describes the manual configuration process in detail. These steps
   can be automated using:

   .. code-block:: bash

      ~/Code_Dev/OS/OSConfig/scripts/config.sh

   Running this script may overwrite existing configuration files. It is strongly
   recommended to review the script and back up any important files before
   execution.

Clone Configuration Repository
------------------------------

Clone the configuration repository:

.. code-block:: bash

   cd ~/Code_Dev/OS
   git clone https://github.com/Jon-Webb-79/OSConfig.git

Verify the repository exists:

.. code-block:: bash

   ls ~/Code_Dev/OS/OSConfig

Powerline Configuration
-----------------------

Verify that powerline is installed:

.. code-block:: bash

   ls /usr/share/powerline/

If the directory exists, no further action is required.

If it does not exist, install the configuration:

.. code-block:: bash

   sudo cp -r ~/Code_Dev/OS/OSConfig/config/shell/powerline /usr/share/

.. note::

   Copying to ``/usr/share`` requires elevated privileges. Ensure the source
   directory exists before running this command.

Neovim Configuration
--------------------

Install Neovim configuration:

.. code-block:: bash

   cp -r ~/Code_Dev/OS/OSConfig/config/nvim ~/.config/nvim

Launch Neovim to initialize plugins:

.. code-block:: bash

   nvim

The Lazy plugin manager will automatically install required plugins on first run.

Shell Configuration
-------------------

Install shell configuration files:

.. code-block:: bash

   cp -r ~/Code_Dev/OS/OSConfig/config/shell ~/.config/
   cp ~/Code_Dev/OS/OSConfig/.zshrc ~/.zshrc
   cp ~/Code_Dev/OS/OSConfig/config/.zsh_profile ~/.zsh_profile
   cp ~/Code_Dev/OS/OSConfig/config/.bashrc ~/.bashrc
   cp ~/Code_Dev/OS/OSConfig/config/.bash_profile ~/.bash_profile

Apply configuration changes:

.. code-block:: bash

   source ~/.bashrc

Set Zsh as the default shell:

.. code-block:: bash

   chsh -s /bin/zsh

Log out and log back in for changes to take effect.

tmux Configuration
------------------

Install tmux configuration:

.. code-block:: bash

   cp ~/Code_Dev/OS/OSConfig/config/.tmux.conf ~/.tmux.conf

Verify:

.. code-block:: bash

   tmux

A configured tmux session should launch.

Ghostty Configuration
---------------------

Install Ghostty configuration:

.. code-block:: bash

   cp -r ~/Code_Dev/OS/OSConfig/config/ghostty ~/.config/ghostty

Start Ghostty to verify configuration is applied.

.. note::

   Additional visual effects (e.g., shaders) can be enabled by editing
   ``~/.config/ghostty/config``.

Code Templates
--------------

Install development templates:

.. code-block:: bash

   cp -r ~/Code_Dev/OS/OSConfig/config/templates ~/.config/templates

These templates support the integrated development workflow using tmux and Neovim.

Download Management
-------------------

Install utility scripts for managing cache and downloads:

.. code-block:: bash

   mkdir -p ~/scripts
   cp ~/Code_Dev/OS/OSConfig/config/cleanCache.sh ~/scripts/
   cp ~/Code_Dev/OS/OSConfig/config/mngDownloads.sh ~/scripts/
   chmod +x ~/scripts/*.sh

These scripts can be executed from the ``~/scripts`` directory to:
- clean system cache
- organize and manage the ``Downloads`` directory

Backups
-------

Install the backup utility:

.. code-block:: bash

   sudo cp ~/Code_Dev/OS/OSConfig/config/core_backup /usr/local/bin/core_backup
   sudo chmod +x /usr/local/bin/core_backup

This script enables system backups using ``rsync``.

Usage:

.. code-block:: bash

   sudo core_backup

This script can also be scheduled using ``cron`` for automated backups.

.. note::

   The backup script is installed in ``/usr/local/bin`` so it is available
   system-wide. Administrative privileges are required to execute it.

System Utilities
================
This section describes the process of setting up and configuring system
utility tools.

Cron (Task Scheduling)
----------------------

Cron is a time-based job scheduler used to automate recurring tasks such as
backups, log cleanup, and system maintenance.

More information can be found in the 
`Arch Linux Cron Wiki <https://wiki.archlinux.org/title/cron>`_.

Verify Installation (Linux)
~~~~~~~~~~~~~~~~~~~~~~~~~~~

On Linux systems, verify that cron is installed:

.. code-block:: bash

   crontab -l

If the command is not found, install cron:

- Arch Linux:

  .. code-block:: bash

     sudo pacman -S cronie
     sudo systemctl enable cronie
     sudo systemctl start cronie

- Pop!_OS / Ubuntu:

  .. code-block:: bash

     sudo apt install cron
     sudo systemctl enable cron
     sudo systemctl start cron

macOS Notes
~~~~~~~~~~~

macOS does not rely on cron by default. Instead, it uses ``launchd`` for
task scheduling. However, cron is still available and functional for
user-level jobs.

Cron File Locations
~~~~~~~~~~~~~~~~~~~

Cron jobs can be defined at both the user and system levels.

User Cron Files:

- Managed via:

  .. code-block:: bash

     crontab -e

- Stored internally (do not edit directly):

  - Linux: ``/var/spool/cron/<username>``
  - macOS: ``/usr/lib/cron/tabs/<username>``

System Cron Files (Linux only):

- ``/etc/crontab`` — system-wide cron configuration  
- ``/etc/cron.d/`` — additional cron job definitions  
- ``/etc/cron.daily/`` — scripts run daily  
- ``/etc/cron.weekly/`` — scripts run weekly  
- ``/etc/cron.monthly/`` — scripts run monthly  

.. note::

   System-level cron jobs typically require root privileges.

Cron Format
~~~~~~~~~~~

Cron entries follow this format:

.. code-block:: bash

   # ┌───────────── minute (0 - 59)
   # │ ┌───────────── hour (0 - 23)
   # │ │ ┌───────────── day of month (1 - 31)
   # │ │ │ ┌───────────── month (1 - 12)
   # │ │ │ │ ┌───────────── day of week (0 - 6) (Sunday = 0 or 7)
   # │ │ │ │ │
   # * * * * * command

Example
~~~~~~~

Run a backup script every day at 2:00 AM:

.. code-block:: bash

   0 2 * * * /usr/local/bin/core_backup

Run a cleanup script every hour:

.. code-block:: bash

   0 * * * * ~/scripts/cleanCache.sh

Edit your crontab:

.. code-block:: bash

   crontab -e

List existing jobs:

.. code-block:: bash

   crontab -l

.. warning::

   Always use ``crontab -e`` to edit cron jobs. Do not modify files in
   ``/var/spool`` directly, as this may corrupt your cron configuration.

Fail2Ban Configuration
----------------------

Fail2Ban is a security utility that monitors log files and automatically bans
IP addresses that show malicious behavior, such as repeated failed login attempts.

More information can be found in the 
`Arch Linux Fail2Ban Wiki <https://wiki.archlinux.org/title/fail2ban>`_.

Installation
~~~~~~~~~~~~

Verify if Fail2Ban is installed:

.. code-block:: bash

   which fail2ban

If no path is returned, install Fail2Ban:

- Arch Linux:

  .. code-block:: bash

     sudo pacman -S fail2ban

- Pop!_OS / Ubuntu:

  .. code-block:: bash

     sudo apt install fail2ban

Configuration
~~~~~~~~~~~~~

Fail2Ban uses ``.conf`` files for defaults and ``.local`` files for user
configuration. You should **never edit ``.conf`` files directly**.

Instead, copy the default configuration files:

.. code-block:: bash

   sudo cp /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local
   sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

Edit the local configuration:

.. code-block:: bash

   sudo nvim /etc/fail2ban/jail.local

Recommended settings:

- ``ignoreip`` — IP addresses that should never be banned (e.g., localhost)

  .. code-block:: text

     ignoreip = 127.0.0.1/8 ::1 <your-ip>

- ``findtime`` — Time window to count failed attempts

  .. code-block:: text

     findtime = 7m

- ``maxretry`` — Number of failed attempts before banning

  .. code-block:: text

     maxretry = 3

- ``bantime`` — Duration of the ban

  .. code-block:: text

     bantime = 1h

Enable jails (example: SSH protection):

.. code-block:: text

   [sshd]
   enabled = true

.. note::

   Only enable jails for services that are installed and actively used.

Optional: Adjust database purge time:

.. code-block:: bash

   sudo nvim /etc/fail2ban/fail2ban.local

Add or modify:

.. code-block:: text

   dbpurgeage = 7d

Start and Enable Fail2Ban
~~~~~~~~~~~~~~~~~~~~~~~~~

Start the service:

.. code-block:: bash

   sudo systemctl start fail2ban

Enable on boot:

.. code-block:: bash

   sudo systemctl enable fail2ban

Verification
~~~~~~~~~~~~

Check service status:

.. code-block:: bash

   sudo systemctl status fail2ban

Check active jails:

.. code-block:: bash

   sudo fail2ban-client status

Check a specific jail:

.. code-block:: bash

   sudo fail2ban-client status sshd

.. warning::

   Always include your own IP address in ``ignoreip`` to avoid locking yourself
   out of your system.

rsync (File Synchronization and Backup)
---------------------------------------

``rsync`` is a utility used to efficiently copy and synchronize files between
locations. It is commonly used for backups, mirroring directories, and
transferring files over SSH.

More information can be found in the 
`Arch Linux rsync Wiki <https://wiki.archlinux.org/title/rsync>`_.

Installation
~~~~~~~~~~~~

Install ``rsync`` if it is not already available:

- Arch Linux:

  .. code-block:: bash

     sudo pacman -S rsync

- Pop!_OS / Ubuntu:

  .. code-block:: bash

     sudo apt install rsync

- macOS:

  .. code-block:: bash

     brew install rsync

Basic Usage
~~~~~~~~~~~

This section demonstrates backing up a home directory to an external drive.

Assume the backup drive is mounted at:

.. code-block:: text

   /run/media/<username>/drive_1

Dry Run (Recommended)
~~~~~~~~~~~~~~~~~~~~~

Before performing a backup, run a dry test:

.. code-block:: bash

   rsync -avhn --dry-run /home/<username>/ /run/media/<username>/drive_1/

This command will display what changes would be made without copying any files.

Initial Backup
~~~~~~~~~~~~~~

Run the initial backup:

.. code-block:: bash

   rsync -avh /home/<username>/ /run/media/<username>/drive_1/

Expected behavior:

- All files are copied
- Directory structure is preserved
- Existing files are skipped

Incremental Backup
~~~~~~~~~~~~~~~~~~

For subsequent backups, use:

.. code-block:: bash

   rsync -avh --delete /home/<username>/ /run/media/<username>/drive_1/

This ensures the backup is an exact mirror of the source directory.

.. warning::

   The ``--delete`` flag removes files from the destination that no longer
   exist in the source directory. Use with caution.

Common Flags
~~~~~~~~~~~~

- ``-a`` — archive mode (preserves permissions, timestamps, etc.)
- ``-v`` — verbose output
- ``-h`` — human-readable file sizes
- ``-n`` — dry run (no changes made)
- ``--delete`` — remove extraneous files from destination

Examples
~~~~~~~~

Backup a specific directory:

.. code-block:: bash

   rsync -avh ~/Documents/ /backup/Documents/

Backup over SSH:

.. code-block:: bash

   rsync -avh ~/Documents/ user@remote:/backup/Documents/

Exclude files:

.. code-block:: bash

   rsync -avh --exclude=".cache" /home/<username>/ /backup/

.. note::

   Always include a trailing slash (``/``) on the source directory when you
   intend to copy its contents rather than the directory itself.

SSH (Secure Shell)
------------------

SSH is used to securely connect to remote systems, transfer files, and automate
administration tasks. It supports password-based and key-based authentication.

Client-Side Setup
~~~~~~~~~~~~~~~~~

Installation
^^^^^^^^^^^^

Verify SSH is installed:

.. code-block:: bash

   which ssh

If not installed:

- Arch Linux:

  .. code-block:: bash

     sudo pacman -S openssh

- Pop!_OS / Ubuntu:

  .. code-block:: bash

     sudo apt install openssh-client

- macOS:

  SSH is pre-installed.

Basic Connection Test
^^^^^^^^^^^^^^^^^^^^^

Test connection to a server:

.. code-block:: bash

   ssh -p <port> <username>@<ip_address>

Expected behavior:

- Prompt for password
- Successful login to remote system

Exit the session:

.. code-block:: bash

   exit

Generate SSH Key Pair
^^^^^^^^^^^^^^^^^^^^^

Create a key pair:

.. code-block:: bash

   ssh-keygen -t ed25519 -C "<description>"

Recommended:

- Use ``ed25519`` key type
- Use a strong passphrase

This generates:

- Private key: ``~/.ssh/id_ed25519``
- Public key: ``~/.ssh/id_ed25519.pub``

.. warning::

   Never share your private key.

Copy Key to Server
^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   ssh-copy-id -i ~/.ssh/id_ed25519.pub <username>@<ip_address>

Verify:

.. code-block:: bash

   ssh -p <port> <username>@<ip_address>

Expected:

- Login without password
- Prompt only for passphrase (if set)

SSH Agent (Optional)
^^^^^^^^^^^^^^^^^^^^

Start the SSH agent:

.. code-block:: bash

   eval "$(ssh-agent -s)"

Add your key:

.. code-block:: bash

   ssh-add ~/.ssh/id_ed25519

Verify:

.. code-block:: bash

   ssh-add -l

SSH Config File
^^^^^^^^^^^^^^^

Create a config file:

.. code-block:: bash

   nvim ~/.ssh/config

Example configuration:

.. code-block:: text

   Host myserver
       HostName <ip_address>
       Port <port>
       User <username>
       IdentityFile ~/.ssh/id_ed25519

Connect using alias:

.. code-block:: bash

   ssh myserver

---

Server-Side Setup
~~~~~~~~~~~~~~~~~

Installation
^^^^^^^^^^^^

- Arch Linux:

  .. code-block:: bash

     sudo pacman -S openssh

- Pop!_OS / Ubuntu:

  .. code-block:: bash

     sudo apt install openssh-server

- macOS (server use):

  Enable via System Settings → Sharing → Remote Login

Service Management
^^^^^^^^^^^^^^^^^^

Start SSH service:

.. code-block:: bash

   sudo systemctl start sshd

Enable on boot:

.. code-block:: bash

   sudo systemctl enable sshd

Check status:

.. code-block:: bash

   sudo systemctl status sshd

Configuration
^^^^^^^^^^^^^

Edit SSH daemon config:

.. code-block:: bash

   sudo nvim /etc/ssh/sshd_config

Recommended settings:

.. code-block:: text

   Port <custom_port>
   PermitRootLogin no
   PasswordAuthentication no
   AllowUsers <username>

.. warning::

   Ensure SSH key authentication is working before disabling password login.

Restart service:

.. code-block:: bash

   sudo systemctl restart sshd

File Permissions
^^^^^^^^^^^^^^^^

Secure SSH files:

.. code-block:: bash

   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/authorized_keys

.. note::

   Avoid using immutable flags (``chattr``) unless you fully understand the
   implications, as they can complicate system maintenance.

Monitoring
^^^^^^^^^^

View recent login attempts:

.. code-block:: bash

   journalctl -u sshd --since "10 minutes ago"

USB
---

This section describes how to identify, unmount, format, and label a USB drive.

Determine Device Location
-------------------------

To identify connected drives, use:

.. code-block:: bash

   lsblk

Example output:

.. code-block:: text

   NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
   sda      8:0    0  500G  0 disk 
   └─sda1   8:1    0  500G  0 part /
   sdb      8:16   1   32G  0 disk 
   └─sdb1   8:17   1   32G  0 part /run/media/user/USB

In this example, the USB device is ``/dev/sdb1``.

Alternatively:

.. code-block:: bash

   df -h

Unmount the Drive
-----------------

Before modifying or formatting a drive, it must be unmounted:

.. code-block:: bash

   sudo umount /dev/sdb1

.. note::

   If the device is busy, ensure no files are open on the drive.

Format the Drive (Linux)
------------------------

To format the drive with a Linux filesystem:

.. code-block:: bash

   sudo mkfs.ext4 /dev/sdb1

.. warning::

   Formatting will permanently erase all data on the device.

Rename the Drive (Linux)
------------------------

To label an ext4 filesystem, use ``e2label`` (part of ``e2fsprogs``).

Verify installation:

.. code-block:: bash

   which e2label

If not installed:

- Arch Linux:

  .. code-block:: bash

     sudo pacman -S e2fsprogs

- Pop!_OS / Ubuntu:

  .. code-block:: bash

     sudo apt install e2fsprogs

Rename the drive:

.. code-block:: bash

   sudo e2label /dev/sdb1 user_defined_label

macOS Notes
-----------

macOS uses different tools for managing USB devices.

List disks:

.. code-block:: bash

   diskutil list

Unmount a disk:

.. code-block:: bash

   diskutil unmount /dev/disk2s1

Format a disk:

.. code-block:: bash

   diskutil eraseDisk APFS USB_NAME /dev/disk2

Common filesystem options:

- ``APFS`` — macOS native (recommended for macOS-only use)
- ``ExFAT`` — cross-platform (macOS + Linux + Windows)

.. note::

   Device names on macOS typically follow the format ``/dev/diskXsY``.

journalctl (System Logs)
------------------------

``journalctl`` is used to view logs collected by the systemd journal. It is
essential for debugging system services, SSH connections, and automation tasks.

Basic Usage
~~~~~~~~~~~

View all logs:

.. code-block:: bash

   journalctl

View recent logs:

.. code-block:: bash

   journalctl -n 50

Follow logs in real time:

.. code-block:: bash

   journalctl -f

Filter by Service
~~~~~~~~~~~~~~~~~

View logs for a specific service:

.. code-block:: bash

   journalctl -u sshd

Examples:

.. code-block:: bash

   journalctl -u fail2ban
   journalctl -u cron

Filter by Time
~~~~~~~~~~~~~~

View logs from the last 10 minutes:

.. code-block:: bash

   journalctl --since "10 minutes ago"

View logs from today:

.. code-block:: bash

   journalctl --since today

Filter by Priority
~~~~~~~~~~~~~~~~~~

Show only errors:

.. code-block:: bash

   journalctl -p err

Common priorities:

- ``err`` — errors  
- ``warning`` — warnings  
- ``info`` — general information  

Disk Usage
~~~~~~~~~~

Check journal size:

.. code-block:: bash

   journalctl --disk-usage

Limit log size:

.. code-block:: bash

   sudo journalctl --vacuum-time=7d

This removes logs older than 7 days.

Persistent Logs
~~~~~~~~~~~~~~~

Enable persistent logging:

.. code-block:: bash

   sudo mkdir -p /var/log/journal
   sudo systemctl restart systemd-journald

.. note::

   By default, some systems store logs in memory only.

macOS Notes
~~~~~~~~~~~

macOS does not use ``journalctl``. Instead, logs can be accessed with:

.. code-block:: bash

   log show

or:

.. code-block:: bash

   log stream
