import { createContext, useContext, useEffect, useState } from 'react';
import Web3 from 'web3';

const BlockchainContext = createContext();

export function BlockchainProvider({ children }) {
  const [web3, setWeb3] = useState(null);
  const [account, setAccount] = useState('');

  useEffect(() => {
    const connectWallet = async () => {
      if (window.ethereum) {
        const web3Instance = new Web3(window.ethereum);
        try {
          await window.ethereum.request({ method: 'eth_requestAccounts' });
          const accounts = await web3Instance.eth.getAccounts();
          setWeb3(web3Instance);
          setAccount(accounts[0]);
        } catch (error) {
          console.error('Wallet connection failed:', error);
        }
      }
    };
    connectWallet();
  }, []);

  return (
    <BlockchainContext.Provider value={{ web3, account }}>
      {children}
    </BlockchainContext.Provider>
  );
}

export const useBlockchain = () => useContext(BlockchainContext);