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
