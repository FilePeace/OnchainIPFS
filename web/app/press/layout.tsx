import { generateMetadata } from '@/utils/generateMetadata';

export const metadata = generateMetadata({
  title: 'Press - Onchain IPFS',
  description:
    'Press Kit page of Onchain IPFS: the service to store your files onchain and link them between IPFS, Arweave and Torrent.',
  images: 'themes.png',
  pathname: 'press',
});

export default async function Layout({ children }: { children: React.ReactNode }) {
  return children;
}
