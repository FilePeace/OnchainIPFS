import type { Metadata } from 'next';

type MetaTagsProps = {
  title: string;
  description: string;
  frame?: Record<string, string> | Record<string, never>;
  images: string | string[];
  url?: string;
  pathname: string;
};

const deployUrl = process.env.BOAT_DEPLOY_URL ?? process.env.VERCEL_URL;
const defaultUrl = deployUrl
  ? `https://${deployUrl}`
  : `http://localhost:${process.env.PORT ?? 3000}`;

export const generateMetadata = ({
  title = 'Onchain IPFS',
  description = 'The service to store your files onchain and link them between IPFS, Arweave and Torrent.',
  frame = {},
  images,
  url = 'https://github.com/danimesq/OnchainIPFS',
  pathname,
}: MetaTagsProps): Metadata => {
  const i = Array.isArray(images) ? images : [images];
  return {
    metadataBase: new URL(defaultUrl),
    title,
    description,
    openGraph: {
      url: `${url}${pathname ?? ''}`,
      title,
      description,
      images: i.map((img) => `${url}/social/${img}`),
    },
    other: {
      ...frame,
    },
  };
};
