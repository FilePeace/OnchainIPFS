import { generateMetadata } from '@/utils/generateMetadata';

export const metadata = generateMetadata({
  title: 'Buy me a cupcake🧁 - Onchain IPFS',
  description:
    'Donate to Onchain IPFS: the service to store your files onchain and link them between IPFS, Arweave and Torrent.',
  images: 'themes.png',
  pathname: 'buy-me-coffee',
});

export default async function Layout({ children }: { children: React.ReactNode }) {
  return children;
}
