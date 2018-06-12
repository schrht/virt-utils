# virt-utils
Some utilities used for Linux testing

# IDEs
VSC (Visual Studio Code) is recommended.

# Coding style
Please do PEP-8 conversion for Python code before submiting.
Suggest using `pydocstyle` to write cool Python docstrings.
Suggest adding comments at the begining of the script to record the changes.

Python:
```python
#!/usr/bin/env python
"""Generate FIO Test Report.

Interface between StoragePerformanceTest.py
StoragePerformanceTest.py should do:
1. the fio outputs should be at least in json+ format
   the "fio --group_reporting" must be used
2. save the fio outputs into *.fiolog
3. put all *.fiolog files into ./fio_result/
4. empty ./fio_report/ folder
5. pass the additional information by "fio --description"
   a) "driver" - frontend driver, such as SCSI or IDE
   b) "format" - the disk format, such as raw or xfs
   c) "round" - the round number, such as 1, 2, 3...
   d) "backend" - the hardware which data image based on

History:
v1.0    2018-02-09  cheshi  Finish all the functions.
v2.0    2018-03-19  cheshi  Use Pandas to replace PrettyTable.
v2.0.1  2018-03-23  cheshi  Use "NaN" to replace "error" and "n/a".
v2.0.2  2018-03-23  cheshi  Consider "Round" while sorting the DataFrame.
"""
```

Shell:
```bash
#!/usr/bin/env bash

# Description: 
# Generate FIO Test Report.
#
# Interface between StoragePerformanceTest.py
# StoragePerformanceTest.py should do:
# 1. the fio outputs should be at least in json+ format
#    the "fio --group_reporting" must be used
# 2. save the fio outputs into *.fiolog
# 3. put all *.fiolog files into ./fio_result/
# 4. empty ./fio_report/ folder
# 5. pass the additional information by "fio --description"
#    a) "driver" - frontend driver, such as SCSI or IDE
#    b) "format" - the disk format, such as raw or xfs
#    c) "round" - the round number, such as 1, 2, 3...
#    d) "backend" - the hardware which data image based on
#
# History:
# v1.0    2018-02-09  cheshi  Finish all the functions.
# v2.0    2018-03-19  cheshi  Use Pandas to replace PrettyTable.
# v2.0.1  2018-03-23  cheshi  Use "NaN" to replace "error" and "n/a".
# v2.0.2  2018-03-23  cheshi  Consider "Round" while sorting the DataFrame.
```

# Contribute
For collaborators:
1. `git clone git@github.com:SCHEN2015/virt-utils.git`
2. Modify the code and commit the change
3. `git pull --rebase` before push your commits
4. `git push`

For others:
1. Fork this repo
2. Modify the code and commit the change
3. Push the commits to Github.com
4. Generate "Pull Request"
