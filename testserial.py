""" 
first test code for walker project:

TODO in order:
- check and assign all 3 serial streams correctly
- write these to a log file as they come in to check sync
- timestamping
- parse each value from the 3 streams -> 10 or 11 data sources (or how many we have in testcase)
- check for errors (eg. same values consistently in data source, GPS problems) and alert usre to error
- design wx user interface
- integrate with matplotlib
- EEG decoding and analysis
- walk-flow of initialise, is all going, keep user updates
"""

from threading import Thread
import time, datetime
import serial
import os
import pprint
import random
import sys
import wx
