from flask import Flask, jsonify, request
from flask_cors import CORS
from analyze_v2 import findSection

app = Flask(__name__)
CORS(app)
@app.route('/')
def results():
    json_file = {}
    json_file['Verdict'] = 'Section 378 : Theft'
    return jsonify(json_file)

@app.route('/data', methods = ['POST'])
def recieve_data():
    data = request.get_json()
    if 'description' in data:
        description = data['description']
        result = findSection(description)
        print(result)
        print(f'description recieved : {description}')
        return jsonify(result),200

if __name__ == '__main__':
    app.run(debug=True, host= '0.0.0.0',port=51561)