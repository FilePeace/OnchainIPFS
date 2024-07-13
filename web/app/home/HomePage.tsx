'use client';
import { useAccount } from 'wagmi';
import Footer from '@/components/layout/footer/Footer';
import Header from '@/components/layout/header/Header';

/**
 * Use the page component to wrap the components
 * that you want to render on the page.
 */
export default function HomePage() {
  const account = useAccount();

  return (
    <>
      <Header />
      <main className="container mx-auto flex flex-col px-8 py-16">
        <div>
          <p>Make your files permanent by storing them onchain. Store files referenced by Ethereum L1, on L2! A 100% Ethereum-aligned alternative to Arweave. Helps Arweave itself to be linked to an IPFS CID. Currently, Filecoin and Arweave (two non-Ethereum L1s) are the only way to store NFT metadata and other IPFS files' contents onchain. On Arweave, it is harder to obtain the file content for those used to IPFS. Onchain IPFS come to solve both issues: onchain storage (using the Ethereum-aligned L2 Base) and linking: CID&lt;-&gt;Arweave TXID&lt;-&gt;Torrent URI.</p>
          <hr/>
          <h2 className="text-xl">Developer information</h2>
          <br />
          <h3 className="text-lg">Account</h3>
          <ul>
            <li>
              <b>status</b>: {account.status}
            </li>
            <li>
              <b>addresses</b>: {JSON.stringify(account.addresses)}
            </li>
            <li>
              <b>chainId</b>: {account.chainId}
            </li>
          </ul>
        </div>
      </main>
      <Footer />
    </>
  );
}
