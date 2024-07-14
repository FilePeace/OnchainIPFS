import { clsx } from 'clsx';
import useOnchainCoffeeMemos from '../_hooks/useOnchainCoffeeMemos';
import FormBuyCoffee from './FormBuyCoffee';
import Memos from './Memos';

export default function BuyMeCoffeeContractDemo() {
  const { memos, refetchMemos } = useOnchainCoffeeMemos();

  return (
    <div
      className={clsx([
        'grid grid-cols-1 items-stretch justify-start',
        'md:grid-cols-2CoffeeMd md:gap-9 lg:grid-cols-2CoffeeLg',
      ])}
    >
      <section
        className={clsx([
          'rounded-lg border border-solid border-boat-color-palette-line',
          'bg-boat-color-palette-backgroundalternate p-10',
        ])}
      >
        <h2 className="mb-5 w-fit text-2xl font-semibold text-white">Messages from supporters</h2>

        {memos?.length > 0 && <Memos memos={memos} />}
      </section>
      <aside>
        <div
          className={clsx([
            'mt-10 rounded-lg border border-solid border-boat-color-palette-line',
            'bg-boat-color-palette-backgroundalternate p-10 md:mt-0',
          ])}
        >
          <FormBuyCoffee refetchMemos={refetchMemos} />
        </div>
      </aside>
          <section
            className={clsx(
              'flex flex-col items-center justify-between gap-6 p-6 md:flex-row md:gap-0',
              `rounded-lg border border-zinc-400 border-opacity-10 bg-white bg-opacity-10 p-4 backdrop-blur-2xl`,
            )}
          >
            Donate and help the development of Onchain IPFS: the service to store your files onchain and link them between IPFS, Arweave and Torrent.
          </section>
    </div>
  );
}
