import Image from 'next/image';
import Link from 'next/link';

function DownloadLink({ href, label }: { href: string; label: string }) {
  return (
    <Link href={href} className="bg-blue-500 hover:bg-blue-600 text-white font-semibold py-2 px-4 rounded" download>
      {label}
    </Link>
  );
}

function PressKitItem({ title, imageSrc, alt, svgLink, pngLink, icoLink, darkBg }: PressKitItemProps) {
  return (
    <div className="bg-white rounded-lg shadow-md p-6">
      <h2 className="text-xl font-semibold mb-4 text-gray-800">{title}</h2>
      <div className={`flex justify-center items-center h-40 mb-4 ${darkBg ? 'bg-gray-800' : ''}`}>
        <Image src={imageSrc} alt={alt} width={200} height={100} style={{ objectFit: "contain" }} />
      </div>
      <div className="flex justify-center space-x-4">
        <DownloadLink href={svgLink} label="SVG" />
        <DownloadLink href={pngLink} label="PNG" />
        {icoLink && <DownloadLink href={icoLink} label="ICO" />}
      </div>
    </div>
  );
}

type PressKitItemProps = {
  title: string;
  imageSrc: string;
  alt: string;
  svgLink: string;
  pngLink: string;
  icoLink?: string;
  darkBg?: boolean;
};

export default function PressPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-4xl font-bold mb-8 text-center">Onchain IPFS Press Kit</h1>
      
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        <PressKitItem
          title="Logotype - Colored"
          imageSrc="/logotype.svg"
          alt="Onchain IPFS Logotype - Colored"
          svgLink="/logotype.svg"
          pngLink="/logotype.png"
        />
        <PressKitItem
          title="Logotype - Plain Black"
          imageSrc="/img/press/press-kit/logotype-plain_black.svg"
          alt="Onchain IPFS Logotype - Plain Black"
          svgLink="/img/press/press-kit/logotype-plain_black.svg"
          pngLink="/img/press/press-kit/logotype-plain_black.png"
        />
        <PressKitItem
          title="Logotype - Plain White"
          imageSrc="/img/press/press-kit/logotype-plain_white.svg"
          alt="Onchain IPFS Logotype - Plain White"
          svgLink="/img/press/press-kit/logotype-plain_white.svg"
          pngLink="/img/press/press-kit/logotype-plain_white.png"
          darkBg
        />
        <PressKitItem
          title="Icon"
          imageSrc="/logo.svg"
          alt="Onchain IPFS Icon"
          svgLink="/logo.svg"
          pngLink="/logo.png"
          icoLink="/favicon.ico"
        />
      </div>
    </div>
  );
}