import {loadStdlib} from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
const stdlib = loadStdlib(process.env);

const startingBalance = stdlib.parseCurrency(100);

const [ accAlice, accBob ] =
  await stdlib.newTestAccounts(2, startingBalance);
console.log('Hello, Alice and Bob!');



console.log('Launching...');
const ctcAlice = accAlice.contract(backend);
const ctcBob = accBob.contract(backend, ctcAlice.getInfo());

console.log("Creator is creating the testing NFT")

const theNFT= await stdlib.launchToken(accAlice,"Mona Lisa", "NFT", {supply:1} )
const nftParams= {
  nftId: theNFT.id,
  numTickets: 10
}

await accBob.tokenAccept(nftParams.nftId)
const OUTCOME= [ "Your number is not a match", "Your number is a match"];
const shared= {
  getnum: (numTickets)=>{
    const num= (Math.floor(Math.random()*numTickets)+1)
    return num
  },
  seeOutcome: (num)=>{
   console.log (`Outcome : ${OUTCOME[num]}`)
  }
}

console.log('Starting backends...');
await Promise.all([
  backend.Alice(ctcAlice, {
    ...stdlib.hasRandom,
    ...shared,
    startingRaffle: ()=>{
       console.log("Starting the raffle...")
       return nftParams

    },
    seeHash: (value)=>{
      console.log(`Winning number HASH: ${value}`)
    }
    // implement Alice's interact object here
  }),
  backend.Bob(ctcBob, {
    ...stdlib.hasRandom,
    ...shared,
    showNum: (num)=>{
      console.log(`the raffle number is ${num}`)
    },
    seeWinner: (num)=>{
      console.log(`the winner number is ${num}`)
    }
    

    // implement Bob's interact object here
  }),
]);

console.log('Goodbye, Alice and Bob!');
