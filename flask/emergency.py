import flask
from flask import request, jsonify
import subprocess
import os
import json,sys,requests
from subprocess import Popen,PIPE
import collections
import threading
import shutil
import time
from datetime import date
from datetime import datetime, timedelta
from flask import Flask, request, send_from_directory
import logging
logging.getLogger('').handlers = []

app = Flask(__name__)

@app.route('/emergency/<fileName>', methods=['GET'])
def sendlFile(fileName):
  EmergencyFolderPath = "/root/emergency" + '/'
  return send_from_directory(EmergencyFolderPath,fileName)

if __name__ == '__main__':
  app.run(host='0.0.0.0', debug=True, port=8085)
