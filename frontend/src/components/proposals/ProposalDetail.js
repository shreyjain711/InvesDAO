import {Client, Identity, KeyInfo} from '@textile/hub';

async function authorize (key: KeyInfo, identity: Identity) {
  const client = await Client.withKeyInfo(key)
  await client.getToken(identity)
  return client
}