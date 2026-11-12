import json
d = json.load(open('android/app/google-services.json'))
c = d['client'][0]; p = d['project_info']
print(json.dumps({'android': {
    'apiKey': c['api_key'][0]['current_key'],
    'appId': c['client_info']['mobilesdk_app_id'],
    'messagingSenderId': p['project_number'],
    'projectId': p['project_id'],
    'storageBucket': p.get('storage_bucket'),
}}))
