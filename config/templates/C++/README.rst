************
Project_Name
************

Overview
========
Brief description of the C++ library. Explain the purpose, scope, and key
design goals (performance, portability, abstraction, etc.).

Features
========
- Feature 1
- Feature 2
- Feature 3

Project Structure
=================
::

  Project_Name/
  ├── Project_Name/
  │   ├── include/         # Public headers
  │   ├── simd/            # SIMD (if applicable)
  │   ├── test/            # GoogleTest unit tests
  │   └── CMakeLists.txt
  ├── scripts/
  │   ├── unix/
  │   └── Windows/
  ├── docs/
  │   └── doxygen/
  └── README.rst

Requirements
============
- Git
- CMake (version X.YY.ZZ or later)
- C++ compiler (GCC, Clang, or MSVC with C++17 support)

Testing:
- GoogleTest (automatically fetched via CMake)

Build and Test
==============

Getting the Code
----------------
.. code-block:: bash

  git clone <repo_url>
  cd Project_Name

Debug Build (with tests)
------------------------
**Linux/macOS:**

.. code-block:: bash

  cd scripts/unix
  ./debug.sh

**Windows:**

.. code-block:: batch

  cd scripts\Windows
  debug.bat

Run Tests
---------
.. code-block:: bash

  cd build/debug
  ./unit_tests

Tests are automatically discovered using GoogleTest.

Static Build
------------
.. code-block:: bash

  cd scripts/unix
  ./static.sh

Installation
============
**Linux/macOS:**

.. code-block:: bash

  cd scripts/unix
  sudo ./install.sh

**Windows:**

Run ``scripts\Windows\install.bat`` as Administrator.

Documentation
=============
Documentation is generated using Doxygen and Sphinx.

Setup:
.. code-block:: bash

  cd docs/doxygen
  source .venv/bin/activate
  pip install -r requirements.txt

Build docs:
.. code-block:: bash

  doxygen Doxyfile
  sphinx-build -b html sphinx_docs build

Future Work
===========
- Add new modules
- Improve template abstractions
- Extend SIMD support

Contributing
============
Pull requests are welcome. For major changes, please open an issue first to
discuss proposed modifications.

License
=======
This project is licensed under the MIT License.
