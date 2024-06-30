from flask import Flask, request, jsonify
import requests
import os
import datetime
import csv
import pickle
import time

app = Flask(__name__)

@app.route('/chillerstatus', methods=['POST'])
def processImage():
  file = request.files['file']
  filePath = '/root/scripts/Chiller_Alert/Machine_Name/' + str(file.filename)
  a = file.save(filePath)
  return "File Sent Successfully"

if __name__ == "__main__":               # on running python app.py
    app.run(host="0.0.0.0",port = 8084)   # run the flask app
