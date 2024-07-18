import { clsx } from 'clsx';
import Image from 'next/image';
import Button from '@/components/Button/Button';
import useOnchainCoffeeMemos from '../_hooks/useOnchainCoffeeMemos';
import FormBuyCoffee from './FormBuyCoffee';
import Memos from './Memos';

export default function BuyUsCupcakePage() {
  const pageSize = 5;
  const { memos, refetchMemos, currentPage, goToPreviousPage, goToNextPage } =
    useOnchainCoffeeMemos(pageSize);

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
          'p-10',
        ])} style={{ background: 'url(./img/Pages/buy-me-cupcake/_eca9303c-74e8-4d65-9643-4f3518741d8b.jpeg)' }}
      >
       <div className="flex items-center justify-start gap-4">
        <Image src="/img/Pages/buy-me-cupcake/_eca9303c-74e8-4d65-9643-4f3518741d8b.jpeg" width="200" height="200" />
        <h2 className="mb-5 w-fit text-2xl font-semibold text-black">💌 Messages from supporters</h2>
       </div>

        {memos?.length > 0 && <Memos memos={memos} />}
        <div className="mt-4 flex flex items-center justify-between">
          <Button
            className="w-auto px-10"
            onClick={goToPreviousPage}
            disabled={currentPage < 1}
            buttonContent={<span>Read older messages</span>}
          />

          <div className="text-black">Page {currentPage + 1}</div>

          <Button
            className="w-auto px-10"
            onClick={goToNextPage}
            disabled={memos.length < pageSize}
            buttonContent={<span>Read newer messages</span>}
          />
        </div>
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
