from flask import Flask, render_template 
  
app = Flask(__name__) 
  
# Debug setting set to true 
app.debug = True
  
@app.route('/') 
def index(): 
    return "Greetings Its working Folks"
  
if __name__ == '__main__': 
    app.run() 
