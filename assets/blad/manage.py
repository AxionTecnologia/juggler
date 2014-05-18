#!/usr/bin/env python
activate_this = '/home/axion/webapps/blad/current/activate_this.py'
execfile(activate_this, dict(__file__=activate_this, path='/home/axion/webapps/blad/current/lib/python2.7/site-packages'))
import os
import sys

if __name__ == "__main__":
  os.environ.setdefault("DJANGO_SETTINGS_MODULE", "blad.settings")

  from django.core.management import execute_from_command_line
  execute_from_command_line(sys.argv)
