import logging

from crypy.client import Client

logging.basicConfig(level=logging.INFO)

def get_key():
    cc = Client('dcos', crypter_env='ops')
    sumo_key_id = cc.read_credential('SUMO_KEY_ID')
    sumo_key_secret = cc.read_credential('SUMO_KEY_SECRET')
    return sumo_key_id, sumo_key_secret

if __name__ == '__main__':
    key_id, key_secret = get_key()
    print '%s:%s' % (key_id, key_secret)
