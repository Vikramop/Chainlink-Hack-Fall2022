import '../styles/globals.css'
// import Navbar from '../components/Navbar'
import '@rainbow-me/rainbowkit/styles.css'
import {
  getDefaultWallets,
  RainbowKitProvider,
} from '@rainbow-me/rainbowkit'
import {
  chain,
  configureChains,
  createClient,
  WagmiConfig,
} from 'wagmi'
import { alchemyProvider } from 'wagmi/providers/alchemy'
import { publicProvider } from 'wagmi/providers/public'

function MyApp({ Component, pageProps }) {
  const { chains, provider } = configureChains(
    [chain.polygonMumbai],
    [
      alchemyProvider({ apiKey: 'ivcJQdjhx-71mh0dCV1ILW3yMdG4ojCB' }),
      publicProvider()
    ],
  );

  const { connectors } = getDefaultWallets({
    appName: 'My App',
    chains
  });

  const wagmiClient = createClient({
    autoConnect: true,
    connectors,
    provider
  });

  return (
    <WagmiConfig client={wagmiClient}>
      <RainbowKitProvider chains={chains}>
        {/* <Navbar /> */}
        <Component {...pageProps} />
      </RainbowKitProvider>
    </WagmiConfig>
  ); 
}

export default MyApp
