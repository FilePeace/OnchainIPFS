import { ExclamationTriangleIcon } from '@radix-ui/react-icons';
import { parseEther } from 'viem';

import { useAccount } from 'wagmi';
import { UseContractReturn } from '@/hooks/contracts';
import { useLoggedInUserCanAfford } from '@/hooks/useUserCanAfford';

function useCanUserAfford(amount: string) {
  const canAfford = useLoggedInUserCanAfford(parseEther(amount));
  if (!amount || isNaN(parseFloat(amount))) {
    console.error('Invalid amount:', amount);
    return false;
  }
  return canAfford;
}

export function ContractAlertLayout({ children, isError }: { children: React.ReactNode, isError?: boolean }) {
  return (
    <div className="my-3 flex items-center justify-center">
      <div className="mr-2">
        <ExclamationTriangleIcon width={12} height={12} color={isError ? 'red' : 'currentColor'} />
      </div>
      <div className={`text-xs ${isError ? 'text-red-500' : ''}`}>{children}</div>
    </div>
  );
}

type ContractAlertProps = {
  contract: UseContractReturn<unknown>;
  amount: number;
  coffeeCount?: number;
  ethPrice?: number | null;
};

export default function ContractAlert({ contract, amount, coffeeCount = 1, ethPrice }: ContractAlertProps) {
  const { isConnected } = useAccount();
  const requiredAmount = parseFloat(amount) * coffeeCount;

  if (isNaN(requiredAmount)) {
    console.error('Calculation error:', { amount, coffeeCount });
    return null;
  }

  // Ensure hooks are called at the top level
  const canAfford = useCanUserAfford(requiredAmount.toFixed(18));
  if (!requiredAmount || isNaN(parseFloat(requiredAmount))) {
    console.error('Invalid amount:', requiredAmount);
    return false;
  }

  console.log('Checking affordability:', { requiredAmount: requiredAmount.toFixed(18), canAfford });

  if (!isConnected) {
    return (
      <ContractAlertLayout isError>
        <div style={{ color: 'yellow' }}>Please connect your wallet to continue.</div>
      </ContractAlertLayout>
    );
  }

  if (contract.status === 'onUnsupportedNetwork') {
    return (
      <ContractAlertLayout>
        Please connect to one of the supported networks to continue: {contract.supportedChains.map((c) => c.name).join(', ')}
      </ContractAlertLayout>
    );
  }

  if (contract.status === 'deactivated') {
    return <ContractAlertLayout>This contract has been deactivated on this chain.</ContractAlertLayout>;
  }

  if (!canAfford) {
    return (
      <ContractAlertLayout isError>
        You must have at least {requiredAmount.toFixed(4)} ETH ({ethPrice ? `$${(requiredAmount * ethPrice).toFixed(2)}` : 'loading...'}) in your wallet to continue.
      </ContractAlertLayout>
    );
  }

  return null;
}