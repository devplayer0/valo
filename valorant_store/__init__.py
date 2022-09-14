import json
import asyncio
import aiohttp
import re
import getpass
import riot_auth

region = 'eu'

async def amain(formuser, formpass):
    auth = riot_auth.RiotAuth()
    await auth.authorize(formuser, formpass)

    async with aiohttp.ClientSession() as session:
        headers = {
            'X-Riot-Entitlements-JWT': auth.entitlements_token,
            'Authorization': 'Bearer ' + auth.access_token,
        }
        async with session.get(
            f'https://pd.{region}.a.pvp.net/store/v2/storefront/' + auth.user_id,
            headers=headers) as r:
            data = json.loads(await r.text())
        allstore = data.get('SkinsPanelLayout')
        singleitems = allstore['SingleItemOffers']

        for i, item in enumerate(singleitems):
            async with session.get(
                    'https://valorant-api.com/v1/weapons/skinlevels/' + item) as r:
                skin = json.loads(await r.text())['data']
                print(f'skin {i}: {skin["displayName"]}')

def main():
    riotuser = input('user: ')
    riotpass = getpass.getpass('pass: ')

    asyncio.run(amain(riotuser, riotpass))
