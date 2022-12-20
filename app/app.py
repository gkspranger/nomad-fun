import os
from flask import Flask
app = Flask(__name__)

PORT = os.environ.get("APP_PORT", 10000)
INSTANCE = os.environ.get("APP_INSTANCE", 1)
NAME = os.environ.get("APP_NAME", "default")
VERSION = os.environ.get("APP_VERSION", "0.1")

def get_env_vars():
    result = ""
    print(f"going to print env vars")
    for k, v in os.environ.items():
        print(f"{k}={v}")
        # if "env" in k:
        #     result = f"{result}; {k}={v}"
        #     print(f"{k}={v}")
    return result

@app.route("/")
def hello_world():
    get_env_vars()
    return f"Hello, World! Instance={INSTANCE}; Port={PORT}; Name={NAME}; Version={VERSION}; EnvVars=''"

if __name__ == '__main__':
   app.run(host="0.0.0.0", port=PORT)
