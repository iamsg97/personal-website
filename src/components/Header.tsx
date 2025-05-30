import { useEffect, useState } from 'react'
import { Link } from '@tanstack/react-router'
import { Button } from './ui/button'

export default function Header() {
  const [isMenuOpen, setIsMenuOpen] = useState(false)
  const [scrolled, setScrolled] = useState(false)

  // Handle scroll effect
  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 10)
    }

    window.addEventListener('scroll', handleScroll)
    return () => window.removeEventListener('scroll', handleScroll)
  }, [])

  // Close mobile menu when clicking on a navigation link
  const handleNavClick = () => {
    setIsMenuOpen(false)
  }

  return (
    <header
      className={`border-b bg-background sticky top-0 z-40 ${scrolled ? 'shadow-sm' : ''} transition-shadow`}
    >
      <div className="container flex h-16 items-center justify-between py-4">
        {/* Logo on the left */}
        <div>
          <Link to="/" className="font-bold text-xl">
            My Portfolio
          </Link>
        </div>

        {/* Navigation centered - desktop */}
        <div className="flex-grow flex justify-center">
          <nav className="hidden md:flex items-center gap-6 text-sm">
            <Link
              to="/"
              className="font-medium transition-colors hover:text-primary"
            >
              Home
            </Link>
            <a
              href="#about"
              className="font-medium transition-colors hover:text-primary"
              onClick={handleNavClick}
            >
              About
            </a>
            <a
              href="#skills"
              className="font-medium transition-colors hover:text-primary"
              onClick={handleNavClick}
            >
              Skills
            </a>
            <a
              href="#projects"
              className="font-medium transition-colors hover:text-primary"
              onClick={handleNavClick}
            >
              Projects
            </a>
            <a
              href="#contact"
              className="font-medium transition-colors hover:text-primary"
              onClick={handleNavClick}
            >
              Contact
            </a>
          </nav>
        </div>

        {/* Auth buttons on the right */}
        <div className="flex items-center gap-2">
          <div className="hidden md:block">
            <Button variant="outline" size="sm">
              Sign In
            </Button>
            <Button size="sm" className="ml-2">
              Sign Up
            </Button>
          </div>

          {/* Mobile menu button */}
          <button
            className="md:hidden p-2"
            onClick={() => setIsMenuOpen(!isMenuOpen)}
            aria-label="Toggle menu"
          >
            {isMenuOpen ? (
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                strokeWidth={1.5}
                stroke="currentColor"
                className="w-6 h-6"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M6 18L18 6M6 6l12 12"
                />
              </svg>
            ) : (
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                strokeWidth={1.5}
                stroke="currentColor"
                className="w-6 h-6"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5"
                />
              </svg>
            )}
          </button>
        </div>
      </div>

      {/* Mobile navigation */}
      {isMenuOpen && (
        <div className="md:hidden py-4 border-t bg-background">
          <nav className="container flex flex-col space-y-3">
            <Link
              to="/"
              className="px-4 py-2 font-medium transition-colors hover:text-primary"
              onClick={handleNavClick}
            >
              Home
            </Link>
            <a
              href="#about"
              className="px-4 py-2 font-medium transition-colors hover:text-primary"
              onClick={handleNavClick}
            >
              About
            </a>
            <a
              href="#skills"
              className="px-4 py-2 font-medium transition-colors hover:text-primary"
              onClick={handleNavClick}
            >
              Skills
            </a>
            <a
              href="#projects"
              className="px-4 py-2 font-medium transition-colors hover:text-primary"
              onClick={handleNavClick}
            >
              Projects
            </a>
            <a
              href="#contact"
              className="px-4 py-2 font-medium transition-colors hover:text-primary"
              onClick={handleNavClick}
            >
              Contact
            </a>
            <div className="flex gap-2 pt-4 px-4">
              <Button variant="outline" size="sm" className="w-full">
                Sign In
              </Button>
              <Button size="sm" className="w-full">
                Sign Up
              </Button>
            </div>
          </nav>
        </div>
      )}
    </header>
  )
}
