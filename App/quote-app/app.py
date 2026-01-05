from flask import Flask, jsonify
import pyodbc
import os
import requests
import struct
from datetime import datetime

app = Flask(__name__)

server = os.environ.get("SQL_SERVER")
database = os.environ.get("SQL_DATABASE")

def get_db():
    """Get database connection"""
    token = requests.get(
        "http://169.254.169.254/metadata/identity/oauth2/token",
        params={"api-version": "2018-02-01", "resource": "https://database.windows.net/"},
        headers={"Metadata": "true"},
        timeout=10
    ).json()["access_token"]
    
    token_bytes = token.encode("utf-16-le")
    token_struct = struct.pack(f"<I{len(token_bytes)}s", len(token_bytes), token_bytes)
    
    conn_str = (
        f"DRIVER={{ODBC Driver 18 for SQL Server}};"
        f"SERVER=tcp:{server},1433;"
        f"DATABASE={database};"
        "Encrypt=yes;TrustServerCertificate=yes;"
    )
    
    return pyodbc.connect(conn_str, attrs_before={1256: token_struct})

@app.route("/")
def quote():
    """Get random quote with response time"""
    try:
        start_time = datetime.now()
        conn = get_db()
        cursor = conn.cursor()
        cursor.execute("SELECT TOP 1 quote, author FROM quotes ORDER BY NEWID()")
        row = cursor.fetchone()
        conn.close()
        
        response_time = (datetime.now() - start_time).total_seconds() * 1000
        
        if row:
            return jsonify({
                row[1]: row[0],  # Author as key, quote as value
                "response_time_ms": response_time
            })
        else:
            return jsonify({"error": "No quotes found"}), 404
    except Exception as e:
        return jsonify({"error": "Database error", "message": str(e)}), 500

@app.route("/healthz")
def health():
    return jsonify({"status": "ok"}), 200

@app.route("/ready")
def ready():
    try:
        conn = get_db()
        conn.close()
        return jsonify({"status": "ready"}), 200
    except:
        return jsonify({"status": "not ready"}), 503

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
