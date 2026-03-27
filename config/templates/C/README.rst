************
Project_Name
************

Overview
========
Brief description of the library and its purpose. Describe what problem this
library solves and its intended use.

Features
========
- Feature 1
- Feature 2
- Feature 3

Project Structure
=================
::

  Project_Name/
  ├── Project_Name/        # Source code
  │   ├── include/         # Public headers
  │   ├── simd/            # SIMD implementations (if applicable)
  │   ├── test/            # Unit tests (cmocka)
  │   └── CMakeLists.txt
  ├── scripts/
  │   ├── unix/            # Linux/macOS scripts
  │   └── Windows/         # Windows batch scripts
  ├── docs/
  │   └── doxygen/         # Doxygen + Sphinx docs
  └── README.rst

Requirements
============
- Git
- CMake (version X.YY.ZZ or later)
- C compiler (GCC, Clang, or MSVC)

Testing:
- cmocka

Optional:
- valgrind (Linux only, for memory checking)

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
**Linux (valgrind optional):**

.. code-block:: bash

  cd build/debug
  valgrind ./unit_tests

**macOS/Windows:**

.. code-block:: bash

  cd build/debug
  ./unit_tests

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
- Add feature X
- Improve performance in Y
- Extend API coverage

Contributing
============
Pull requests are welcome. For major changes, please open an issue first to
discuss proposed modifications.

License
=======
This project is licensed under the MIT License.
