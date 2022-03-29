from brownie import Swords, network, config,interface
import brownie
from scripts.global_helpful_script import (
    get_account,
    fund_with_link,
    listen_for_event,
    get_rarity,
)
import time
from web3 import Web3

# I think this function is clear ^^'
def deploy():
    account = get_account()
    swords_contract = Swords.deploy(
        config["networks"][network.show_active()]["key_hash"],
        0.1 * 10 ** 18,
        config["networks"][network.show_active()]["vrf_coordinator"],
        config["networks"][network.show_active()]["link_address"],
        {"from": account},
    )
    print("Done .. Deployed!")
    fund_with_linkTx = fund_with_link(
        swords_contract.address,
        config["networks"][network.show_active()]["link_address"],
        account,
    )
    # createCollectible(swords_contract,account)

# create collectible
def createCollectible():
    account = get_account()
    swords_contract = Swords[-1] # last deployed one
    link = interface.LinkTokenInterface(config["networks"][network.show_active()]["link_address"])
    balance = link.balanceOf(swords_contract.address)
    if balance >= Web3.toWei(0.1,"ether"):

        print("Creating NFT for you ...")
        print(time.ctime(time.time()))
        create_col = swords_contract.createCollectible({"from": account})
        create_col.wait(1) # wait 1 block
        #time.sleep(10)
        
        listen_for_event(swords_contract, "CollecibleCreated") # check this funtion in global_helpful_script
        requestId = create_col.events["requestCreationOfCollectible"]["requestId"] # get event
        itemId = swords_contract.requestIdToItemId(requestId)
        rarity = swords_contract.idToRarirty(itemId)
        itemUri = swords_contract.rarityToUri(rarity)
        print(rarity)
        if rarity == "0" or "1" :
            print(f"You don't have a big chance :(  your id Token is {itemId} and it's {get_rarity(rarity)} TokenUri : {itemUri}")

        elif rarity ==  "2" or "3" :
            print(f"You have some chance ^^ your id Token is {itemId} and it's {get_rarity(rarity)} TokenUri : {itemUri}")

        elif rarity == "5":
            print(f"Your token id is {itemId} and it's {get_rarity(rarity)} TokenUri : {itemUri}")
    
    else :
        print("contract has no Link" )

    print(time.ctime(time.time()))
def main():
    #deploy() # deploy contract 
    createCollectible() # interacte with it 
