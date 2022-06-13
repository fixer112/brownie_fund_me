from brownie import FundMe
from scripts.helper import get_account
from web3 import Web3


def fund():
    fund_me = FundMe[-1]
    account = get_account()
    # print()
    entrance_fee = fund_me.getEntranceFee(0)
    print(entrance_fee)
    # print(f"The current entry fee is {entrance_fee}")
    # print("Funding")
    # fund_me.fund({"from": account, "value": entrance_fee})


def withdraw():
    fund_me = FundMe[-1]
    account = get_account()
    fund_me.withdraw({"from": account})


def main():
    fund()
    # withdraw()
