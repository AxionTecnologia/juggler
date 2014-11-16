#! /usr/bin/env python

activate_this = '/home/axion/webapps/taxicab_fees/current/activate_this.py'
execfile(activate_this, dict(__file__=activate_this, path='/home/axion/webapps/taxicab_fees/current/lib/python2.7/site-packages'))
import os
import tornado.httpserver
import tornado.ioloop
import tornado.wsgi
import sys
from django.core.wsgi import get_wsgi_application

sys.path.append('/home/axion/webapps/taxicab_fees/current/taxicab_fees/taxicab_fees')
sys.path.append('/home/axion/webapps/taxicab_fees/current/taxicab_fees')

def main():
  os.environ.setdefault("DJANGO_SETTINGS_MODULE", "taxicab_fees.settings")
  application = get_wsgi_application()
  container = tornado.wsgi.WSGIContainer(application)
  http_server = tornado.httpserver.HTTPServer(container)
  http_server.listen(13459)
  tornado.ioloop.IOLoop.instance().start()

if __name__ == "__main__":
  main()
