import { Avatar, Name } from '@coinbase/onchainkit/identity';
import { clsx } from 'clsx';
import { convertBigIntTimestampToDate } from '@/utils/timestamp';
import type { CoffeeMemo } from './types';

/**
 * Memo received from the coffee purchase in BuyMeACoffee smart contract.
 *
 * @param twitterHandle Twitter handle of the person who sent the memo.
 * @param lensHandle Lens handle of the person who sent the memo.
 * @param farcasterHandle Farcaster handle of the person who sent the memo.
 * @param message Message sent by the person.
 * @param timestamp Timestamp of the memo.
 */
function MemoCard({ numCoffees, twitterHandle, lensHandle, farcasterHandle, message, userAddress, time, userName }: CoffeeMemo) {
  const convertedTimestamp = convertBigIntTimestampToDate(time);
  const numCoffeesInt = Number(numCoffees);

  return (
    <li className="flex w-full flex-col items-start gap-4 rounded-2xl border-[color:var(--boat-color-foregroundMuted,#000)] border-2 backdrop-blur-[20px]">
      <div className="w-full grow items-center justify-between lg:flex bg-boat-color-palette-backgroundalternate rounded-2xl border-2">
        <div className="flex items-center gap-3">
          <div title={userName} style={{ borderRadius: '50%', overflow: 'hidden' }}>
            <Avatar address={userAddress} />
          </div>
          <div className="inline-flex items-start gap-1 md:flex">
            <span className="text-3 text-bold truncate text-wrap font-bold text-white">
              <div title={userName}>
                <Name address={userAddress} />
              </div>
            </span>
            <span className="text-3 line-clamp-1 flex-1 truncate text-wrap break-all font-normal text-boat-color-palette-foregroundmuted">
              {lensHandle && (
                <a href={`https://hey.xyz/u/${lensHandle}`} target="_blank" rel="noopener noreferrer">
                  <img src="/img/social/button/lens.svg" alt="Lens" title={`@${lensHandle}`} className="social-icon" width="16" height="16" />
                </a>
              )}
              {twitterHandle && (
                <a href={`https://twitter.com/${twitterHandle}`} target="_blank" rel="noopener noreferrer">
                  <img src="/img/social/button/twitter.svg" alt="Twitter" title={`@${twitterHandle}`} className="social-icon" width="16" height="16" />
                </a>
              )}
              {farcasterHandle && (
                <a href={`https://warpcast.com/${farcasterHandle}`} target="_blank" rel="noopener noreferrer">
                  <img src="/img/social/button/farcaster.svg" alt="Farcaster" title={`@${farcasterHandle}`} className="social-icon" width="16" height="16" />
                </a>
              )}
            </span>
            <span className="text-3 whitespace-nowrap font-normal text-boat-color-palette-foregroundmuted">
              bought {numCoffeesInt} cupcake{numCoffeesInt > 1 ? 's' : ''}
            </span>
          </div>
        </div>
        <div className="text-3 ml-[43px] whitespace-nowrap font-normal text-boat-color-palette-foregroundmuted">
          {convertedTimestamp.toDateString()}
        </div>
      </div>
      <div
        className={clsx([
          'flex w-full items-center rounded-2xl border-2',
          'border-solid border-[color:var(--boat-color-foregroundMuted,#8A919E)] p-6 backdrop-blur-[20px]',
        ])}
      >
        <p className="flex w-[0px] shrink grow items-start gap-1">
          <span
            className={clsx([
              'truncate whitespace-nowrap text-wrap text-base ',
              'font-normal not-italic leading-6 text-black',
            ])}
          >
            {message}
          </span>
        </p>
      </div>
    </li>
  );
}

export default MemoCard;