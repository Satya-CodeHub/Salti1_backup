from flask import Flask, request, jsonify
import requests
import os
import datetime
import csv
import pickle
import time

app = Flask(__name__)

@app.route('/csalerts', methods=['POST','GET'])
def processfile():
  file = request.files['file']
  filePath = '/root/scripts/Cameraserver/Machine_Details/' + str(file.filename)
  a = file.save(filePath)
  return "File Sent Successfully"

if __name__ == "__main__":               # on running python app.py
    app.run(host="0.0.0.0",port = 61142)   # run the flask app
