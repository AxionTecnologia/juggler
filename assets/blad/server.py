#! /usr/bin/env python

activate_this = '/home/axion/webapps/blad/current/activate_this.py'
execfile(activate_this, dict(__file__=activate_this, path='/home/axion/webapps/blad/current/lib/python2.7/site-packages'))
import os
import tornado.httpserver
import tornado.ioloop
import tornado.wsgi
import sys
import django.core.handlers.wsgi

sys.path.append('/home/axion/webapps/blad/current/blad/blad')
sys.path.append('/home/axion/webapps/blad/current/blad')

def main():
  os.environ["DJANGO_SETTINGS_MODULE"] = 'settings'
  application = django.core.handlers.wsgi.WSGIHandler()
  container = tornado.wsgi.WSGIContainer(application)
  http_server = tornado.httpserver.HTTPServer(container)
  http_server.listen(23566)
  tornado.ioloop.IOLoop.instance().start()

if __name__ == "__main__":
  main()
