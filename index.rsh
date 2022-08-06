'reach 0.1';
const amt=1;
const shared= {
  getnum: Fun([UInt], UInt),
  seeOutcome: Fun([UInt], Null)
}
export const main = Reach.App(() => {
  const A = Participant('Alice', {
    // Specify Alice's interact interface here
    ...shared,
    ...hasRandom,
    startingRaffle: Fun([], Object ({
      nftId: Token,
      numTickets: UInt

    })),
    seeHash: Fun([Digest], Null)
  });
  const B = Participant('Bob', {
    ...shared,
    showNum: Fun([UInt], Null),
    seeWinner: Fun([UInt], Null)
    // Specify Bob's interact interface here
  });
  init();
  // The first one to publish deploys the contract
  A.only(()=>{
    const {nftId, numTickets}= declassify(interact.startingRaffle());
    const _winningNum= (interact.getnum(numTickets));
    const [_commitA, _saltA]= makeCommitment(interact, _winningNum);
    const commitA= declassify(_commitA);
  })
  A.publish(nftId, numTickets, commitA)
  A.interact.seeHash(commitA);
  commit();
  A.pay([[amt, nftId]]);
  commit();

  unknowable(B, A(_winningNum, _saltA)) 
  B.only(()=>{
    const myNum= declassify(interact.getnum(numTickets))
    interact.showNum(myNum)
  })
  // The second one to publish always attaches
  B.publish(myNum);
  commit();

  A.only(()=>{
    const saltA= declassify(_saltA)
    const winningNum= declassify(_winningNum )
  })
  A.publish(saltA, winningNum )
  checkCommitment(commitA,saltA, winningNum);


  B.interact.seeWinner(winningNum)
  const outcome=(myNum==winningNum? 1:0 )
  transfer(amt, nftId).to(outcome==0? A: B )
 

  each ([A,B], ()=>{
    interact.seeOutcome(outcome)
   
  })
 commit();
   
  // write your program here
  exit();
});
