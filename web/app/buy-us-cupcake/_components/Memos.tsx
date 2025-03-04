import MemoCard from './MemoCard';
import type { CoffeeMemo } from './types';

type MemosProps = {
  memos: CoffeeMemo[];
};

/**
 * Memos received from coffee purchases in BuyMeACoffee smart contract.
 *
 * @param memos List of memos.
 */
function Memos({ memos }: MemosProps) {
  if (!memos) {
    return null;
  }
  return (
    <ul className="flex w-full flex-col items-center gap-10">
      {memos.map((memo) => {
        return (
          <MemoCard
            key={memo.time.toString()}
            numCoffees={memo.numCoffees}
            userName={memo.userName}
            twitterHandle={memo.twitterHandle}
            lensHandle={memo.lensHandle}
            farcasterHandle={memo.farcasterHandle}
            message={memo.message}
            userAddress={memo.userAddress}
            time={memo.time}
          />
        );
      })}
    </ul>
  );
}

export default Memos;