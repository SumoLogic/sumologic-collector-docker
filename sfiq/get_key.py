import logging

from crypy.client import Client

logging.basicConfig(level=logging.INFO)

def get_key():
	crypter_role = os.environ.get('CRYPTER_ROLE', 'dcos')
	crypter_env = os.environ.get('CRYPTER_ENV', 'ops')
	crypter_key_for_sumo_key_id = os.environ.get('CRYPTER_KEY_FOR_SUMO_KEY_ID', 'SUMO_KEY_ID')
	crypter_key_for_sumo_key_secret = os.environ.get('CRYPTER_KEY_FOR_SUMO_KEY_SECRET', 'SUMO_KEY_SECRET')
	cc = Client(crypter_role, crypter_env=crypter_env)
	sumo_key_id = cc.read_credential(crypter_key_for_sumo_key_id)
	sumo_key_secret = cc.read_credential(crypter_key_for_sumo_key_secret)
	return sumo_key_id, sumo_key_secret

if __name__ == '__main__':
	key_id, key_secret = get_key()
	print '%s:%s' % (key_id, key_secret)
