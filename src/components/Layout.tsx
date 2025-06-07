import { Outlet } from '@tanstack/react-router'
import { TanStackRouterDevtools } from '@tanstack/react-router-devtools'
import { ThemeProvider } from '../contexts/ThemeContext'
import Footer from './Footer'
import Header from './Header'

export default function Layout() {
  return (
    <ThemeProvider defaultTheme="system" storageKey="portfolio-theme">
      <div className="flex min-h-screen flex-col">
        <Header />

        <main className="container mx-auto flex-grow px-4 py-8">
          <Outlet />
        </main>

        <Footer />
        <TanStackRouterDevtools />
      </div>
    </ThemeProvider>
  )
}
