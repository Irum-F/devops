import os
from flask import Flask
import MySQLdb

app = Flask(__name__)

@app.route('/')
def hello_world():
    db = MySQLdb.connect(
        host=os.getenv("DB_HOST", "localhost"),
        user=os.getenv("DB_USER", "root"),
        passwd=os.getenv("DB_PASSWORD"),
        db=os.getenv("DB_NAME", "mysql")
    )
    cur = db.cursor()
    cur.execute("SELECT VERSION()")
    version = cur.fetchone()
    return f'Hello, World! MySQL version: {version[0]}'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.getenv("PORT", 5002)))