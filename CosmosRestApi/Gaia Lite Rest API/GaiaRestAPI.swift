//
//  GaiaRestAPI.swift
//  CosmosClient
//
//  Created by Calin Chitu on 02/01/2019.
//  Copyright © 2019 Calin Chitu. All rights reserved.
//

import Foundation

/* Needs RPC server to be started
 
 Specs url:  https://cosmos.network/rpc/
 Sample url: https://localhost:1317/keys
 
 */

public class GaiaRestAPI: NSObject, RestNetworking, URLSessionDelegate {
    
    static let minVersion = "0.32.0-2-g19f0f92c"
    
    let connectData: ConnectData
    
    public init(scheme: String = "https", host: String = "localhost", port: Int = 1317) {
        connectData = ConnectData(scheme: scheme, host: host, port: port)
        super.init()
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
    
    //ICS0 - endermint APIs, such as query blocks, transactions and validatorset
    
    public func getNodeInfo(completion: ((RestResult<[NodeInfo]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/node_info", delegate: self, singleItemResponse: true, timeout: 3, completion: completion)
    }
    
    public func getSyncingInfo(completion: ((RestResult<[String]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/syncing", delegate: self, singleItemResponse: true, timeout: 3, completion: completion)
    }
    
    public func getLatestBlock(completion: ((RestResult<[BlockRoot]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/blocks/latest", delegate: self, singleItemResponse: true, completion: completion)
    }
    
    public func getBlock(at height: Int, completion: ((RestResult<[BlockRoot]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/blocks/\(height)", delegate: self, singleItemResponse: true, completion: completion)
    }
    
    public func getLatestValidators(completion: ((RestResult<[Validators]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/validatorsets/latest", delegate: self, singleItemResponse: true, completion: completion)
    }
    
    public func getValidators(at height: Int, completion: ((RestResult<[Validators]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/validatorsets/\(height)", delegate: self, singleItemResponse: true, completion: completion)
    }
    
    public func getTransaction(by hash: String, completion: ((RestResult<[Transaction]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/txs/\(hash)", delegate: self, singleItemResponse: true, completion: completion)
    }
    
    public func getSentTransactions(by address: String, completion: ((RestResult<[Transaction]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/txs", delegate: self, queryItems: [URLQueryItem(name: "sender", value: "\(address)")], completion: completion)
    }
    
    public func getReceivedTransactions(by address: String, completion: ((RestResult<[Transaction]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/txs", delegate: self, queryItems: [URLQueryItem(name: "recipient", value: "\(address)")], completion: completion)
    }

    //ICS1 - Key management APIs
    
    public func createSeed(completion: ((RestResult<[String]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/keys/seed", delegate: self, singleItemResponse: true, completion: completion)
    }
    
    public func getKeys(completion: ((RestResult<[Key]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/keys", delegate: self, completion: completion)
    }
    
    public func getKey(by name: String, completion: ((RestResult<[Key]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/keys/\(name)", delegate: self, singleItemResponse: true, completion: completion)
    }
    
    public func createKey(keyData: KeyPostData, completion:((RestResult<[Key]>) -> Void)?) {
        genericRequest(bodyData: keyData, connData: connectData, path: "/keys", delegate: self, reqMethod: "POST", singleItemResponse: true, completion: completion)
    }
    
    public func recoverKey(keyData: KeyPostData, completion:((RestResult<[Key]>) -> Void)?) {
        genericRequest(bodyData: keyData, connData: connectData, path: "/keys/\(keyData.name)/recover", delegate: self, reqMethod: "POST", singleItemResponse: true, completion: completion)
    }
    
    public func deleteKey(keyData: KeyPostData, completion:((RestResult<[String]>) -> Void)?) {
        genericRequest(bodyData: keyData, connData: connectData, path: "/keys/\(keyData.name)", delegate: self, reqMethod: "DELETE", singleItemResponse: true, completion: completion)
    }
    
    public func changeKeyPassword(keyData: KeyPasswordData, completion:((RestResult<[String]>) -> Void)?) {
        genericRequest(bodyData: keyData, connData: connectData, path: "/keys/\(keyData.name)", delegate: self, reqMethod: "PUT", singleItemResponse: true, completion: completion)
    }
    
    public func getAccount(address: String, completion: ((RestResult<[Account]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/auth/accounts/\(address)", delegate: self, singleItemResponse: true, completion: completion)
    }
    
    public func getVestedAccount(address: String, completion: ((RestResult<[VestedAccount]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/auth/accounts/\(address)", delegate: self, singleItemResponse: true, completion: completion)
    }

    // ICS20
    
    public func bankTransfer(to address: String, transferData: TransferPostData, completion:((RestResult<[TransferResponse]>) -> Void)?) {
        genericRequest(bodyData: transferData, connData: connectData, path: "/bank/accounts/\(address)/transfers", delegate: self, reqMethod: "POST", singleItemResponse: true, completion: completion)
    }
    
    public func getBalance(address: String, completion: ((RestResult<[TxFeeAmount]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/bank/balances/\(address)", delegate: self, singleItemResponse: false, completion: completion)
    }
    
    
    // ICS21 - Stake module APIs
    
    public func getDelegations(for address: String, completion: ((RestResult<[Delegation]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/staking/delegators/\(address)/delegations", delegate: self, completion: completion)
    }
    
    public func delegation(from address: String, transferData: DelegationPostData, completion:((RestResult<[TransferResponse]>) -> Void)?) {
        genericRequest(bodyData: transferData, connData: connectData, path: "/staking/delegators/\(address)/delegations", delegate: self, reqMethod: "POST", singleItemResponse: true, completion: completion)
    }
    
    public func getDelegation(for address: String, validator: String, completion: ((RestResult<[Delegation]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/staking/delegators/\(address)/delegations/\(validator)", delegate: self, singleItemResponse: true, completion: completion)
    }
    
    public func getUnbondingDelegations(for address: String, completion: ((RestResult<[UnbondingDelegation]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/staking/delegators/\(address)/unbonding_delegations", delegate: self, completion: completion)
    }
    
    public func unbonding(from address: String, transferData: UnbondingDelegationPostData, completion:((RestResult<[TransferResponse]>) -> Void)?) {
        genericRequest(bodyData: transferData, connData: connectData, path: "/staking/delegators/\(address)/unbonding_delegations", delegate: self, reqMethod: "POST", singleItemResponse: true, completion: completion)
    }
    
    public func getUnbondingDelegation(for address: String, validator: String, completion: ((RestResult<[UnbondingDelegation]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/staking/delegators/\(address)/unbonding_delegations/\(validator)", delegate: self, singleItemResponse: true, completion: completion)
    }
    
    public func getRedelegations(for address: String, completion: ((RestResult<[Redelegation]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/staking/delegators/\(address)/redelegations", delegate: self, completion: completion)
    }
    
    public func redelegation(from address: String, transferData: RedelegationPostData, completion:((RestResult<[TransferResponse]>) -> Void)?) {
        genericRequest(bodyData: transferData, connData: connectData, path: "/staking/delegators/\(address)/redelegations", delegate: self, reqMethod: "POST", singleItemResponse: true, completion: completion)
    }
    
    public func getDelegatorValidators(for address: String, completion: ((RestResult<[DelegatorValidator]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/staking/delegators/\(address)/validators", delegate: self, singleItemResponse: false, completion: completion)
    }
    
    public func getDelegatorValidator(for address: String,  validator: String, completion: ((RestResult<[DelegatorValidator]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/staking/delegators/\(address)/validators/\(validator)", delegate: self, singleItemResponse: true, completion: completion)
    }
    
    public func getStakingTxs(for address: String, completion: ((RestResult<[Transaction]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/staking/delegators/\(address)/txs", delegate: self, singleItemResponse: false, completion: completion)
    }
    
    public func getStakeValidators(completion: ((RestResult<[DelegatorValidator]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/staking/validators", delegate: self, singleItemResponse: false, completion: completion)
    }
    
    public func getStakeValidator(for valAddress: String, completion: ((RestResult<[DelegatorValidator]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/staking/validators/\(valAddress)", delegate: self, singleItemResponse: true, completion: completion)
    }
    
    public func getStakeValidatorDelegations(for valAddress: String, completion: ((RestResult<[Delegation]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/staking/validators/\(valAddress)/delegations", delegate: self, singleItemResponse: false, completion: completion)
    }
    
    public func getStakeValidatorUnbondingDelegations(for valAddress: String, completion: ((RestResult<[UnbondingDelegation]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/staking/validators/\(valAddress)/unbonding_delegations", delegate: self, singleItemResponse: false, completion: completion)
    }
    
    public func getStakeValidatorRedelegations(for valAddress: String, completion: ((RestResult<[Redelegation]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/staking/validators/\(valAddress)/redelegations", delegate: self, singleItemResponse: false, completion: completion)
    }
    
    public func getStakePool(completion: ((RestResult<[StakePool]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/staking/pool", delegate: self, singleItemResponse: true, completion: completion)
    }
    
    public func getStakeParameters(completion: ((RestResult<[StakeParameters]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/staking/parameters", delegate: self, singleItemResponse: true, completion: completion)
    }
    
    
    //ICS22 - Governance
    
    public func submitProposal(transferData: ProposalPostData, completion:((RestResult<[TransferResponse]>) -> Void)?) {
        genericRequest(bodyData: transferData, connData: connectData, path: "/gov/proposals", delegate: self, reqMethod: "POST", singleItemResponse: true, completion: completion)
    }

    public func getPorposals(completion: ((RestResult<[Proposal]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/gov/proposals", delegate: self, singleItemResponse: false, completion: completion)
    }

    public func getPorposal(forId id: String, completion: ((RestResult<[Proposal]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/gov/proposals/\(id)", delegate: self, singleItemResponse: true, completion: completion)
    }
    
    public func getPorposalDeposits(forId id: String, completion: ((RestResult<[ProposalDeposit]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/gov/proposals/\(id)/deposits", delegate: self, singleItemResponse: false, completion: completion)
    }

    public func getPorposalDeposit(forId id: String, by depositor: String, completion: ((RestResult<[ProposalDeposit]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/gov/proposals/\(id)/deposits/\(depositor)", delegate: self, singleItemResponse: true, completion: completion)
    }

    public func getPorposalVotes(forId id: String, completion: ((RestResult<[ProposalVote]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/gov/proposals/\(id)/votes", delegate: self, singleItemResponse: false, completion: completion)
    }

    public func getPorposalTally(forId id: String, completion: ((RestResult<[ProposalTallyResult]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/gov/proposals/\(id)/tally", delegate: self, singleItemResponse: true, completion: completion)
    }

    public func getPorposalVote(forId id: String, by voter: String, completion: ((RestResult<[ProposalVote]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/gov/proposals/\(id)/votes/\(voter)", delegate: self, singleItemResponse: true, completion: completion)
    }

    public func depositToProposal(id: String, transferData: ProposalDepositPostData, completion:((RestResult<[TransferResponse]>) -> Void)?) {
        genericRequest(bodyData: transferData, connData: connectData, path: "/gov/proposals/\(id)/deposits", delegate: self, reqMethod: "POST", singleItemResponse: true, completion: completion)
    }

    public func voteProposal(id: String, transferData: ProposalVotePostData, completion:((RestResult<[TransferResponse]>) -> Void)?) {
        genericRequest(bodyData: transferData, connData: connectData, path: "/gov/proposals/\(id)/votes", delegate: self, reqMethod: "POST", singleItemResponse: true, completion: completion)
    }

    public func getGovDepositParameters(completion: ((RestResult<[GovDepositParameters]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/gov/parameters/deposit", delegate: self, singleItemResponse: true, completion: completion)
    }

    public func getGovTallyingParameters(completion: ((RestResult<[GovTallyingParameters]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/gov/parameters/tallying", delegate: self, singleItemResponse: true, completion: completion)
    }
    
    public func getGovVotingParameters(completion: ((RestResult<[GovVotingParameters]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/gov/parameters/voting", delegate: self, singleItemResponse: true, completion: completion)
    }


    //ICS23 - Slashing
    
    public func getSlashingSigningInfo(of valPubKey: String, completion: ((RestResult<[SigningInfo]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/slashing/validators/\(valPubKey)/signing_info", delegate: self, singleItemResponse: true, completion: completion)
    }

    public func unjail(validator valAddr: String, transferData: UnjailPostData, completion:((RestResult<[TransferResponse]>) -> Void)?) {
        genericRequest(bodyData: transferData, connData: connectData, path: "/slashing/validators/\(valAddr)/unjail", delegate: self, reqMethod: "POST", singleItemResponse: true, completion: completion)
    }

    public func getSlashingParameters(completion: ((RestResult<[SlashingParameters]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/slashing/parameters", delegate: self, singleItemResponse: true, completion: completion)
    }

    //ICS24 - Fee distribution module APIs
    
    // POST /distribution/delegators/{delegatorAddr}/rewards/{validatorAddr}

    public func withdrawReward(to address: String, fromValidator: String, transferData: TransferPostData, completion:((RestResult<[TransferResponse]>) -> Void)?) {
        genericRequest(bodyData: transferData, connData: connectData, path: "/distribution/delegators/\(address)/rewards/\(fromValidator)", delegate: self, reqMethod: "POST", singleItemResponse: true, completion: completion)
    }

    
    //Version
    
    public func getGaiaVersion(completion: ((RestResult<[String]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/version", delegate: self, singleItemResponse: true, completion: completion)
    }

    public func getNodeVersion(completion: ((RestResult<[String]>) -> Void)?) {
        genericRequest(bodyData: EmptyBody(), connData: connectData, path: "/node_version", delegate: self, singleItemResponse: true, completion: completion)
    }

}
