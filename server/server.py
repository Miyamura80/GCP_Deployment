from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/ping')
def ping():
    return 'pong'

@app.route('/double', methods=['POST'])
def double():
    data = request.get_json()
    if 'number' not in data:
        return jsonify({'error': 'No number provided'}), 400
    
    try:
        number = float(data['number'])
        result = number * 2
        return jsonify({'result': result})
    except ValueError:
        return jsonify({'error': 'Invalid number provided'}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

