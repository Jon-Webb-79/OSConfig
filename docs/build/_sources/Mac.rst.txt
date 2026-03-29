.. _mac_os:

*******************
macOS Overview
*******************

`macOS <https://www.apple.com/mac/>`_ is a Unix-based operating system developed 
by `Apple Inc. <https://www.apple.com/>`_ for its Mac hardware lineup. It combines 
a polished graphical user interface with a stable Unix foundation, making it 
popular among developers and general users.

The primary advantage of macOS is its stability, ease of use, and strong ecosystem 
integration. However, it is limited to Apple hardware and offers less low-level 
system control compared to Linux distributions.

Pre-Installation
================

No pre-installation process is required.

Installation
============

macOS is pre-installed on Apple hardware.

Post Installation
=================

This section describes how to install core development tools on macOS. Configuration 
is handled separately in :ref:`System <config_files>`.

Install Homebrew
----------------

Install Homebrew (package manager):

.. code-block:: bash

   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

Update Homebrew:

.. code-block:: bash

   brew update
   brew upgrade

Install Core Packages
---------------------

.. code-block:: bash

   brew install git gh fzf bat tree htop btop tmux rsync neofetch

Verify:

.. code-block:: bash

   git --version
   gh --version

GitHub Setup
------------

Authenticate with GitHub:

.. code-block:: bash

   gh auth login

Development Directory Structure
-------------------------------

.. code-block:: bash

   mkdir -p ~/Code_Dev/{Python,C,C++,OS}

Install Fonts
-------------

.. code-block:: bash

   git clone https://github.com/powerline/fonts.git --depth=1
   cd fonts
   ./install.sh
   cd ..
   rm -rf fonts

Install Neovim
--------------

.. code-block:: bash

   brew install neovim

Install lazy.nvim:

.. code-block:: bash

   git clone https://github.com/folke/lazy.nvim \
     ~/.local/share/nvim/lazy/lazy.nvim

Install Node.js and Tree-sitter
-------------------------------

.. code-block:: bash

   brew install node
   npm install -g tree-sitter-cli

Install Python
--------------

Install Python and development tools:

.. code-block:: bash

   brew install python pipx

Enable pipx:

.. code-block:: bash

   pipx ensurepath

Restart your shell after running this command.

Install Poetry:

.. code-block:: bash

   pipx install poetry

Configure Poetry:

.. code-block:: bash

   poetry config virtualenvs.in-project true

.. note::

   Avoid modifying the system Python environment directly. Use ``venv`` or
   ``pipx`` for isolated environments.

Install C/C++ Toolchain
-----------------------

.. code-block:: bash

   xcode-select --install
   brew install cmake gcc googletest cmocka

Install LaTeX
-------------

.. code-block:: bash

   brew install --cask mactex

Install System Utilities
------------------------

.. code-block:: bash

   brew install openssh fail2ban
   brew install --cask libreoffice

.. warning::

   Some tools installed via third-party scripts should be reviewed before use.

Update Brew 
===========
Packages installed by Brew should be updated every few days via the commands:

.. code-block:: bash 

   brew doctor
   brew update
   brew upgrade
