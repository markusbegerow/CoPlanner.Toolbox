import requests

server = ""
port = ""
username = ""
password = ""

session = requests.Session()
# For self-signed certificate:
session.verify = False

# Get login information
beforeSessionResult = session.get('https://' + server + ':' + port + '/coplanner/api/v1.0/apps/login')
beforeSessionResult.raise_for_status()
print ('BeforeSession successful')

scenarioId = beforeSessionResult.json()['scenarios'][0]['id']
entityId = beforeSessionResult.json()['entities']['elements'][0]['id']

# Log in
loginResult = session.post(
	'https://' + server + ':' + port + '/coplanner/token',
	data={
		'grant_type': 'password',
		'username': username,
		'password': password,
		'language_id': '0',
		'entity_id': entityId,
		'scenario_id': scenarioId,
		'client_type': 'Web',
		'culture_name': 'de'
	})
loginResult.raise_for_status()
print('Login successful')

# Update session information for future requests
tokenType = loginResult.json()['token_type']
accessToken = loginResult.json()['access_token']
session.headers['Authorization'] = tokenType + ' ' + accessToken

# Simple authenticated GET request (session information)
sessionResult = session.get('https://' + server + ':' + port + '/coplanner/api/v1.0/session')
sessionResult.raise_for_status()
print(sessionResult.json())

# GET request with query parameters
filteredData = session.get('https://' + server + ':' + port + '/coplanner/api/v1.0/data/tables/TBL_Umsatzerloese_PLAN', params={'$filter': 'Zeit mu 2023010103'})
print(filteredData.json())

# Log out
deleteResult = session.delete('https://' + server + ':' + port + '/coplanner/api/v1.0/session')
deleteResult.raise_for_status()
print('Logout successful')
