//import { clsx } from 'clsx';
//import Image from 'next/image';
import NextLink from 'next/link';

export default function PressPage() {

  return (
     <div>
     {/* <div
      className={clsx([
        'grid grid-cols-1 items-stretch justify-start',
        'md:grid-cols-2CoffeeMd md:gap-9 lg:grid-cols-2CoffeeLg',
      ])}
    > */}
            {/* <h1>Press kit <NextLink href="./press/press-kit">here</NextLink>.</h1> */}
            <center><img width="256px" src="./img/press/press-kit/logotype-plain_black.svg" title="Onchain IPFS" alt="Onchain IPFS"/><br/><h1>Press Kit</h1><h2>Onchain IPFS logos and brand assets</h2></center>
<hr/>
<h3>Onchain IPFS Logotypes</h3>
<div className="flex h-8 items-center justify-start gap-4"><h5>Logotype - colored</h5>
<img width="315px" src="./logotype.svg"/>
<NextLink href="./logotype.svg" target="_blank">SVG</NextLink><p> | </p><NextLink href="./logotype.png" target="_blank">PNG</NextLink>
<h5>Logotype 1-color (plain) Black</h5>
<img width="315px" src="./img/press/press-kit/logotype-plain_black.svg"/>
<br/><NextLink href="./img/press/press-kit/logotype-plain_black.svg" target="_blank">SVG</NextLink><p> | </p><NextLink href="./img/press/press-kit/logotype-plain_black.png" target="_blank">PNG</NextLink>
</div>
<h5>Logotype 1-color (plain) White</h5>
<img width="315px" src="./img/press/press-kit/logotype-plain_white.svg"/>
<br/><NextLink href="./img/press/press-kit/logotype-plain_white.svg" target="_blank">SVG</NextLink><p> | </p><NextLink href="./img/press/press-kit/logotype-plain_white.png" target="_blank">PNG</NextLink>
<h3>Onchain IPFS Icons/Logos</h3>
<h5>Icon</h5>
<img width="256px" src="./logo.svg"/>
<br/><NextLink href="./logo.png" target="_blank">PNG</NextLink><p> | </p><NextLink href="./favicon.ico" target="_blank">ICO</NextLink><p> | </p><NextLink href="./logo.svg" target="_blank">SVG</NextLink>
    </div>
  );
}
