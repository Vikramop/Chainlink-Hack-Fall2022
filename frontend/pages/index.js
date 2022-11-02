import Head from 'next/head'
import styles from '../styles/Home.module.css'
import Navbar from '../components/Navbar'

export default function Home() {

  return (
    <div>
      <Navbar />
      <h1 >Hello there 👋 Welcome to home page!</h1>
    </div>
  )
}
