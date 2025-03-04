'use client';

import { GitHubLogoIcon, TwitterLogoIcon, ArrowTopRightIcon } from '@radix-ui/react-icons';
import Image from 'next/image';
import NextLink from 'next/link';
import { NavbarLink } from '@/components/layout/header/Navbar';
{
  /*import FooterIcon from './FooterIcon';*/
}

export default function Footer() {
  return (
    <footer className="flex flex-1 flex-col justify-end">
      <div className="flex flex-col justify-between gap-16 bg-boat-footer-dark-gray py-12">
        <div className="container mx-auto flex w-full flex-col justify-between gap-16 px-8 md:flex-row">
          <div className="flex flex-col justify-between">
            <div className="flex h-8 items-center justify-start gap-4">
              <NextLink href="/" passHref className="relative h-8 w-8" aria-label="Home page">
                <Image src="/logo.svg" alt="Onchain IPFS Logo" width="32" height="37" />
              </NextLink>
              <NextLink
                href="/"
                passHref
                className="font-robotoMono text-center text-xl font-medium text-white no-underline"
              >
                ONCHAIN IPFS
              </NextLink>
              <NavbarLink href="https://github.com/danimesq/OnchainIPFS" target="_blank">
                <GitHubLogoIcon
                  width="24"
                  height="24"
                  aria-label="Onchain IPFS' Github respository"
                />
              </NavbarLink>
            </div>

            <div className="mt-8 flex flex-col items-center justify-center">
              <p className="text-base font-normal leading-7 text-boat-footer-light-gray">
                This project is licensed under the NonCommercial Creative Commons License - see the{' '}
                <NextLink
                  href="https://github.com/danimesq/OnchainIPFS/blob/main/LICENSE.md"
                  className="underline"
                  target="_blank"
                >
                  LICENSE.md
                </NextLink>{' '}
                file for details
              </p>
            </div>
          </div>

          <div className="font-robotoMono flex flex-col items-start justify-center gap-4 text-center text-xl font-medium text-white">
            <div className="flex h-8 items-center justify-start gap-4"><NextLink href="https://filepeace.github.io" target="_blank">
              <Image
                src="https://filepeace.github.io/logotype.svg"
                alt="FilePeace"
                width="189"
                height="32"
              />
            </NextLink>               <NavbarLink href="https://twitter.com/FilePeace" target="_blank">
                <TwitterLogoIcon
                  width="24"
                  height="24"
                  aria-label="Onchain IPFS' Github respository"
                />
              </NavbarLink></div>
            <NavbarLink href="/">
              <span className="flex items-center gap-1 px-2">Onchain IPFS (you&apos;re here!)</span>
            </NavbarLink>
            <NavbarLink href="https://github.com/FilePeace/folderstamp" target="_blank">
              <span className="flex items-center gap-1 px-2">
                Folderstamp <ArrowTopRightIcon width="16" height="16" />
              </span>
            </NavbarLink>
            <NavbarLink href="https://github.com/FilePeace/webpresent" target="_blank">
              <span className="flex items-center gap-1 px-2">
                Webpresent <ArrowTopRightIcon width="16" height="16" />
              </span>
            </NavbarLink>
            {/*<NavbarLink href="/paymaster-bundler">
              <span className="flex items-center gap-1 px-2">
                Paymaster Bundler <ArrowTopRightIcon width="16" height="16" />
              </span>
            </NavbarLink>*/}
          </div>
        </div>
      </div>
    </footer>
  );
}
