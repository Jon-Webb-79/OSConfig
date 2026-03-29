*********
OSConfig
*********

OSConfig is a cross-platform development environment and system configuration
repository for Linux and macOS systems. It provides a consistent setup for
tools such as tmux, Neovim, and modern terminal environments, along with
documentation for installing and configuring complete operating systems.

The goal of this repository is to create a reproducible, portable, and efficient
development environment across multiple platforms.

Features
========

- Unified configuration for:
  - tmux
  - Neovim
  - Ghostty terminal
- Cross-platform support:
  - Arch Linux
  - Pop!_OS (Ubuntu-based)
  - macOS
- System configuration documentation:
  - SSH
  - Fail2Ban
  - rsync backups
  - cron scheduling
  - journald logging
- Automated setup script for applying configurations

Repository Structure
====================

::

   OSConfig/
   ├── config/        # Configuration files (nvim, tmux, shell, ghostty)
   ├── scripts/       # Setup and utility scripts
   ├── docs/          # Sphinx documentation (OS installation + configuration)
   └── README.rst

Getting Started
===============

Clone the repository:

.. code-block:: bash

   git clone https://github.com/Jon-Webb-79/OSConfig.git
   cd OSConfig

Apply configuration automatically:

.. code-block:: bash

   ./scripts/config.sh

.. warning::

   The configuration script may overwrite existing configuration files in your
   home directory. Review the script before running.

Documentation
=============

Full documentation is available in the ``docs/`` directory and includes:

- Operating system installation guides (Arch, Pop!_OS, macOS)
- Post-installation setup
- Development environment configuration
- System utilities and troubleshooting

To build the documentation:

.. code-block:: bash

   cd docs
   make html

Philosophy
==========

OSConfig emphasizes:

- Reproducibility across systems
- Minimal reliance on system defaults
- Separation of configuration (System.rst) from OS-specific setup
- Automation with transparency (manual steps + scripts)

Future Work
===========

- Expanded macOS system configuration
- Additional automation scripts
- Improved cross-platform abstractions
- Enhanced development tooling integration

License
=======

Specify your license here (e.g., MIT, BSD, etc.).
