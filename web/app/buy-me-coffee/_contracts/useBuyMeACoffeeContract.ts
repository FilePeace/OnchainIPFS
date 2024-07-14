import { baseSepolia } from 'viem/chains';
import { generateContractHook } from '@/hooks/contracts';
import BuyMeACoffeeABI from './BuyMeACoffeeABI';

/**
 * Returns contract data for the BuyMeACoffee contract.
 */
export const useBuyMeACoffeeContract = generateContractHook({
  abi: BuyMeACoffeeABI,
  [baseSepolia.id]: {
    chain: baseSepolia,
    address: '0xc877b2a5c7b65ef516c60d95535b97eee25f900c',
  },

  // ... more chains for this contract go here
});
