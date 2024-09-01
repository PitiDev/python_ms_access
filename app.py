import flask
from flask import jsonify, request
import subprocess
import csv
import io
import logging
from urllib.parse import unquote

app = flask.Flask(__name__)
logging.basicConfig(level=logging.DEBUG)

# Replace with your .mdb file path
MDB_PATH = '/SuperABS_DB.mdb'

def run_mdb_command(command):
    try:
        result = subprocess.run(command, capture_output=True, text=True, check=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        logging.error(f"Error running command {command}: {e}")
        logging.error(f"Stderr: {e.stderr}")
        return None

@app.route('/tables', methods=['GET'])
def get_tables():
    command = ['mdb-tables', '-1', MDB_PATH]
    output = run_mdb_command(command)
    if output is None:
        return jsonify({"error": "Failed to retrieve tables"}), 500
    
    tables = output.strip().split('\n')
    logging.debug(f"Retrieved tables: {tables}")
    return jsonify(tables)

@app.route('/table/<table_name>', methods=['GET'])
def get_table_data(table_name):
    command = ['mdb-export', MDB_PATH, table_name]
    output = run_mdb_command(command)
    
    if output is None:
        return jsonify({"error": f"Failed to retrieve data from table {table_name}"}), 500

    csv_reader = csv.DictReader(io.StringIO(output))
    data = list(csv_reader)
    
    return jsonify(data)

@app.route('/search', methods=['GET'])
def search_by_car_no():
    car_no = request.args.get('car_no')
    if not car_no:
        return jsonify({"error": "Missing car_no parameter"}), 400

    command = ['mdb-export', MDB_PATH, 'TableCarInfo']
    output = run_mdb_command(command)
    
    if output is None:
        return jsonify({"error": "Failed to retrieve data from TableCarInfo"}), 500

    csv_reader = csv.DictReader(io.StringIO(output))
    data = [row for row in csv_reader if row['Car___No'] == car_no]
    
    if not data:
        return jsonify({"message": "No matching records found"}), 404

    return jsonify(data)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=9000, debug=True)