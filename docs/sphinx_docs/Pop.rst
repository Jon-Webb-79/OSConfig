.. _pop_os:

*******************
Pop!_OS Overview
*******************

`Pop!_OS <https://support.system76.com/articles/pop-basics/>`_ is a 
user-friendly Linux distribution developed by 
`System76 <https://system76.com/>`_, based on Ubuntu. It is designed to 
provide a smooth out-of-the-box experience, particularly for developers, 
engineers, and users working with graphics-intensive applications. Pop!_OS 
includes built-in support for NVIDIA GPUs, a customized GNOME-based desktop 
(COSMIC), and a curated set of tools aimed at productivity and system stability.

The strength of Pop!_OS lies in its balance between usability and performance. 
It offers a polished desktop environment, reliable package management through 
APT, and strong hardware compatibility, making it an excellent choice for both 
beginners and experienced users. On the downside, it provides less low-level 
customization compared to Arch Linux, and its release cycle does not deliver 
updates as rapidly as rolling-release distributions.

Pre-Installation
================

Before beginning the installation, download the Pop!_OS ISO image and create a 
bootable USB drive.

Download the ISO Image
----------------------

Navigate to the `Pop!_OS download page <https://system76.com/pop/download/>`_.

Available options include:

- **Intel/AMD (Standard)** — for most systems  
- **NVIDIA** — for systems with NVIDIA GPUs  
- **Raspberry Pi** — for ARM-based devices  

Select the appropriate version and download the ISO file.

Flash the ISO to a USB Drive
----------------------------

Use a tool such as 
`USB Imager <https://gitlab.com/bztsrc/usbimager>`_ to create a bootable USB.

.. image:: images/usb_imager.png
   :alt: USB Imager download options

.. image:: images/imager.png
   :alt: USB Imager graphical interface

Steps:

1. Select the downloaded ``.iso`` file  
2. Select the USB drive  
3. Enable **Verify**  
4. Click **Write**  

.. warning::

   All data on the USB drive will be erased.

Installation
============

Booting the Installer
---------------------

Insert the USB drive and power on the system. Enter the boot menu 
(commonly accessed via ``F2``, ``F10``, ``F12``, or ``DEL``).

Select the USB device.

Expected option:

.. code-block:: bash

   Pop!_OS install medium (x86_64, UEFI)

Select and press ``Enter``.

Installer Workflow
------------------

The Pop!_OS graphical installer will guide you through:

- Language and keyboard selection  
- Network configuration  
- Disk selection  
- Installation type  

Disk Encryption (Recommended)
-----------------------------

Enable full disk encryption unless you have a specific reason not to.

Expected behavior:

- System prompts for encryption password at boot  
- Disk is automatically configured with encryption  

Complete Installation
---------------------

Follow the remaining prompts to:

- Create a user account  
- Set a password  
- Complete installation  

Once complete:

1. Remove the USB drive  
2. Reboot  

Expected result:

- System boots into the Pop!_OS desktop  
- Login screen appears  

Post Installation
=================

This section describes how to install core packages for a development 
environment on Pop!_OS. Configuration of these tools is handled in 
:ref:`System <config_files>`.

Update System
-------------

Update package lists and upgrade installed packages:

.. code-block:: bash

   sudo apt update
   sudo apt upgrade

Install Core Packages
---------------------

Install commonly used utilities:

.. code-block:: bash

   sudo apt install \
       git gh \
       fzf bat tree htop btop \
       zsh tmux rsync \
       xclip fail2ban \
       libreoffice neofetch

Verify installation:

.. code-block:: bash

   git --version
   gh --version
   zsh --version

GitHub Setup
------------

Authenticate GitHub CLI:

.. code-block:: bash

   gh auth login

Follow the prompts to authenticate.

Update Terminal
---------------

Pop!_OS includes a capable terminal by default through the COSMIC desktop
environment. However, this guide uses ``ghostty`` as the preferred terminal.

Install ``ghostty`` with the following command:

.. code-block:: bash

   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"

Development Directory Structure
-------------------------------

Create development directories:

.. code-block:: bash

   mkdir -p ~/Code_Dev/{Python,C,C++,OS}

Install Google Chrome
---------------------

Download the Debian package from:

`Google Chrome <https://www.google.com/chrome/>`_

Install:

.. code-block:: bash

   cd ~/Downloads
   sudo apt install ./google-chrome-stable_current_amd64.deb

Install Fonts
-------------

Create fonts directory:

.. code-block:: bash

   mkdir -p ~/.fonts

Download fonts from:

`Nerd Fonts <https://www.nerdfonts.com/font-downloads>`_

Install fonts:

.. code-block:: bash

   unzip <font>.zip -d ~/.fonts
   fc-cache -fc

Install Neovim
--------------

Install Neovim from the official release:

.. code-block:: bash

   mkdir -p ~/.local/bin
   cd ~/.local/bin
   curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
   tar xzf nvim-linux-x86_64.tar.gz
   ln -sf ~/.local/bin/nvim-linux-x86_64/bin/nvim ~/.local/bin/nvim

.. note::

   Ensure ``~/.local/bin`` is in your PATH:

   .. code-block:: bash

      export PATH="$HOME/.local/bin:$PATH"

Install Node.js and Tree-sitter
-------------------------------

.. code-block:: bash

   curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
   sudo apt install nodejs
   npm install -g tree-sitter-cli

Install tmux
------------

.. code-block:: bash

   sudo apt install tmux

Install LaTeX
-------------

.. code-block:: bash

   sudo apt install texlive-latex-base texlive-fonts-recommended texlive-fonts-extra

System Utilities
----------------

Install additional tools:

.. code-block:: bash

   sudo apt install snapd

