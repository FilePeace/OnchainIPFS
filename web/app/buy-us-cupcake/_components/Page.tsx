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

  // Define the clipart filenames
  const cliparts = [
    '_eca9303c-74e8-4d65-9643-4f3518741d8b.jpeg.png',
    '_e05bc47c-aca7-4ae9-b40f-e96a99f67c8b.jpeg.png'
  ];

  // Define the background filenames
  const backgrounds = [
    '_eca9303c-74e8-4d65-9643-4f3518741d8b.jpeg',
    '_e05bc47c-aca7-4ae9-b40f-e96a99f67c8b.jpeg'
  ];

  // Randomly select a clipart and a background
  const randomClipart = cliparts[Math.floor(Math.random() * cliparts.length)];
  const randomBackground = backgrounds[Math.floor(Math.random() * backgrounds.length)];

  return (
    <div>
      <section
        className="w-full p-6 bg-white bg-opacity-10 backdrop-blur-2xl rounded-lg border border-zinc-400 border-opacity-10"
      >
        Donate and help the development of Onchain IPFS: the service to store your files onchain and link them between IPFS, Arweave and Torrent.
      </section>

      <div
        className={clsx([
          'grid grid-cols-1 items-stretch justify-start',
          'md:grid-cols-2 md:gap-9 lg:grid-cols-3 lg:gap-9',
        ])}
      >
        <section
          className={clsx([
            'lg:col-span-2 rounded-lg border border-solid border-boat-color-palette-line',
            'p-10',
          ])} style={{ background: `url(/img/Pages/buy-me-cupcake/bg/${randomBackground})` }}
        >
          <div className="flex items-center justify-start gap-4">
            <Image src={`/img/Pages/buy-me-cupcake/clipart/${randomClipart}`} width="200" height="200" alt={`Clipart: ${randomClipart}`} />
            <div className="flex flex-col">
              <h2 className="mb-5 w-fit text-2xl font-semibold text-black">💌 Messages from supporters</h2>
              <p className="text-xl text-black">Buy us a cupcake if you want to appear here!</p>
            </div>
          </div>

          {memos?.length > 0 && <Memos memos={memos} />}
          <div className="mt-4 flex flex items-center justify-between">
            <Button
              className={clsx('w-auto px-10', { 'opacity-50 cursor-not-allowed': currentPage === 0 })}
              onClick={goToPreviousPage}
              disabled={currentPage === 0}
              buttonContent={<span>Read older messages</span>}
            />

            <div className="text-black">Page {currentPage + 1}</div>

            <Button
              className={clsx('w-auto px-10', { 'opacity-50 cursor-not-allowed': memos.length < pageSize })}
              onClick={goToNextPage}
              disabled={memos.length < pageSize}
              buttonContent={<span>Read newer messages</span>}
            />
          </div>
        </section>
        <aside className="lg:col-span-1">
          <div
            className={clsx([
              'rounded-lg border border-solid border-boat-color-palette-line',
              'bg-boat-color-palette-backgroundalternate p-10 md:mt-0',
            ])}
          >
            <FormBuyCoffee refetchMemos={refetchMemos} />
          </div>
        </aside>
      </div>
    </div>
  );
}