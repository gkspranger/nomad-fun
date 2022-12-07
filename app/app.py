import os
from flask import Flask
app = Flask(__name__)

PORT = os.environ.get("APP_PORT", 10000)
INSTANCE = os.environ.get("APP_INSTANCE", 1)
NAME = os.environ.get("APP_NAME", "default")

@app.route("/")
def hello_world():
    return f"Hello, World! Instance={INSTANCE}; Port={PORT}; Name={NAME}"

if __name__ == '__main__':
   app.run(host="0.0.0.0", port=PORT)
