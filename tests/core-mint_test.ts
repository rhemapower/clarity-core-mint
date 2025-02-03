import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure can mint NFT with valid params",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    const wallet1 = accounts.get("wallet_1")!;
    
    const mintTx = chain.mineBlock([
      Tx.contractCall(
        "core-mint",
        "mint-nft",
        [types.utf8("ipfs://metadata"), types.principal(wallet1.address)],
        deployer.address
      ),
    ]);

    assertEquals(mintTx.receipts.length, 1);
    assertEquals(mintTx.height, 2);
    mintTx.receipts[0].result.expectOk().expectUint(1);
  },
});

Clarinet.test({
  name: "Ensure can transfer NFT between accounts",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    const wallet1 = accounts.get("wallet_1")!;
    const wallet2 = accounts.get("wallet_2")!;
    
    let block = chain.mineBlock([
      Tx.contractCall(
        "core-mint",
        "mint-nft",
        [types.utf8("ipfs://metadata"), types.principal(wallet1.address)],
        deployer.address
      ),
    ]);

    block = chain.mineBlock([
      Tx.contractCall(
        "core-mint",
        "transfer-nft",
        [types.uint(1), types.principal(wallet1.address), types.principal(wallet2.address)],
        wallet1.address
      ),
    ]);

    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 3);
    block.receipts[0].result.expectOk().expectBool(true);
  },
});

Clarinet.test({
  name: "Ensure only owner can set minting fee",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get("wallet_1")!;
    
    const block = chain.mineBlock([
      Tx.contractCall(
        "core-mint",
        "set-minting-fee",
        [types.uint(2000000)],
        wallet1.address
      ),
    ]);

    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectErr().expectUint(100);
  },
});
